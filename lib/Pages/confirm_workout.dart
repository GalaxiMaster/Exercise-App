import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ConfirmWorkout extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final sets;
  final String startTime; 
  const ConfirmWorkout({
    super.key,
    required this.sets,
    required this.startTime,
  });

  Map getStats(){
    Map stats = {"Volume" : 0, "Sets" : 0, "Exercises" : 0, "WorkoutTime": ''};
    
    for (var exercise in sets.keys){
      stats['Exercises'] += 1;
      for (var set in sets[exercise]){
        stats['Sets'] += 1;
        stats['Volume'] += (set['weight'] * set['reps']);
      }
    }
    Duration difference = DateTime.now().difference(DateTime.parse(startTime)); // Calculate the difference

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    stats['WorkoutTime'] = "${hours}h ${minutes}m";
    return stats;
  }
  
  @override
  Widget build(BuildContext context) {
    Map stats = getStats();
    List<String> messages = ['Weight lifted:', 'Sets Done:', 'Exercises Done:', 'Workout Time'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Workout'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.0, // Adjust to fit your needs
                ),
                shrinkWrap: true,
                padding: EdgeInsets.zero, // Remove padding around the GridView
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(8.0),
                      margin: EdgeInsets.zero, // Remove margin
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent, // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Keeps the column compact
                        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                        children: [
                          Text(
                            messages[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            stats.keys.elementAt(index) != 'Volume' ? '${stats.values.elementAt(index)}' : '${stats.values.elementAt(index)}kg',
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            //stats
            ElevatedButton( //confirm 
              onPressed: (){
                saveExercises(sets, startTime);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Confirm Workout'),
            ),
          ],
        ),
      ),
    );
  }

  void saveExercises(var exerciseList, String startTime) async {
    debugPrint(exerciseList.toString());
    List<List<dynamic>> rows = [];
    String endTime = DateFormat('YY-MM-dd; HH:mm').format(DateTime.now()).toString();
    // Populate the rows list with exercise data
    for (var exercise in exerciseList.keys) {
      exerciseList[exercise].asMap().forEach((i, set) {
        rows.add([
          startTime,
          endTime,
          exercise,
          '', //notes
          i + 1,
          set['type'],
          set['weight'].toString(),
          set['reps'].toString(),
        ]);
      });
    }

    // Convert rows to CSV format
    String csv = const ListToCsvConverter().convert(rows);

    // Append to CSV only if there's data
    writeToCsv(csv);

    readFromCsv();
    try {// reset current workout
    // Ensure the CSV string ends with a newline

    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path}/currentWorkout.csv';
    final file = File(path);
    // Write or append the CSV data
    await file.writeAsString(
      '',
    );

    debugPrint('CSV reset at: $path');
  } catch (e) {
    debugPrint('Error saving CSV file: $e');
  }
    // try {
    //   final directory = await getExternalStorageDirectory();
    //   final path = '${directory?.path}/output.csv';

    //   // Only share the file after ensuring it has been written
    //   final file = File(path);
    //   if (await file.exists()) {
    //     await Share.shareXFiles(
    //       [XFile(path)],
    //       text: 'Check out this CSV file!',
    //     );
    //   } else {
    //     debugPrint('Error: CSV file does not exist for sharing');
    //   }
    // } catch (e) {
    //   debugPrint('Error sharing CSV file: $e');
    // }
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

