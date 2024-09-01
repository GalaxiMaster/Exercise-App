import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'workout_list.dart'; // Ensure the path to your WorkoutList file is correct
import 'package:exercise_app/widgets.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';


class Addworkout extends StatefulWidget {
  @override
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  var selectedExercises = [];
  
  Map<String, List<Map<String, dynamic>>> sets = {};

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
              pressedColor: Color.fromRGBO(163, 163, 163, .7),
              color: Color.fromARGB(255, 245, 241, 241),
              iconHeight: 20,
              iconWidth: 20,
              onTap:(){
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
                          3: FlexColumnWidth(3),
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
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Type'),
                              ),
                            ],
                          ),
                          for (int i = 0; i < (sets[exercise]?.length ?? 0); i++)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${i + 1}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: sets[exercise]![i]['weight'],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      border: InputBorder.none,
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
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      sets[exercise]![i]['reps'] = value;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: sets[exercise]![i]['type'],
                                    items: ['Warmup', 'Normal', 'Failure']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      sets[exercise]![i]['type'] = newValue;
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                    builder: (context) => WorkoutList(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    selectedExercises.add(result);
                    sets[result] = [{'weight': '', 'reps': '', 'type': 'Normal'}]; // Initialize sets list for the new exercise
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

  void addNewSet(String exercise) {
    setState(() {
      sets[exercise]?.add({'weight': '', 'reps': '', 'type': 'Normal'});
    });
  }
}
  
void saveExercises(var exerciseList) async{
  debugPrint(exerciseList.toString());
    List<List<dynamic>> rows = [
  ["exercise", "weight", "reps", "volume"],
  ];
  for (var exercise in exerciseList.keys){
    for (var set in exerciseList[exercise]){
      rows.add([exercise, set['weight'].toString(), set['reps'].toString(), (num.tryParse(set['weight'])! * num.tryParse(set['reps'])!).toString()]);
    }
  }
  String csv = const ListToCsvConverter().convert(rows);
  final dir = await getExternalStorageDirectory();
  writeToCsv(csv, dir);

  readFromCsv(dir);
try {
    // final directory = await getExternalStorageDirectory();
    // debugPrint(directory?.path);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/output.csv';
    debugPrint(path);
    final file = File(path);
    await file.writeAsString(csv);

    // Share the file using shareXFiles
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Check out this CSV file!',
    );
  } catch (e) {
    print('Error sharing CSV file: $e');
  }

}

void writeToCsv(var csv, final directory) async{
  try {
    final path = '${directory.path}/output.csv';

    final file = File(path);
    await file.writeAsString(csv);

    debugPrint('CSV file saved at: $path');
  } catch (e) {
    debugPrint('Error saving CSV file: $e');
  }
}

void readFromCsv(final directory) async{
  try{
    final path = '${directory.path}/output.csv';

    // Read the CSV file
    final file = File(path);
    final csvString = await file.readAsString();

    // Parse the CSV content
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

    // Print the data or use it as needed
    debugPrint('CSV Datas: $csvData');
  } catch (e) {
    debugPrint('Error reading CSV file: $e');
  }
}