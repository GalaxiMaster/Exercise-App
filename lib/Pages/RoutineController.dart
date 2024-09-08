import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AddRoutine extends StatefulWidget {
  final Function() onRoutineSaved;
  final String o_name;
  late Map sets;

  AddRoutine({super.key, required this.onRoutineSaved, sets, o_name}) 
    : sets = sets ?? {}, 
      o_name = o_name ?? '';
  @override
  _AddRoutineState createState() => _AddRoutineState();
  }

class _AddRoutineState extends State<AddRoutine> {
  late TextEditingController _routineNameController;
  Map sets = {};
  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController(text: widget.o_name);
    sets = widget.sets.isNotEmpty ? widget.sets['sets'] : {};

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: SizedBox(
            width: 200,
            child: TextField(
              controller: _routineNameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none, // Remove default border
                hintText: 'Enter routine name',
                hintStyle: TextStyle(
                  color: Colors.black45
                )
              ),
            ),
          ),
        ),
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
                createRoutine(_routineNameController.text); // Pass the routine name
              },
            ),
          ),
        ],
        backgroundColor: Colors.white,
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
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
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
    int _getNormalSetNumber(String exercise, int currentIndex) {
    int normalSetCount = 0;
    
    for (int j = 0; j <= currentIndex; j++) {
      if (sets[exercise]![j]['type'] != 'Warmup') {
        normalSetCount++;
      }
    }     

    return normalSetCount;
  }  
  void addNewSet(String exercise) {
    setState(() {
      sets[exercise]?.add({'weight': '', 'reps': '', 'type': 'Normal'});
    });
  }
  
  void createRoutine(String name) {
    debugPrint(name + widget.o_name);
    if (name != ''){
      if (widget.o_name != '' && name != widget.o_name){
        deleteFile('routines/${widget.o_name}');
      }
      Map newData = {
        'data' : {
          'name' : name
        },
        'sets' : sets
      };
      writeData(newData, path: 'routines/$name', append: false);
      widget.onRoutineSaved();          
    }
  }
}