import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ConfirmWorkout extends StatelessWidget {
  final sets;
  const ConfirmWorkout({
    super.key,
    required this.sets,
  });
  Map getStats(){
    Map stats = {"Volume" : 0, "Sets" : 0, "Exercises" : 0};

    for (var exercise in sets.keys){
      stats['Exercises'] += 1;
      for (var set in sets[exercise]){
        stats['Sets'] += 1;
        stats['Volume'] += (num.tryParse(set['weight'])! * num.tryParse(set['reps'])!);
      }
    }
    return stats;
  }
  
  @override
  Widget build(BuildContext context) {
    Map stats = getStats();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Workout'),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: stats.keys.length,
              itemBuilder: (context, index) {
                return Text(
                  '${stats.keys.elementAt(index)}: ${stats.values.elementAt(index)}'
                );
              }
            ),
            //stats
            ElevatedButton( //confirm 
              onPressed: (){
                saveExercises(sets);
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

