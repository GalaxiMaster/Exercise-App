import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/encryption_controller.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ImportingPage extends ConsumerStatefulWidget {
  const ImportingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportingPageState createState() => _ImportingPageState();
}

class _ImportingPageState extends ConsumerState<ImportingPage> {
  List<DateTime> highlightedDays = [];
  Map exerciseData = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Importing'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingsHeader('Import Workout Data', context),
          buildSettingsTile(context, icon: Icons.import_contacts, label: 'Import from This', function: (){importDataThis(context, ref);}),
          buildSettingsTile(context, icon: Icons.import_contacts, label: 'Import from Hevy', function: (){importDataHevy(context);}),
          buildSettingsTile(context, icon: Icons.import_contacts, label: 'Import from Strong', function: (){importDataStrong(context);}),
          // settingsHeader('Import Routines', context),
          // buildSettingsTile(context, icon: Icons.import_contacts, label: 'Import routines', function: (){importDataStrong(context);}),

        ],
      ),
    );
  }
}

void importDataThis(BuildContext context, WidgetRef ref) async{
  try {
    // Open file picker and allow the user to select a JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Restrict to custom types
      allowedExtensions: ['json'], // Only allow .json files
    );
    
    if (result != null && result.files.isNotEmpty) {
      // Get the file path
      String? filePath = result.files.single.path;

      // Read the content of the file
      if (filePath == null) return; // TODO clean slightly and add  validation

      File file = File(filePath);
      String content = await file.readAsString();

      // Parse the JSON content
      Map<String, dynamic> jsonData = jsonDecode(content);
      // writeData({}, append: false);
      for (String key in jsonData.keys){
        writeData(jsonData[key], append: true, path: key);
      }
      ref.invalidate(workoutDataProvider);

      // Map data = await readData();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Data written'),
            content: Text(jsonData.toString()),
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
      syncData();
      // Do something with the parsed JSON data
      debugPrint("Parsed JSON data: $jsonData");
        } else {
      debugPrint("User canceled the picker");
    }
  } catch (e) {
    debugPrint("Error picking or reading file: $e");
  }
  }

void importDataHevy(BuildContext context) async{
  try {
    // Open file picker and allow the user to select a JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['csv', 'CSV'],
      allowMultiple: false, // Add this if you only want single file selection
    );
    
    if (result != null && result.files.isNotEmpty && ['csv', 'CSV'].contains(result.files.single.extension)) {
      // Get the file path
      String? filePath = result.files.single.path;

      // Read the content of the file
                if (filePath == null) return; // TODO clean slightly

      final file = File(filePath).openRead();

      List jsonData = await file
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(const LineSplitter()) // Convert stream to individual lines.
          .map((line) => const CsvToListConverter().convert(line)) // Convert each line to a list.
          .toList();
      Map records = await readData(path: 'records');
      Map<String, dynamic> data = formatHevyData(jsonData, records);
      // writeData({}, append: false);
      writeData(data, append: true);
      // Map data = await readData();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Data written'),
            content: Text(data.toString()),
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
      syncData();
      // Do something with the parsed JSON data
      debugPrint("Parsed JSON data: $data");
        } else {
      debugPrint("User canceled the picker");
    }
  } catch (e) {
    debugPrint("Error picking or reading file: $e");
  }
}
void importDataStrong(BuildContext context) async{
  try {
    // Open file picker and allow the user to select a JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['csv', 'CSV'],
      allowMultiple: false, // Add this if you only want single file selection
    );
    
    if (result != null && result.files.isNotEmpty && ['csv', 'CSV'].contains(result.files.single.extension)) {
      // Get the file path
      String? filePath = result.files.single.path;

      // Read the content of the file
      if (filePath == null) return; // TODO clean slightly

      final file = File(filePath).openRead();

      List jsonData = await file
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(const LineSplitter()) // Convert stream to individual lines.
          .map((line) => const CsvToListConverter(fieldDelimiter: ';').convert(line)) // Convert each line to a list.
          .toList();
      Map records = await readData(path: 'records');
      Map<String, dynamic> data = formatStrongData(jsonData, records);
      // writeData({}, append: false);
      writeData(data, append: true);
      // Map data = await readData();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Data written'),
            content: Text(data.toString()),
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
      syncData();
      // Do something with the parsed JSON data
      debugPrint("Parsed JSON data: $data");
        } else {
      debugPrint("User canceled the picker");
    }
  } catch (e) {
    debugPrint("Error picking or reading file: $e");
  }
}
Map<String, dynamic> formatStrongData(List data, Map records){
  Map<String, dynamic> formattedData = {};
  Map dailyExercises = {};
  data.removeAt(0);
  for (var entry in data.reversed) {
    List row = entry[0]; // for some reason its nested further
    if (row.length != 14){
      continue;
    }
    try{
    String startTime = row[0];
    String notes = row[12].isNotEmpty ? '${row[0]} | ${row[12]}' : row[1];
    String exercise = corrections[row[2]] ?? row[2];
    String exerciseNote = row[11];
    // int setIndex = row[7];
    String setType = 'Normal';
    double? weight = double.tryParse(row[4].toString());
    int? reps = int.tryParse(row[6].toString());
    double? distance = double.tryParse(row[8].toString());
    int duration = parseTime(row[13].toString());
    
    DateTime startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(startTime);
    DateTime endDate = startDate.add(Duration(minutes: duration));
    String dateStr = DateFormat('yyyy-MM-dd').format(startDate);

    String key = '$dateStr 1';
    if (!formattedData.containsKey(key)){
      formattedData[key] = {
        'stats': {
          'startTime': DateFormat('yyyy-MM-dd HH:mm').format(startDate),
          'endTime': DateFormat('yyyy-MM-dd HH:mm').format(endDate),
          'notes': {"Workout": notes},
        },
        'sets': {}  // Create an empty 'sets' map to populate later
      };
    }
    if (exerciseNote != ''){
      formattedData[key]['stats']['notes'][exercise] = exerciseNote;
    }
    weight = findWeight(weight, distance);
    Map set = {'weight': weight ?? 1, 'reps': reps ?? 1, 'type': setType};
    if (!records.containsKey(exercise)){
      records[exercise] = set;
      set['PR'] = 'yes';
    }
    else{
      if (set['weight'] > double.parse(records[exercise]['weight'].toString())){
        records[exercise] = set;
        set['PR'] = 'yes';
      } else if (set['weight'] == double.parse(records[exercise]['weight'].toString()) && set['reps'] > double.parse(records[exercise]['reps'].toString())){
        records[exercise] = set;
        set['PR'] = 'yes';
      }
    }
    dailyExercises.putIfAbsent(key, () => []).insert(0, {'exercise': exercise, 'set': set}); // TODO understand putifabsent
    }catch(e){
      debugPrint('failed: $e $row');
    }
    
  }
    // Reverse order of exercises for each day
  dailyExercises.forEach((key, exercises) {
    formattedData[key]['sets'] = {};  // Initialize empty sets map

    // Populate `formattedData` in the correct chronological order
    for (var exerciseData in exercises) {
      String exercise = exerciseData['exercise'];
      Map set = exerciseData['set'];
      if (!formattedData[key]['sets'].containsKey(exercise)) {
        formattedData[key]['sets'][exercise] = [];
      }
      formattedData[key]['sets'][exercise].add(set);
    }
  });
  return formattedData;
}

