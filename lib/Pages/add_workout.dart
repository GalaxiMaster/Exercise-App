import 'dart:async';
import 'package:exercise_app/Pages/confirm_workout.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:vibration/vibration.dart';
import 'choose_exercise.dart';

class Addworkout extends ConsumerStatefulWidget {
  final Map sets;
  final bool editing;
  final WorkoutMetaData? metaData;
  const Addworkout({
    super.key, 
    Map? sets,
    this.editing = false, 
    this.metaData,
  }) : sets = sets ?? const {}; // Assign default if null passed through

  @override
  AddworkoutState createState() => AddworkoutState();
}

class AddworkoutState extends ConsumerState<Addworkout> {
  Map sets = {};
  Map stats = {};
  String startTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()).toString();
  Map<String, List<Map<String, FocusNode>>> _focusNodes = {};
  Map<String, List<Map<String, TextEditingController>>> _controllers = {};
  Map<String, List<bool>> _checkBoxStates = {};
  Map exerciseTypeAccess = {};
  bool loading = false;

  Map boxErrors = {};
  @override
  void initState() { // TODO clean up this page, specifically this initstate section and to do with currentWorkout
    super.initState();
    loading = true;
    if(widget.sets.isEmpty){
      ref.read(currentWorkoutProvider).whenData((data) {
        setState(() {
          sets = data['sets'] ?? {};
          stats['notes'] = data['stats']?['notes'] ?? {};
          if (sets.isNotEmpty){
            startTime = data['stats']['startTime'];
          }
          stats['startTime'] = startTime;
        });
        repopulateExerciseTypeAccess();
      });
    }else {
      sets = widget.sets['sets'];
      stats['notes'] = widget.sets['stats']?['notes'] ?? {};
      stats['startTime'] = startTime;
      repopulateExerciseTypeAccess();
    }

    if (widget.metaData != null){
      Map metaDataMap = widget.metaData?.toMap() ?? {};
      stats.addAll(metaDataMap);
    }
    _initializeFocusNodesAndControllers();
    loading = false;
  }
  @override
  void dispose() {
    // Dispose of focus nodes and controllers
    for (var exerciseNodes in _focusNodes.values) {
      for (var setNodes in exerciseNodes) {
        setNodes['weight']!.dispose();
        setNodes['reps']!.dispose();
      }
    }
    for (var exerciseControllers in _controllers.values) {
      for (var setControllers in exerciseControllers) {
        setControllers['weight']!.dispose();
        setControllers['reps']!.dispose();
      }
    }
    super.dispose();
  }

  Future<void> repopulateExerciseTypeAccess() async{
    final customExerciseAsync = ref.read(customExercisesProvider);
    for (String exercise in sets.keys){
      String? type = exerciseMuscles[exercise]?['type'];
      if (type == null){
        customExerciseAsync.whenData((data){
          if (data.containsKey(exercise)){
            type = data[exercise]['type'];
          }
        });
      }
      type ??= 'Weighted';
      exerciseTypeAccess[exercise] = type;
    }
  }

  void _initializeFocusNodesAndControllers() {
    for (String exercise in sets.keys) {
      _ensureExerciseFocusNodesAndControllers(exercise);
    }
  }

 void _ensureExerciseFocusNodesAndControllers(String exercise) {
  // First cleanup any old controllers/nodes if exercise no longer exists
  if (!sets.containsKey(exercise)) {
    // Clean up old controllers and nodes
    _focusNodes[exercise]?.forEach((nodeMap) {
      nodeMap['weight']?.dispose();
      nodeMap['reps']?.dispose();
    });
    _controllers[exercise]?.forEach((controllerMap) {
      controllerMap['weight']?.dispose();
      controllerMap['reps']?.dispose();
    });
    _focusNodes.remove(exercise);
    _controllers.remove(exercise);
    _checkBoxStates.remove(exercise);
    return;
  }

  // Initialize if needed
  if (!_focusNodes.containsKey(exercise)) {
    _focusNodes[exercise] = [];
    _controllers[exercise] = [];
    _checkBoxStates[exercise] = [];
  }

  // Now we know exercise exists in sets and all maps
  while (_focusNodes[exercise]!.length < sets[exercise]!.length) {
    final weightFocusNode = FocusNode();
    final repsFocusNode = FocusNode();
    
    // Use weak references to controllers to prevent null access if they're disposed
    final controllerIndex = _focusNodes[exercise]!.length;
    weightFocusNode.addListener(() {
      if (weightFocusNode.hasFocus && 
          _controllers.containsKey(exercise) &&
          _controllers[exercise]!.length > controllerIndex) {
        final controller = _controllers[exercise]![controllerIndex]['weight'];
        if (controller != null) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length
          );
        }
      }
    });

    repsFocusNode.addListener(() {
      if (repsFocusNode.hasFocus && 
          _controllers.containsKey(exercise) &&
          _controllers[exercise]!.length > controllerIndex) {
        final controller = _controllers[exercise]![controllerIndex]['reps'];
        if (controller != null) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length
          );
        }
      }
    });

    _focusNodes[exercise]!.add({
      'weight': weightFocusNode,
      'reps': repsFocusNode,
    });
    _controllers[exercise]!.add({
      'weight': TextEditingController(
        text: sets[exercise]![_focusNodes[exercise]!.length - 1]['weight'].toString()
      ),
      'reps': TextEditingController(
        text: sets[exercise]![_focusNodes[exercise]!.length - 1]['reps'].toString()
      ),
    });
    _checkBoxStates[exercise]!.add(false);
  }
}

  void updateExercises() async{
    if (!widget.editing){
      if (sets.isEmpty){
        ref.read(currentWorkoutProvider.notifier).writeState(<String, dynamic>{});
      } else{
        ref.read(currentWorkoutProvider.notifier).writeState({'stats': stats, 'sets': sets});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customExerciseAsync = ref.read(customExercisesProvider);
    final Map settings = ref.watch(settingsProvider).value ?? {};
    final Map workoutData = ref.watch(workoutDataProvider).value ?? {};
    final Map records = ref.watch(recordsProvider).value ?? {};

    if (loading){
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: myAppBar(context, 'Workout', 
        button: MyIconButton(
          icon: Icons.check,
          width: 37,
          height: 37,
          borderRadius: 10,
          iconHeight: 20,
          iconWidth: 20,
          onTap: () => confirmExercises(sets),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
              itemCount: sets.keys.length,
              itemBuilder: (context, index) {
                String exercise = sets.keys.toList()[index];
                _ensureExerciseFocusNodesAndControllers(exercise);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ExerciseScreen(exercises: [exercise]))
                              );
                            },
                            child: Text(
                              exercise,
                              style: const TextStyle(
                                fontSize: 18
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (['Bodyweight', 'Assisted'].contains(exerciseTypeAccess[exercise]))
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: GestureDetector(
                                  onTap: () async{
                                    await showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return MeasurementPopup(initialMeasurement: settings['Bodyweight'] ?? '0',);
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.person_2_outlined, 
                                    color: Colors.blueAccent
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async{
                                  switch (value){
                                    case 'Swap': 
                                      List? newExerciseList = await Navigator.push(
                                        context,    
                                        MaterialPageRoute(
                                          builder: (context) => const WorkoutList(setting: 'choose', multiSelect: false)
                                        )
                                      );

                                      if (newExerciseList != null && !sets.containsKey(newExerciseList.first)){
                                        String newExercise = newExerciseList.first;
                                        Map newSets = {};
                                        final Map<String, List<Map<String, FocusNode>>> newFocusnodes = {};
                                        final Map<String, List<Map<String, TextEditingController>>> newControllers = {};
                                        final Map<String, List<bool>> newCheckboxstates = {};
                                        for (String exerciseEntry in sets.keys){
                                          newSets[exerciseEntry == exercise ? newExercise : exerciseEntry] = sets[exerciseEntry];
                                          newFocusnodes[exerciseEntry == exercise ? newExercise : exerciseEntry] = _focusNodes[exerciseEntry]!;
                                          newControllers[exerciseEntry == exercise ? newExercise : exerciseEntry] = _controllers[exerciseEntry]!;
                                          newCheckboxstates[exerciseEntry == exercise ? newExercise : exerciseEntry] = _checkBoxStates[exerciseEntry]!;
                                        }
                                        setState(() {
                                          sets = newSets;
                                          _focusNodes = newFocusnodes;
                                          _controllers = newControllers;
                                          _checkBoxStates = newCheckboxstates;
                                          _initializeFocusNodesAndControllers();
                                          updateExercises();
                                        });
                                      }
                                    case 'Delete':
                                      setState(() {
                                        sets.remove(exercise);
                                        _focusNodes.remove(exercise);
                                        _controllers.remove(exercise);
                                        _checkBoxStates.remove(exercise);
                                        updateExercises();
                                      });
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem(value: 'Swap', child: Text('Swap')),
                                    const PopupMenuItem(value: 'Reorder', child: Text('Reorder', style: TextStyle(color: Colors.grey),)),    
                                    const PopupMenuItem(value: 'Delete', child: Text('Delete', style: TextStyle(color: Colors.red),)),
                                  ];
                                },
                                elevation: 2, 
                                child: const Icon(Icons.more_vert, color: Colors.white)
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextFormField(
                        initialValue: stats['notes'][exercise] ?? '',
                        decoration: const InputDecoration(
                          hintText: 'Enter your notes here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          )
                        ),
                        onChanged: (value) {
                          stats['notes'][exercise] = value;
                          updateExercises();
                        },
                      ),
                    ),
                    Table(
                      border: const TableBorder.symmetric(inside: BorderSide.none),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Set'),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Weight (kg)')
                              ),
                            ), 
                            if (exerciseTypeAccess[exercise] != 'Timed')
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Reps')
                              ),
                            ),
                            if (settings['Tick Boxes'] ?? false)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Icon(Icons.check)
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < (sets[exercise]?.length ?? 0); i++)
                        TableRow(
                          decoration: _checkBoxStates[exercise]![i] ? BoxDecoration(color: const Color.fromARGB(255, 111, 223, 36).withAlpha(175)): BoxDecoration(color: i % 2 == 1 ? ThemeColors.bg : ThemeColors.accent),
                          children: [
                            InkWell(
                              onTap: () {
                                _showSetTypeMenu(exercise, i);
                              },
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    sets[exercise]![i]['type'] == 'Warmup'
                                        ? 'W'
                                        : sets[exercise]![i]['type'] == 'Failure'
                                            ? 'F'
                                            : sets[exercise]![i]['type'] == 'Dropset'
                                              ? 'D'
                                              : '${getNormalSetNumber(exercise, i, sets[exercise]!)}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (boxErrors[exercise]?[i]?['weight'] ?? false) ? Colors.redAccent.withValues(alpha: .7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7.5)
                                ),
                                child: Center(
                                  child: (exerciseMuscles[exercise]?['type'] ?? '') != 'Bodyweight' && (exerciseMuscles[exercise]?['type'] ?? '') != 'Timed'? 
                                    TextFormField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                      focusNode: _focusNodes[exercise]![i]['weight'],
                                      controller: _controllers[exercise]![i]['weight'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: sets[exercise][i]['PR'] == 'no' || sets[exercise][i]['PR'] == null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getPrevious(exercise, i+1, 'Weight', sets[exercise][i]['type'], workoutData),
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16, // Adjust hint text size
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (boxErrors[exercise]?[i]['weight'] ?? false){
                                          boxErrors[exercise] ??= {};
                                          boxErrors[exercise][i] ??= {};
                                          boxErrors[exercise][i]['weight'] = false;
                                        }
                                        value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                        sets[exercise]![i]['weight'] = value != 'null' ? value : '';
                                        final result = checkSetPR(exercise, i, records);

                                        applyPRResult(
                                          exercise,
                                          i,
                                          result,
                                          settings,
                                        );  
                                        updateExercises();
                                      },
                                      onFieldSubmitted: (value) {
                                        if (i == sets[exercise]!.length - 1) {
                                          addNewSet(exercise, exerciseTypeAccess[exercise]);
                                        } else {
                                          FocusScope.of(context).requestFocus(_focusNodes[exercise]![i + 1]['weight']);
                                        }
                                      },
                                      onTap: () {
                                        _controllers[exercise]![i]['reps']!.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: _controllers[exercise]![i]['reps']!.text.length,
                                        );
                                      },
                                    ) : exerciseTypeAccess[exercise] == 'Timed' ? 
                                      SizedBox(
                                        height: 50, 
                                        child: TimerScreen(
                                          updateVariable: (int seconds){
                                            String value = seconds.toString();
                                            sets[exercise]![i]['weight'] = value;
                                            final result = checkSetPR(exercise, i, records);

                                            applyPRResult(
                                              exercise,
                                              i,
                                              result,
                                              settings,
                                            );  
                                            updateExercises();
                                          },
                                        )
                                      ) :
                                    const Text(
                                      '-',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 33.5,
                                      ),
                                    )
                                ),
                              ),
                            ),
                            if (exerciseTypeAccess[exercise] != 'Timed')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (boxErrors[exercise]?[i]?['reps'] ?? false) ? Colors.redAccent.withValues(alpha: .7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(7.5)
                                ), 
                                child: Center(
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}')),
                                    ],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    focusNode: _focusNodes[exercise]![i]['reps'],
                                    controller: _controllers[exercise]![i]['reps'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: sets[exercise][i]['PR'] == 'no' || sets[exercise][i]['PR'] == null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: getPrevious(exercise, i+1, 'Reps', sets[exercise][i]['type'], workoutData),
                                      border: InputBorder.none,
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16, // Adjust hint text size
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (boxErrors[exercise]?[i]?['reps'] ?? false){
                                        boxErrors[exercise] ??= {};
                                        boxErrors[exercise][i] ??= {};
                                        boxErrors[exercise][i]['reps'] = false;
                                      }
                                      value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                      sets[exercise]![i]['reps'] = value != 'null' ? value : '';
                                      final result = checkSetPR(exercise, i, records);

                                      applyPRResult(
                                        exercise,
                                        i,
                                        result,
                                        settings,
                                      );  
                                      updateExercises();
                                    },
                                      onFieldSubmitted: (value) {
                                        if (i == sets[exercise]!.length - 1) {
                                          addNewSet(exercise, exerciseTypeAccess[exercise]);
                                        } else {
                                          FocusScope.of(context).requestFocus(_focusNodes[exercise]![i + 1]['reps']);
                                        }
                                    },
                                    onTap: () {
                                      _controllers[exercise]![i]['reps']!.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset: _controllers[exercise]![i]['reps']!.text.length,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (settings['Tick Boxes'] ?? false)
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.green,
                                value: _checkBoxStates[exercise]![i],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _checkBoxStates[exercise]![i] = value!;
                                  });
                                  if (value ?? false){
                                    final result = checkSetPR(exercise, i, records);

                                    applyPRResult(
                                      exercise,
                                      i,
                                      result,
                                      settings,
                                    );                                  
                                  }
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          addNewSet(exercise, exerciseTypeAccess[exercise]);
                        },
                        child: const Text('Add Set'),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to WorkoutList and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutList(setting: 'choose', preData: workoutData),
                  ),
                );

                if (result != null) {
                  for (String exercise in result){
                    if (!sets.containsKey(exercise)) {
                      String? type = exerciseMuscles[exercise]?['type'];
                      if (type == null){
                        customExerciseAsync.whenData((data){
                          if (data.containsKey(exercise)){
                            type = data[exercise]['type'];
                          }
                        });
                      }
                      type ??= 'Weighted';
                      sets[exercise] = [
                        {
                          'weight': type == 'Bodyweight' 
                            ? '1' 
                            : '', 
                          'reps': type == 'Timed' 
                            ? '1' 
                            : '' , 
                          'type': 'Normal'
                        }
                      ]; // Initialize sets list for the new exercise
                      exerciseTypeAccess[exercise] = type;
                    }
                  }
                  updateExercises();
                }
              },
              child: const Text('Select Exercise'),
            ),
          ],
        ),
      ),
    );
  }
  
  String getPrevious(String tExercise, int setNum, String target, String type, Map workoutData){ // TODO this is very expensive, probably cache results
    // TODO with the matching set types, it could be preferential instead of only. like if theres no sets with that index and set type, it just picks the last of that type
    if (workoutData.isNotEmpty){
      for (var day in workoutData.keys.toList().reversed.toList()){
        for (var exercise in workoutData[day]['sets'].keys){
          if (exercise == tExercise){
            for (var i = 0; i < workoutData[day]['sets'][exercise].length; i++) {
              var set = workoutData[day]['sets'][exercise][i];
              if (i == setNum-1 && set['type'] == type) {
                if (target == 'Weight') {
                  return set['weight'].toString();
                } else if (target == 'Reps') {
                  return set['reps'].toString();
                }
              }
            }
          }
        }
      }
    }
    return '0';
  }

  void _showSetTypeMenu(String exercise, int setIndex) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSetTypeOption(exercise, setIndex, 'Warmup', 'W'),
              _buildSetTypeOption(exercise, setIndex, 'Normal', (setIndex + 1).toString()),
              _buildSetTypeOption(exercise, setIndex, 'Failure', 'F'),
              _buildSetTypeOption(exercise, setIndex, 'Dropset', 'D'),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Set', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    if(setIndex == 0 && sets[exercise].length == 1){
                      sets.remove(exercise);
                      _controllers.remove(exercise);
                      _focusNodes.remove(exercise);
                      _checkBoxStates.remove(exercise);
                    } else {
                      sets[exercise]?.removeAt(setIndex);
                      _controllers[exercise]!.removeAt(setIndex);
                      _focusNodes[exercise]!.removeAt(setIndex);
                      _checkBoxStates[exercise]!.removeAt(setIndex);
                    }
                    updateExercises();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildSetTypeOption(String exercise, int setIndex, String type, String display) {
    return ListTile(
      leading: Text(display, style: const TextStyle(fontWeight: FontWeight.bold)),
      title: Text(type),
      onTap: () {
        setState(() {
          sets[exercise]![setIndex]['type'] = type;
        });
        Navigator.pop(context);
      },
    );
  }

