import 'package:exercise_app/Pages/confirm_workout.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'choose_exercise.dart';
import 'package:exercise_app/widgets.dart';

// ignore: must_be_immutable
class Addworkout extends StatefulWidget {
  Map sets;
  final bool confirm;
  Addworkout({super.key, sets, this.confirm = false}) 
    : sets = sets ?? {};
    @override
  // ignore: library_private_types_in_public_api
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  var selectedExercises = [];
  var preCsvData = {};
  Map records = {};
  Map sets = {};
  Map exerciseNotes = {};
  Map settings = {};
  String startTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()).toString();
  final Map<String, List<Map<String, FocusNode>>> _focusNodes = {};
  final Map<String, List<Map<String, TextEditingController>>> _controllers = {};
  final Map<String, List<bool>> _checkBoxStates = {};

  @override
  void initState() {        
    super.initState();
    reloadRecords();
    if(widget.sets.isEmpty){
      getPreviousWorkout().then((data) {
        setState(() {
          sets = data['sets'] ?? {};
          exerciseNotes = data['stats']?['notes'] ?? {};
          if (sets.isNotEmpty){
            startTime = data['stats']['startTime'];
          }
        });
        debugPrint('tessst sets ${sets.toString()}');
      });
    }else {
      sets = widget.sets['sets'];
      exerciseNotes = widget.sets['stats']?['notes'] ?? {};
    }
    preLoad();
    _initializeFocusNodesAndControllers();
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
  void _initializeFocusNodesAndControllers() {
    for (String exercise in sets.keys) {
      _ensureExerciseFocusNodesAndControllers(exercise);
    }
  }

 void _ensureExerciseFocusNodesAndControllers(String exercise) {
    if (!_focusNodes.containsKey(exercise)) {
      _focusNodes[exercise] = [];
      _controllers[exercise] = [];
      _checkBoxStates[exercise] = [];
    }
    while (_focusNodes[exercise]!.length < sets[exercise]!.length) {
      final weightFocusNode = FocusNode();
      final repsFocusNode = FocusNode();
      
      weightFocusNode.addListener(() {
        if (weightFocusNode.hasFocus) {
          _controllers[exercise]![_focusNodes[exercise]!.length - 1]['weight']!.selection = 
              TextSelection(baseOffset: 0, extentOffset: _controllers[exercise]![_focusNodes[exercise]!.length - 1]['weight']!.text.length);
        }
      });
      
      repsFocusNode.addListener(() {
        if (repsFocusNode.hasFocus) {
          _controllers[exercise]![_focusNodes[exercise]!.length - 1]['reps']!.selection = 
              TextSelection(baseOffset: 0, extentOffset: _controllers[exercise]![_focusNodes[exercise]!.length - 1]['reps']!.text.length);
        }
      });

      _focusNodes[exercise]!.add({
        'weight': weightFocusNode,
        'reps': repsFocusNode,
      });
      _controllers[exercise]!.add({
        'weight': TextEditingController(text: sets[exercise]![_focusNodes[exercise]!.length - 1]['weight'].toString()),
        'reps': TextEditingController(text: sets[exercise]![_focusNodes[exercise]!.length - 1]['reps'].toString()),
      });
      _checkBoxStates[exercise]!.add(
        false
      );
    }
  }
  
  void preLoad() async{
    records = await readData(path: 'records');
    Map data = await readData();
    var sortedKeys = data.keys.toList()..sort();
    // Create a sorted map by iterating over sorted keys
    Map<String, dynamic> sortedMap = {
      for (var key in sortedKeys) key: data[key]!,
    };
    data = sortedMap;
    preCsvData = data;
    settings = await getAllSettings();
    setState(() {}); // Update UI after loading data
  }

  Future<Map> getPreviousWorkout() async {
    Map data = {};
    data = await readData(path: 'current');
    debugPrint("${data}data");
    return data;
  }

  void updateExercises() async{
    if (!widget.confirm){
      if (sets.isEmpty){
        resetData(false, true, false);
      }
      writeData({'stats': {'startTime': startTime, 'notes' : exerciseNotes,}, 'sets': sets}, path: 'current', append: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Workout', 
        button: MyIconButton(
          icon: Icons.check,
          width: 37,
          height: 37,
          borderRadius: 10,
          iconHeight: 20,
          iconWidth: 20,
          onTap: () {
            if (!widget.confirm){
              confirmExercises(sets, exerciseNotes);
            } else{
              Navigator.pop(context, sets);
            }
          },
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
                          Text(
                            exercise,
                            style: const TextStyle(
                              fontSize: 18
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                sets.remove(exercise);
                                updateExercises();
                              });
                            },
                            child: const Icon(Icons.delete, color: Colors.red)
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextFormField(
                        initialValue: exerciseNotes[exercise] ?? '',
                        decoration: const InputDecoration(
                          hintText: 'Enter your notes here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          )
                        ),
                        onChanged: (value) {
                          exerciseNotes[exercise] = value;
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
                                              : '${_getNormalSetNumber(exercise, i)}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0), // Reduce vertical padding
                              child: Center(
                                child: (exerciseMuscles[exercise]?['type'] ?? '') != 'bodyweight' ? 
                                  TextFormField(
                                    focusNode: _focusNodes[exercise]![i]['weight'],
                                    controller: _controllers[exercise]![i]['weight'],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: sets[exercise][i]['PR'] == 'no' || sets[exercise][i]['PR'] == null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: getPrevious(exercise, i+1, 'Weight'),
                                      border: InputBorder.none,
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16, // Adjust hint text size
                                      ),
                                    ),
                                    onChanged: (value) {
                                      value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                      sets[exercise]![i]['weight'] = value != 'null' ? value : '';
                                      isRecord(exercise, i);
                                      updateExercises();
                                    },
                                    onFieldSubmitted: (value) {
                                      if (i == sets[exercise]!.length - 1) {
                                        addNewSet(exercise);
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
                                  ) : 
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  )
 
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0), // Reduce vertical padding
                              child: Center(
                                child: TextFormField(
                                  // initialValue: sets[exercise]![i]['reps'].toString(),
                                  focusNode: _focusNodes[exercise]![i]['reps'],
                                  controller: _controllers[exercise]![i]['reps'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: sets[exercise][i]['PR'] == 'no' || sets[exercise][i]['PR'] == null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: getPrevious(exercise, i+1, 'Reps'),
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16, // Adjust hint text size
                                    ),
                                  ),
                                  onChanged: (value) {
                                    value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                    sets[exercise]![i]['reps'] = value != 'null' ? value : '';
                                    isRecord(exercise, i);
                                    updateExercises();
                                  },
                                    onFieldSubmitted: (value) {
                                    addNewSet(exercise); // Add a new set on pressing "Enter"
                                    FocusScope.of(context).nextFocus(); // Move focus to the next field
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
                          addNewSet(exercise);
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
                    builder: (context) => const WorkoutList(setting: 'choose',),
                  ),
                );

                if (result != null) {
                  setState(() {
                    sets[result] = [
                      {'weight': exerciseMuscles[result]['type'] == 'bodyweight' ? '1' : '', 'reps': '', 'type': 'Normal'}
                    ]; // Initialize sets list for the new exercise
                    updateExercises();
                  });
                }
              },
              child: const Text('Select Exercise'),
            ),
          ],
        ),
      ),
    );
  }
  
  String getPrevious(String tExercise, int setNum, String target){
    if (preCsvData.isNotEmpty){
    for (var day in preCsvData.keys.toList()){
        for (var exercise in preCsvData[day]['sets'].keys){
          if (exercise == tExercise){
            for (var i = 0; i < preCsvData[day]['sets'][exercise].length; i++) {
              var set = preCsvData[day]['sets'][exercise][i];
              if (i == setNum-1) {
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

  int _getNormalSetNumber(String exercise, int currentIndex) {
    int normalSetCount = 0;
    
    for (int j = 0; j <= currentIndex; j++) {
      if (sets[exercise]![j]['type'] != 'Warmup') {
        normalSetCount++;
      }
    }     

    return normalSetCount;
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
                  debugPrint(sets[exercise].toString());
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

  void addNewSet(String exercise) {
    setState(() {
      sets[exercise]?.add({'weight':  exerciseMuscles[exercise]['type'] == 'bodyweight' ? '1' : '', 'reps': '', 'type': 'Normal'});
      _ensureExerciseFocusNodesAndControllers(exercise);
    });
    
    // Schedule a callback to set focus after the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_getLastTextFieldFocus(exercise));
    });
  }  
  
  FocusNode _getLastTextFieldFocus(String exercise) {
    final lastSetIndex = sets[exercise]!.length - 1;
    return _focusNodes[exercise]![lastSetIndex]['weight']!;
  }
  
  
  void confirmExercises(var sets, Map exerciseNotes){
    bool isNull = checkNulls(sets);
    if (isNull){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmWorkout(sets: sets, startTime: startTime, exerciseNotes: exerciseNotes,),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('No empty inputs accepted. Please complete all fields.'),
            actions: <Widget>[
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

  bool checkNulls(var sets){ // could even put this in the save function maybe
    for (String exercise in sets?.keys){
      for (var set in sets[exercise]!) {
        debugPrint(set.toString());
        if (set['reps'] == ''){
          return false;
        } else if(set['weight'] == ''){
          return false;
        }
      }
    }
    return true;
  }

  bool isRecord(String exercise, int index) {
    if (sets[exercise][index]['reps'] == '' || sets[exercise][index]['weight'] == ''){ // TODO check if the heaviest set is pr on change
      if (sets[exercise][index]['PR'] == 'yes'){
        setState(() {
          sets[exercise][index]['PR'] = 'no';
        });
      }
      return false;
    }
    List best = [];
    int topindex = -1;
    for (int i = 0; i < sets[exercise].length; i++) {
      var record = sets[exercise][i];
      if (record['reps'] == '' || record['weight'] == '') {
      }
      else if (best.isEmpty){
        best = [double.parse(record['weight']), double.parse(record['reps'])];
        topindex = i;
      }
      else if (double.parse(record['weight']) > best[0] || double.parse(record['weight']) == best[0] && double.parse(record['reps']) > best[1]){
        best = [double.parse(record['weight']), double.parse(record['reps'])];
        topindex = i;
      }
      else {
        if (sets[exercise][index]['PR'] == 'yes'){
          setState(() {
            sets[exercise][index]['PR'] = 'no';
          });
        }
      }
    }
    if (index == topindex){
      printRecords();
      List candidate = [sets[exercise]![index]['weight'], sets[exercise]![index]['reps']]; // TODO move the pr to the most recent set, or highlight both
      if (records.containsKey(exercise)){
        if (double.parse(candidate[0]) > double.parse(records[exercise]['weight']) || double.parse(candidate[0]) == double.parse(records[exercise]['weight']) && double.parse(candidate[1]) > double.parse(records[exercise]['reps'])){
          setState(() {
            sets[exercise][index]['PR'] = 'yes';
          });
          return true;
        }else {
          if (sets[exercise][index]['PR'] == 'yes'){
            setState(() {
              sets[exercise][index]['PR'] = 'no';
            });
          }
        }
      } else{
          setState(() {
            sets[exercise][index]['PR'] = 'yes';
          });
          return true;
      }
      return false;
    }else{
      setState(() {
        if (sets[exercise][index]['PR'] == 'yes'){
          setState(() {
            sets[exercise][index]['PR'] = 'no';
          });
        }
      });
      return false;
    }
  }
  void printRecords() async{
    var data = await readData(path: 'records');
    debugPrint(data.toString());
  }
}
void reloadRecords() async {
  Map data = await readData();
  var sortedKeys = data.keys.toList()..sort();
  Map records = await readData(path: 'records');
  // Create a sorted map by iterating over sorted keys
  Map<String, dynamic> sortedMap = {
    for (var key in sortedKeys) key: data[key]!,
  };
  Map dataCopy = sortedMap;
  data = sortedMap;
  for (String day in data.keys){
    for (String exercise in data[day]['sets'].keys){

      Map topSet = records[exercise] ?? {'weight': 0, 'reps': 0};

      for (int i = 0; i < data[day]['sets'][exercise].length; i++){
        Map set = data[day]['sets'][exercise][i];
        if (double.parse(set['weight'].toString()) > double.parse(topSet['weight'].toString())){
          topSet = set;
          dataCopy[day]['sets'][exercise][i]['PR'] = 'yes';
        }
        else if (double.parse(set['weight'].toString()) == double.parse(topSet['weight'].toString()) && 
                  double.parse(set['reps'].toString()) > double.parse(topSet['reps'].toString()) 
                ){
          topSet = set; 
          dataCopy[day]['sets'][exercise][i]['PR'] = 'yes';

        }
      }
      records[exercise] = topSet;
    }

  }
  debugPrint('yeah');
  writeData(records, path: 'records', append: false);
        // List sets = data[day]['sets'][exercise];
      // sets.sort((a, b) => a["weight"].compareTo(b["weight"])); wild way to get top set, but i need progressive
      // debugPrint('yeah');
}