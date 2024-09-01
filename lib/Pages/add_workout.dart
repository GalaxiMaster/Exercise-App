import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'workout_list.dart'; // Ensure the path to your WorkoutList file is correct
import 'package:exercise_app/widgets.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class Addworkout extends StatefulWidget {
  const Addworkout({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  var selectedExercises = [];
  Map<String, List<Map<String, dynamic>>> sets = {};
  var pre_csvData = [];
  @override
  void initState() {
    super.initState();
    loadDataFromCsv(); // Load CSV data once during initialization
  }
  Future<void> loadDataFromCsv() async {
    pre_csvData = await readFromCsv();
    debugPrint(pre_csvData.toString());
    debugPrint("##############");
    setState(() {}); // Update UI after loading data
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
                saveExercises(sets);
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
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  String exercise = selectedExercises[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
                    children: [
                      Text(exercise),
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
                                  initialValue: sets[exercise]![i]['weight'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '${getPrevious(exercise, i+1, 'Weight').toString()}',
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    )
                                  ),
                                  onChanged: (value) {
                                    sets[exercise]![i]['weight'] = value;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: sets[exercise]![i]['reps'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '${getPrevious(exercise, i+1, 'Reps')}',
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    )
                                  ),
                                  onChanged: (value) {
                                    sets[exercise]![i]['reps'] = value;
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
                    selectedExercises.add(result);
                    sets[result] = [
                      {'weight': '', 'reps': '', 'type': 'Normal'}
                    ]; // Initialize sets list for the new exercise
                    // debugPrint(selectedExercises.toString());
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
  String getPrevious(String exercise, int setNum, String target){
    for (var set in pre_csvData){
      if (set[0].toString() == exercise && set[1].toString() == setNum.toString()){
        if (target == 'Reps'){
          return set[3].toString();
        } else if(target == "Weight"){
          return set[2].toString();
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
                    sets[exercise]?.removeAt(setIndex);
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

void saveExercises(var exerciseList) async {
  debugPrint(exerciseList.toString());
  List<List<dynamic>> rows = [];

  // Populate the rows list with exercise data
  for (var exercise in exerciseList.keys) {
    exerciseList[exercise].asMap().forEach((i, set) {
      rows.add([
        exercise,
        i + 1,
        set['weight'].toString(),
        set['reps'].toString(),
        (num.tryParse(set['weight'])! * num.tryParse(set['reps'])!).toString()
      ]);
    });
  }

  // Convert rows to CSV format
  String csv = const ListToCsvConverter().convert(rows);

  // Append to CSV only if there's data
  writeToCsv(csv);

  readFromCsv();

  try {
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/output.csv';
    // debugPrint(path);

    // Only share the file after ensuring it has been written
    final file = File(path);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Check out this CSV file!',
      );
    } else {
      debugPrint('Error: CSV file does not exist for sharing');
    }
  } catch (e) {
    debugPrint('Error sharing CSV file: $e');
  }
}

Future<void> writeToCsv(String csv) async {
  try {
    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path}/output.csv';
    final file = File(path);

    // Read existing content if it exists
    String existingContent = '';
    if (await file.exists()) {
      existingContent = await file.readAsString();
    }
    // Write new content and then append existing content
    await file.writeAsString(
      '$csv\n$existingContent',
      mode: FileMode.write, // Overwrite mode
    );

    debugPrint('CSV file saved at: $path');
  } catch (e) {
    debugPrint('Error saving CSV file: $e');
  }
}


Future<List<List<dynamic>>> readFromCsv() async {
  List<List<dynamic>> csvData = [];
  debugPrint('****************************************************************************************');
  try {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final path = '${dir.path}/output.csv';
      final file = File(path);

      // Check if the file exists before attempting to read it
      if (await file.exists()) {
        final csvString = await file.readAsString();
        const converter = CsvToListConverter(
          fieldDelimiter: ',', // Default
          eol: '\n',           // End-of-line character
        );

        List<List<dynamic>> csvData = converter.convert(csvString);
        debugPrint('CSV Data: $csvData');
        return csvData;
      } else {
        debugPrint('Error: CSV file does not exist');
      }
    } else {
      debugPrint('Error: External storage directory is null');
    }
  } catch (e) {
    debugPrint('Error reading CSV file: $e');
  }
  debugPrint("balls");
  return csvData;
}


}
