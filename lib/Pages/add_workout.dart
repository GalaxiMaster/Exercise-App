import 'package:exercise_app/Pages/confirm_workout.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'choose_exercise.dart';
import 'package:exercise_app/widgets.dart';

// ignore: must_be_immutable
class Addworkout extends StatefulWidget {
  Map sets;
  Addworkout({super.key, sets}) 
    : sets = sets ?? {};
    @override
  // ignore: library_private_types_in_public_api
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  var selectedExercises = [];
  var preCsvData = {};
  Map sets = {};
  String startTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()).toString();
  @override
  void initState() {        
    super.initState();
    if(widget.sets.isEmpty){
      getPreviousWorkout().then((data) {
        setState(() {
          sets = data;
        });    
        debugPrint('tessst sets ${sets.toString()}');
      });
    }else {
      sets = widget.sets['sets'];
    }
    loadDataFromCsv(); // Load CSV data once during initialization    
  }

  Future<void> loadDataFromCsv() async {
    preCsvData = await readData();
    debugPrint(preCsvData.toString());
    setState(() {}); // Update UI after loading data
  }

  Future<Map> getPreviousWorkout() async {
    Map data = {};
    data = await readData(path: 'current');
    debugPrint("${data}data");
    return data;
  }

  void updateExercises() async{
    debugPrint('writing');
    debugPrint('sets : ${sets.toString()}');
    debugPrint("${sets}kljdfkljdljgkljdsl");
    writeData(sets, path: 'current', append: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          Center(
            child: MyIconButton(
              filepath: 'Assets/tick.svg',
              width: 37,
              height: 37,
              borderRadius: 10,
              pressedColor: const Color.fromRGBO(163, 163, 163, .7),
              color: const Color.fromARGB(255, 245, 241, 241),
              iconHeight: 20,
              iconWidth: 20,
              onTap: () {
                confirmExercises(sets);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                itemCount: sets.keys.length,
                itemBuilder: (context, index) {
                  String exercise = sets.keys.toList()[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(exercise),
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
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Set'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Weight'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Reps'),
                              ),
                            ],
                          ),
                          for (int i = 0; i < (sets[exercise]?.length ?? 0); i++)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _showSetTypeMenu(exercise, i);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 16), // Adjust vertical padding to increase hitbox
                                    child: Text(
                                      sets[exercise]![i]['type'] == 'Warmup'
                                          ? 'W'
                                          : sets[exercise]![i]['type'] == 'Failure'
                                              ? 'F'
                                              : '${_getNormalSetNumber(exercise, i)}', // Display correct set number
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: sets[exercise]![i]['weight'].toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle( // Add this property
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: getPrevious(exercise, i+1, 'Weight'),
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    )
                                    
                                  ),
                                  onChanged: (value) {
                                    value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                    sets[exercise]![i]['weight'] = value != 'null' ? value : '';
                                    updateExercises();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: sets[exercise]![i]['reps'].toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle( // Add this property
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: getPrevious(exercise, i+1, 'Reps'),
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    )
                                  ),
                                  onChanged: (value) {
                                    value = (int.tryParse(value) ?? double.tryParse(value)).toString();
                                    sets[exercise]![i]['reps'] = value != 'null' ? value : '';  // Safely convert String to int;
                                    updateExercises();
                                  },
                                ),
                              ),
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to WorkoutList and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutList(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    sets[result] = [
                      {'weight': '', 'reps': '', 'type': 'Normal'}
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
                  return set['weight'];
                } else if (target == 'Reps') {
                  return set['reps'];
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
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Set', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    if(setIndex == 0){
                      sets.remove(exercise);
                    } else {
                      sets[exercise]?.removeAt(setIndex);
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
      sets[exercise]?.add({'weight': '', 'reps': '', 'type': 'Normal'});
    });
  }
  
  void confirmExercises(var sets){
    bool isNull = checkNulls(sets);
    if (isNull){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmWorkout(sets: sets, startTime: startTime),
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
    for (String exercise in sets.keys){
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
}