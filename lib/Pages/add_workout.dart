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
import 'choose_exercise.dart';

class AddWorkout extends ConsumerStatefulWidget {
  final Map initialSets;
  final bool editing;
  final WorkoutMetaData? metaData;

  const AddWorkout({
    super.key,
    Map? sets,
    this.editing = false,
    this.metaData,
  }) : initialSets = sets ?? const {};

  @override
  AddWorkoutState createState() => AddWorkoutState();
}

class AddWorkoutState extends ConsumerState<AddWorkout> {
  Map sets = {};
  Map stats = {};
  String startTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  Map<String, List<Map<String, FocusNode>>> _focusNodes = {};
  Map<String, List<Map<String, TextEditingController>>> _controllers = {};
  Map<String, List<bool>> _checkBoxStates = {};
  Map exerciseTypeAccess = {};
  Map boxErrors = {};

  final Map<String, String> _previousCache = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    stats['notes'] = widget.initialSets['stats']?['notes'] ?? {};

    if (widget.initialSets.isEmpty) {
      ref.read(currentWorkoutProvider).whenData((data) {
        setState(() {
          sets = data['sets'] ?? {};
          stats['notes'] = data['stats']?['notes'] ?? {};
          startTime = data['stats']?['startTime'] ?? startTime;
          stats['startTime'] = startTime;
          repopulateExerciseTypeAccess();
          _initializeFocusNodesAndControllers();
          loading = false;
        });
      });
    } else {
      sets = widget.initialSets['sets'];
      stats['startTime'] = startTime;
      repopulateExerciseTypeAccess();
      _initializeFocusNodesAndControllers();
      loading = false;
    }

