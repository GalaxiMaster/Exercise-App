import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nanoid/nanoid.dart';

class AddRoutine extends ConsumerStatefulWidget {
  final Map sets;

  AddRoutine({super.key, Map? sets}) 
    : sets = sets ?? {};
  @override
  // ignore: library_private_types_in_public_api
  _AddRoutineState createState() => _AddRoutineState();
  }

class _AddRoutineState extends ConsumerState<AddRoutine> {
  late TextEditingController _routineNameController;
  Map sets = {};
  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController(text: widget.sets['data']?['name'] ?? '');
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
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none, // Remove default border
                hintText: 'Enter routine name',
                hintStyle: TextStyle(
                  color: Colors.white54
                )
              ),
            ),
          ),
        ),
        actions: [
          Center(
            child: MyIconButton(
              icon: Icons.check,
              width: 37,
              height: 37,
              borderRadius: 10,
              iconHeight: 20,
              iconWidth: 20,
              onTap: () {
                createRoutine(_routineNameController.text); // Pass the routine name
              },
            ),
          ),
        ],
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
                              });
                            },
                            child: const Icon(Icons.delete, color: Colors.red)
                          ),
                        ],
                      ),
                    ),
                    Table(
                      border: const TableBorder.symmetric(inside: BorderSide.none),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Set'),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Weight (kg)')
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Center(
                                child: Text('Reps')
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < (sets[exercise]?.length ?? 0); i++)
                        TableRow(
                          decoration: BoxDecoration(color: i % 2 == 1 ? ThemeColors.bg : ThemeColors.accent),
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
                                            : '${_getNormalSetNumber(exercise, i)}',
                                    style: const TextStyle(fontSize: 20),
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
                    for (String exercise in result){
                      if (!sets.containsKey(exercise)) {
                        sets[exercise] = [
                          {'weight': exerciseMuscles[exercise]?['type'] == 'Bodyweight' ? '1' : '', 'reps': exerciseMuscles[exercise]?['type'] == 'Timed' ? '1' : '' , 'type': 'Normal'} // TODo fix up to account for cusotm exercises
                        ]; // Initialize sets list for the new exercise
                      }
                    }
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
    if (name != ''){
      // if (widget.o_name != '' && name != widget.o_name){
      //   deleteFile('routines/${widget.o_name}');
      // }
      final String id = widget.sets['data']?['id'] ?? nanoid();
      ref.read(routineDataProvider.notifier).updateValue(
        id, 
        {
          'data' : {
            'name' : name,
          },
          'sets' : sets
        }
      );
      Navigator.pop(context);
    }
  }
}