int parseTime(String time) {
  final regex = RegExp(r'(?:(\d+)h)?\s*(?:(\d+)m)?'); // Make hours and minutes optional
  final match = regex.firstMatch(time);

  if (match != null) {
    int hours = int.parse(match.group(1) ?? '0');   // Use 0 if hours are not provided
    int minutes = int.parse(match.group(2) ?? '0'); // Use 0 if minutes are not provided
    return hours * 60 + minutes;
  } else {
    throw const FormatException("Invalid time format");
  }
}

double? findWeight(double? weight, double? distance, {double? duration}) {
  debugPrint('$weight, $distance');
  if (weight != null){
    return weight;
  }
  else if (distance != null){
    return distance;
  }
  return weight;
}
Map<String, dynamic> formatHevyData(List data, Map records){
  Map<String, dynamic> formattedData = {};
  Map dailyExercises = {};

  data.removeAt(0);
  for (var entry in data.reversed) {
    List row = entry[0]; // for some reason its nested further
    String startTime = row[1];
    String endTime = row[2];
    String notes = row[3].isNotEmpty ? '${row[0]} | ${row[3]}' : row[0];
    String exercise = corrections[row[4]] ?? row[4];
    String exerciseNote = row[6];
    // int setIndex = row[7];
    String setType = row[8];
    double? weight = double.tryParse(row[9].toString());
    int? reps = int.tryParse(row[10].toString());
    double? distance = double.tryParse(row[11].toString());
    double? duration = double.tryParse(row[12].toString());
    
    DateTime startDate = DateFormat('dd MMM yyyy, HH:mm').parse(startTime);
    DateTime endDate = DateFormat('dd MMM yyyy, HH:mm').parse(endTime);
    String dateStr = DateFormat('yyyy-MM-dd').format(startDate);

    String key = '$dateStr 1';
    if (!formattedData.containsKey(key)){
      formattedData[key] = {
        'stats': {
          'startTime': DateFormat('yyyy-MM-dd HH:mm').format(startDate),
          'endTime': DateFormat('yyyy-MM-dd HH:mm').format(endDate),
          'notes': {"Workout": notes},
        },
        'sets': {}  // Create an empty 'sets' map to populate later
      };
    }
    if (exerciseNote != ''){
      formattedData[key]['stats']['notes'][exercise] = exerciseNote;
    }
    weight = findWeight(weight, distance, duration: duration);
    Map set = {'weight': weight ?? 1, 'reps': reps ?? 1, 'type': setType};
    if (!records.containsKey(exercise)){
      records[exercise] = set;
      set['PR'] = 'yes';
    }
    else{
      if (set['weight'] > double.parse(records[exercise]['weight'].toString())){
        records[exercise] = set;
        set['PR'] = 'yes';
      } else if (set['weight'] == double.parse(records[exercise]['weight'].toString()) && set['reps'] > double.parse(records[exercise]['reps'].toString())){
        records[exercise] = set;
        set['PR'] = 'yes';
      }
    }
    dailyExercises.putIfAbsent(key, () => []).insert(0, {'exercise': exercise, 'set': set}); // TODO understand putifabsent
  }
    // Reverse order of exercises for each day
  dailyExercises.forEach((key, exercises) {
    formattedData[key]['sets'] = {};  // Initialize empty sets map

    // Populate `formattedData` in the correct chronological order
    for (var exerciseData in exercises) {
      String exercise = exerciseData['exercise'];
      Map set = exerciseData['set'];
      if (!formattedData[key]['sets'].containsKey(exercise)) {
        formattedData[key]['sets'][exercise] = [];
      }
      formattedData[key]['sets'][exercise].add(set);
    }
  });
  return formattedData;
}