    if (widget.metaData != null) {
      stats.addAll(widget.metaData!.toMap());
    }
  }

  @override
  void dispose() {
    for (final exerciseNodes in _focusNodes.values) {
      for (final setNodes in exerciseNodes) {
        setNodes['weight']!.dispose();
        setNodes['reps']!.dispose();
      }
    }
    for (final exerciseControllers in _controllers.values) {
      for (final setControllers in exerciseControllers) {
        setControllers['weight']!.dispose();
        setControllers['reps']!.dispose();
      }
    }
    super.dispose();
  }


  void repopulateExerciseTypeAccess() {
    final customExercises = ref.read(customExercisesProvider).value ?? {};
    for (final exercise in sets.keys) {
      final type = exerciseMuscles[exercise]?['type']
          ?? customExercises[exercise]?['type']
          ?? 'Weighted';
      exerciseTypeAccess[exercise] = type;
    }
  }

  void _initializeFocusNodesAndControllers() {
    for (final exercise in sets.keys) {
      _ensureExerciseFocusNodesAndControllers(exercise);
    }
  }

  void _ensureExerciseFocusNodesAndControllers(String exercise) {
    if (!sets.containsKey(exercise)) {
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

    if (!_focusNodes.containsKey(exercise)) {
      _focusNodes[exercise] = [];
      _controllers[exercise] = [];
      _checkBoxStates[exercise] = [];
    }

    while (_focusNodes[exercise]!.length < sets[exercise]!.length) {
      final controllerIndex = _focusNodes[exercise]!.length;
      final weightFocusNode = FocusNode();
      final repsFocusNode = FocusNode();

      weightFocusNode.addListener(() {
        if (weightFocusNode.hasFocus &&
            _controllers.containsKey(exercise) &&
            _controllers[exercise]!.length > controllerIndex) {
          final controller = _controllers[exercise]![controllerIndex]['weight'];
          controller?.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      });

      repsFocusNode.addListener(() {
        if (repsFocusNode.hasFocus &&
            _controllers.containsKey(exercise) &&
            _controllers[exercise]!.length > controllerIndex) {
          final controller = _controllers[exercise]![controllerIndex]['reps'];
          controller?.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      });

      _focusNodes[exercise]!.add({'weight': weightFocusNode, 'reps': repsFocusNode});
      _controllers[exercise]!.add({
        'weight': TextEditingController(
          text: sets[exercise]![controllerIndex]['weight'].toString(),
        ),
        'reps': TextEditingController(
          text: sets[exercise]![controllerIndex]['reps'].toString(),
        ),
      });
      _checkBoxStates[exercise]!.add(false);
    }
  }

  void updateExercises() {
    if (!widget.editing) {
      if (sets.isEmpty) {
        ref.read(currentWorkoutProvider.notifier).writeState(<String, dynamic>{});
      } else {
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

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: myAppBar(
        context,
        'Workout',
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sets.keys.length,
              itemBuilder: (context, index) {
                final exercise = sets.keys.toList()[index];
                _ensureExerciseFocusNodesAndControllers(exercise);
                return _buildExerciseCard(
                  exercise,
                  settings,
                  records,
                  workoutData,
                  customExerciseAsync,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutList(setting: 'choose', preData: workoutData),
                  ),
                );

                if (result != null) {
                  final customExercises = customExerciseAsync.value ?? {};
                  for (final exercise in result) {
                    if (!sets.containsKey(exercise)) {
                      final type = exerciseMuscles[exercise]?['type']
                          ?? customExercises[exercise]?['type']
                          ?? 'Weighted';
                      sets[exercise] = [
                        {
                          'weight': type == 'Bodyweight' ? '1' : '',
                          'reps': type == 'Timed' ? '1' : '',
                          'type': 'Normal',
                        }
                      ];
                      exerciseTypeAccess[exercise] = type;
                    }
                  }
                  setState(() {});
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

  Widget _buildExerciseCard(
    String exercise,
    Map settings,
    Map records,
    Map workoutData,
    AsyncValue customExerciseAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseScreen(exercises: [exercise]),
                    ),
                  );
                },
                child: Text(
                  exercise,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Row(
                children: [
                  if (['Bodyweight', 'Assisted'].contains(exerciseTypeAccess[exercise]))
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            builder: (context) => MeasurementPopup(
                              initialMeasurement: settings['Bodyweight'] ?? '0',
                            ),
                          );
                        },
                        child: const Icon(Icons.person_2_outlined, color: Colors.blueAccent),
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'Swap':
                          final newExerciseList = await Navigator.push<List>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkoutList(setting: 'choose', multiSelect: false),
                            ),
                          );
                          if (newExerciseList != null &&
                              !sets.containsKey(newExerciseList.first)) {
                            final newExercise = newExerciseList.first as String;
                            final Map newSets = {};
                            final Map<String, List<Map<String, FocusNode>>> newFocusNodes = {};
                            final Map<String, List<Map<String, TextEditingController>>>
                                newControllers = {};
                            final Map<String, List<bool>> newCheckBoxStates = {};

                            for (final entry in sets.keys) {
                              final key = entry == exercise ? newExercise : entry;
                              newSets[key] = sets[entry];
                              newFocusNodes[key] = _focusNodes[entry]!;
                              newControllers[key] = _controllers[entry]!;
                              newCheckBoxStates[key] = _checkBoxStates[entry]!;
                            }

                            setState(() {
                              sets = newSets;
                              _focusNodes = newFocusNodes;
                              _controllers = newControllers;
                              _checkBoxStates = newCheckBoxStates;
                              _initializeFocusNodesAndControllers();
                            });
                            updateExercises();
                          }
                        case 'Delete':
                          setState(() {
                            sets.remove(exercise);
                            _focusNodes.remove(exercise);
                            _controllers.remove(exercise);
                            _checkBoxStates.remove(exercise);
                          });
                          updateExercises();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'Swap', child: Text('Swap')),
                      const PopupMenuItem(
                        value: 'Reorder',
                        child: Text('Reorder', style: TextStyle(color: Colors.grey)),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    elevation: 2,
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Notes field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            initialValue: stats['notes']?[exercise] ?? '',
            decoration: const InputDecoration(
              hintText: 'Enter your notes here...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            onChanged: (value) {
              stats['notes'][exercise] = value;
              updateExercises();
            },
          ),
        ),

        // Sets table
        Column(
          children: [
            _buildSetTableHeader(settings),
            for (int i = 0; i < (sets[exercise]?.length ?? 0); i++)
              _buildSetRow(exercise, i, settings, records, workoutData),
          ],
        ),

        // Add set button
        Center(
          child: ElevatedButton(
            onPressed: () => addNewSet(exercise, exerciseTypeAccess[exercise] as String),
            child: const Text('Add Set'),
          ),
        ),
      ],
    );
  }

  Widget _buildSetTableHeader(Map settings) {
    return Row(
      children: [
        const Expanded(flex: 1, child: Center(child: Text('Set'))),
        const Expanded(flex: 2, child: Center(child: Text('Weight (kg)'))),
        const Expanded(flex: 2, child: Center(child: Text('Reps'))),
        if (settings['Tick Boxes'] ?? false)
          const Expanded(flex: 1, child: Center(child: Icon(Icons.check))),
      ],
    );
  }

  Widget _buildSetRow(
    String exercise,
    int i,
    Map settings,
    Map records,
    Map workoutData,
  ) {
    return SwipeDismissable(
      key: ValueKey('$exercise-$i'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          addNewSet(exercise, 'Bodyweight', data: sets[exercise][i]);
        } else {
          removeSet(exercise, i);
        }
        return false;
      },
      maxSwipeFraction: 0.2,
      background: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Icon(Icons.repeat, color: Colors.teal),
          ),
          Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      child: Container(
        color: _checkBoxStates[exercise]![i]
            ? const Color.fromARGB(255, 111, 223, 36).withAlpha(175)
            : (i.isOdd ? ThemeColors.bg : ThemeColors.accent),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showSetTypeMenu(exercise, i),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      _setLabel(exercise, i),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),

            _buildWeightCell(exercise, i, settings, records, workoutData),

            if (exerciseTypeAccess[exercise] != 'Timed')
              _buildRepsCell(exercise, i, settings, records, workoutData),

            if (settings['Tick Boxes'] ?? false)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    value: _checkBoxStates[exercise]![i],
                    onChanged: (bool? value) {
                      setState(() {
                        _checkBoxStates[exercise]![i] = value!;
                      });
                      if (value ?? false) {
                        applyPRResult(
                          exercise,
                          i,
                          checkSetPR(exercise, i, records),
                          settings,
                        );
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _setLabel(String exercise, int i) {
    return switch (sets[exercise]![i]['type']) {
      'Warmup'  => 'W',
      'Failure' => 'F',
      'Dropset' => 'D',
      _         => '${getNormalSetNumber(exercise, i, sets[exercise]!)}',
    };
  }

  Widget _buildWeightCell(
    String exercise,
    int i,
    Map settings,
    Map records,
    Map workoutData,
  ) {
    final hasError = boxErrors[exercise]?[i]?['weight'] ?? false;

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: hasError ? Colors.redAccent.withValues(alpha: .7) : Colors.transparent,
            borderRadius: BorderRadius.circular(7.5),
          ),
          child: Center(
            child: _buildWeightInput(exercise, i, settings, records, workoutData),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightInput(
    String exercise,
    int i,
    Map settings,
    Map records,
    Map workoutData,
  ) {
    final type = exerciseTypeAccess[exercise] as String? ?? 'Weighted';
    final isPR = sets[exercise][i]['PR'] != 'no' && sets[exercise][i]['PR'] != null;

    if (type == 'Bodyweight') {
      return const Text('-', style: TextStyle(color: Colors.white, fontSize: 33.5));
    }

    if (type == 'Timed') {
      return SizedBox(
        height: 50,
        child: TimerScreen(
          updateVariable: (int seconds) {
            sets[exercise]![i]['weight'] = seconds.toString();
            applyPRResult(exercise, i, checkSetPR(exercise, i, records), settings);
            updateExercises();
          },
        ),
      );
    }

    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      focusNode: _focusNodes[exercise]![i]['weight'],
      controller: _controllers[exercise]![i]['weight'],
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: isPR
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: getPrevious(exercise, i + 1, 'Weight', sets[exercise][i]['type'], workoutData),
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
      onChanged: (value) {
        if (boxErrors[exercise]?[i]?['weight'] ?? false) {
          boxErrors[exercise] ??= {};
          boxErrors[exercise][i] ??= {};
          boxErrors[exercise][i]['weight'] = false;
        }
        final parsed = int.tryParse(value) ?? double.tryParse(value);
        sets[exercise]![i]['weight'] = parsed != null ? parsed.toString() : '';
        applyPRResult(exercise, i, checkSetPR(exercise, i, records), settings);
        updateExercises();
      },
      onFieldSubmitted: (_) {
        if (i == sets[exercise]!.length - 1) {
          addNewSet(exercise, type);
        } else {
          FocusScope.of(context).requestFocus(_focusNodes[exercise]![i + 1]['weight']);
        }
      },
      // FIX: was incorrectly selecting the reps controller
      onTap: () {
        final controller = _controllers[exercise]![i]['weight']!;
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
    );
  }

  Widget _buildRepsCell(
    String exercise,
    int i,
    Map settings,
    Map records,
    Map workoutData,
  ) {
    final hasError = boxErrors[exercise]?[i]?['reps'] ?? false;
    final isPR = sets[exercise][i]['PR'] != 'no' && sets[exercise][i]['PR'] != null;
    final type = exerciseTypeAccess[exercise] as String? ?? 'Weighted';

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: hasError ? Colors.redAccent.withValues(alpha: .7) : Colors.transparent,
            borderRadius: BorderRadius.circular(7.5),
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
                color: isPR
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: getPrevious(exercise, i + 1, 'Reps', sets[exercise][i]['type'], workoutData),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              onChanged: (value) {
                if (boxErrors[exercise]?[i]?['reps'] ?? false) {
                  boxErrors[exercise] ??= {};
                  boxErrors[exercise][i] ??= {};
                  boxErrors[exercise][i]['reps'] = false;
                }
                final parsed = int.tryParse(value) ?? double.tryParse(value);
                sets[exercise]![i]['reps'] = parsed != null ? parsed.toString() : '';
                applyPRResult(exercise, i, checkSetPR(exercise, i, records), settings);
                updateExercises();
              },
              onFieldSubmitted: (_) {
                if (i == sets[exercise]!.length - 1) {
                  addNewSet(exercise, type);
                } else {
                  FocusScope.of(context).requestFocus(_focusNodes[exercise]![i + 1]['reps']);
                }
              },
              onTap: () {
                final controller = _controllers[exercise]![i]['reps']!;
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
            ),
          ),
        ),
      ),
    );
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
                  removeSet(exercise, setIndex);
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

  // -------------------------------------------------------------------------
  // Add / remove sets
  // -------------------------------------------------------------------------

  void addNewSet(String exercise, String type, {Map<String, String>? data}) {
    try {
      setState(() {
        sets[exercise]?.add({
          'weight': type == 'Bodyweight' ? '1' : '',
          'reps': '',
          'type': 'Normal',
          ...data ?? {},
        });
        _ensureExerciseFocusNodesAndControllers(exercise);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastIndex = sets[exercise]!.length - 1;

      if (type == 'Timed') return;

      final focusNode = type == 'Bodyweight'
          ? _focusNodes[exercise]![lastIndex]['reps']!
          : _focusNodes[exercise]![lastIndex]['weight']!;

      final controller = type == 'Bodyweight'
          ? _controllers[exercise]![lastIndex]['reps']!
          : _controllers[exercise]![lastIndex]['weight']!;

      FocusScope.of(context).requestFocus(focusNode);
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  }

  void removeSet(String exercise, int setIndex) {
    setState(() {
      if (setIndex == 0 && sets[exercise].length == 1) {
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
    });
    updateExercises();
  }

  void confirmExercises(Map sets) {
    if (checkValidWorkout(sets)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmWorkout(
            data: {
              'sets': sets,
              'stats': widget.initialSets['stats'] ?? stats,
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  bool checkValidWorkout(Map sets) {
    bool isValid = true;
    for (final exercise in sets.keys) {
      for (int i = 0; i < sets[exercise].length; i++) {
        final set = sets[exercise][i];

        if (set['reps'] == '') {
          setState(() {
            boxErrors[exercise] ??= {};
            boxErrors[exercise][i] ??= {};
            boxErrors[exercise][i]['reps'] = true;
          });
          isValid = false;
        }

        if (set['weight'] == '') {
          setState(() {
            boxErrors[exercise] ??= {};
            boxErrors[exercise][i] ??= {};
            boxErrors[exercise][i]['weight'] = true;
          });
          isValid = false;
        }
      }
    }
    return isValid;
  }

  String getPrevious(
    String exercise,
    int setNum,
    String target,
    String type,
    Map workoutData,
  ) {
    final cacheKey = '$exercise|$setNum|$target|$type';
    if (_previousCache.containsKey(cacheKey)) return _previousCache[cacheKey]!;

    if (workoutData.isNotEmpty) {
      for (final day in workoutData.keys.toList().reversed) {
        final exerciseSets = workoutData[day]['sets'];
        if (!exerciseSets.containsKey(exercise)) continue;
        final exSets = exerciseSets[exercise] as List;
        if (setNum - 1 < exSets.length) {
          final set = exSets[setNum - 1];
          if (set['type'] == type) {
            final result = target == 'Weight'
                ? set['weight'].toString()
                : set['reps'].toString();
            _previousCache[cacheKey] = result;
            return result;
          }
        }
      }
    }

    _previousCache[cacheKey] = '0';
    return '0';
  }

  void applyPRResult(String exercise, int index, PRResult result, Map settings) {
    setState(() {
      sets[exercise][index]['PR'] = result.isPR ? 'yes' : 'no';
    });

    if (!result.isPR) return;
    if (settings['Tick Boxes'] ?? false) return;

    final String subtitle = switch (result.type) {
      PRType.weight => 'Heaviest Weight - ${sets[exercise][index]['weight']} kg',
      PRType.reps   => 'Highest Reps - ${sets[exercise][index]['reps']}',
      PRType.first  => 'First Record!',
      _             => '',
    };

    if (subtitle.isEmpty) return;

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

    final recordLift = records.containsKey(exercise) ? liftFromSet(records[exercise]) : null;

    return evaluatePR(candidate: lift, record: recordLift);
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

  PRResult evaluatePR({required Lift candidate, Lift? record}) {
    if (record == null) return PRResult(true, PRType.first);
    if (candidate.weight > record.weight) return PRResult(true, PRType.weight);
    if (candidate.weight == record.weight && candidate.reps > record.reps) {
      return PRResult(true, PRType.reps);
    }
    return PRResult(false, PRType.none);
  }
}

// ---------------------------------------------------------------------------
// TimerScreen
// ---------------------------------------------------------------------------

class TimerScreen extends StatefulWidget {
  final Function(int seconds)? updateVariable;

  const TimerScreen({super.key, this.updateVariable});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() { isRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() { _seconds++; });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() { isRunning = false; });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isRunning = false;
      _seconds = 0;
    });
  }

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
              widget.updateVariable?.call(_seconds);
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.blue,
              child: Icon(
                isRunning
                    ? Icons.pause
                    : _seconds == 0
                        ? Icons.play_arrow
                        : Icons.restart_alt_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
        ],
      ),
    );
  }
}


class AchievementPopup {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final overlayEntry = _createOverlayEntry(context, title, subtitle, icon);
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
  }

  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50.0,
          left: MediaQuery.of(context).size.width * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                bool isExpanded = false;

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
                    width: isExpanded ? MediaQuery.of(context).size.width * 0.8 : 60,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(30),
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