void addNewSet(String exercise, String type) {
  setState(() {
    sets[exercise]?.add({'weight':  type == 'Bodyweight' ? '1' : '', 'reps': '', 'type': 'Normal'});
    _ensureExerciseFocusNodesAndControllers(exercise);
  });
  
  // Use a more robust method to set focus
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final lastSetIndex = sets[exercise]!.length - 1;
    FocusNode? focusNodeToUse;

    // Determine which node to focus based on exercise type
    if (type == 'Bodyweight') {
      // For Bodyweight, focus on reps
      focusNodeToUse = _focusNodes[exercise]![lastSetIndex]['reps']!;
    } else if (type == 'Timed') {
      // For timed exercises, this will be handled differently
      return;
    } else {
      // Default to weight node for weighted exercises
      focusNodeToUse = _focusNodes[exercise]![lastSetIndex]['weight']!;
    }
    
    // Ensure the focus node is associated with the widget
    FocusScope.of(context).requestFocus(focusNodeToUse);
    
    // Ensure the text is selected
    final controllerToUse = type== 'Bodyweight'
        ? _controllers[exercise]![lastSetIndex]['reps']!
        : _controllers[exercise]![lastSetIndex]['weight']!;
    
    controllerToUse.selection = TextSelection(
      baseOffset: 0, 
      extentOffset: controllerToUse.text.length
    );
  });
}
  
  void confirmExercises(Map sets) {
    bool isValidWorkout = checkValidWorkout(sets);
    if (isValidWorkout){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmWorkout(
            data: {
              'sets': sets,
              'stats': widget.sets['stats'] ?? stats
            }, 
            editing: widget.editing, 
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('No empty inputs accepted. Please complete all fields.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  bool checkValidWorkout(Map sets){ // could even put this in the save function maybe
    bool isStillValid = true;
    for (String exercise in sets.keys){
      for (int i = 0; i < sets[exercise].length; i++) {
        Map set = sets[exercise][i];
        if (set['reps'] == ''){
          setState(() {
            boxErrors[exercise] ??= {};
            boxErrors[exercise][i] ??= {};
            boxErrors[exercise][i]['reps'] = true;
          });
          isStillValid = false;
        } else if(set['weight'] == ''){
          setState(() {
            boxErrors[exercise] ??= {};
            boxErrors[exercise][i] ??= {};
            boxErrors[exercise][i]['weight'] = true;
          });
          isStillValid = false;
        }
      }
    }
    return isStillValid;
  }

  // ! START RECORDS
  void applyPRResult(
    String exercise,
    int index,
    PRResult result,
    Map settings,
  ) {
    setState(() {
      sets[exercise][index]['PR'] = result.isPR ? 'yes' : 'no';
    });

    if (!result.isPR) return;
    if (settings['Tick Boxes'] ?? false) return;

    String subtitle;
    switch (result.type) {
      case PRType.weight:
        subtitle = "Heaviest Weight - ${sets[exercise][index]['weight']} kg";
        break;
      case PRType.reps:
        subtitle = "Highest Reps - ${sets[exercise][index]['reps']}";
        break;
      case PRType.first:
        subtitle = "First Record!";
        break;
      default:
        return;
    }

    AchievementPopup.show(
      context,
      title: exercise,
      subtitle: subtitle,
      icon: Icons.emoji_events,
    );
  }

  PRResult checkSetPR(String exercise, int index, Map records) {
    final lift = liftFromSet(sets[exercise][index]);
    if (lift == null) return PRResult(false, PRType.none);

    final bestIndex = bestSetIndex(sets[exercise]);
    if (bestIndex != index) return PRResult(false, PRType.none);

    final recordLift = records.containsKey(exercise)
        ? liftFromSet(records[exercise])
        : null;

    return evaluatePR(
      candidate: lift,
      record: recordLift,
    );
  }

  int? bestSetIndex(List sets) {
    int? bestIndex;
    Lift? bestLift;

    for (int i = 0; i < sets.length; i++) {
      final lift = liftFromSet(sets[i]);
      if (lift == null) continue;

      if (bestLift == null || isBetter(lift, bestLift)) {
        bestLift = lift;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  PRResult evaluatePR({
    required Lift candidate,
    Lift? record,
  }) {
    if (record == null) return PRResult(true, PRType.first);

    if (candidate.weight > record.weight) {
      return PRResult(true, PRType.weight);
    }

    if (candidate.weight == record.weight &&
        candidate.reps > record.reps) {
      return PRResult(true, PRType.reps);
    }

    return PRResult(false, PRType.none);
  }
  // !End records
}

class TimerScreen extends StatefulWidget { // TODO cleanup
  final Function(int seconds)? updateVariable;

  const TimerScreen({super.key, this.updateVariable});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool isRunning = false;

  // Start the timer
  void _startTimer() {
    if (_timer != null) return;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });

    setState(() {
      isRunning = true;
    });
  }

  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isRunning = false;
    });
  }

  // Reset the timer
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _seconds = 0;
    });
  }

  // Format seconds into minutes:seconds
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (isRunning) {
                _stopTimer();
              } else {
                _seconds == 0 ? _startTimer() : _resetTimer();
              }
              if (widget.updateVariable != null){
                widget.updateVariable!(_seconds);
              }
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.blue,
              child: Icon(
                isRunning ? Icons.pause : _seconds == 0 ? Icons.play_arrow : Icons.restart_alt_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class AchievementPopup {
  static void show(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    OverlayEntry overlayEntry = _createOverlayEntry(context, title, subtitle, icon);
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 300), () {
      overlayEntry.markNeedsBuild();  // Trigger animation for expansion
    });

    // Remove popup after display duration
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  static OverlayEntry _createOverlayEntry(BuildContext context, String title, String subtitle, IconData icon) {
    return OverlayEntry(
      builder: (context) {
        bool isExpanded = false;

        return Positioned(
          top: 50.0,
          left: MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                Future.delayed(Duration.zero, () {
                  setState(() => isExpanded = true);
                });

                return AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 60,
                    width: isExpanded ? MediaQuery.of(context).size.width * 0.8 : 60,  // Starts small, expands to wide
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),  // Circular shape for initial and expanded view
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.amber, size: 30),
                        AnimatedOpacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}