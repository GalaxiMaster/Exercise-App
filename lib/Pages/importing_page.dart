import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exercise_app/encryption_controller.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImportingPage extends StatefulWidget {
  const ImportingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImportingPageState createState() => _ImportingPageState();
}

class _ImportingPageState extends State<ImportingPage> {
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
        children: [
          
          _buildSettingsBox(icon: Icons.import_contacts, label: 'Import from This', function: (){importDataThis(context);}),
          _buildSettingsBox(icon: Icons.import_contacts, label: 'Import from Hevy', function: (){importDataHevy(context);}),
          _buildSettingsBox(icon: Icons.import_contacts, label: 'Import from Strong', function: (){importDataStrong(context);})

        ],
      ),
    );
  }
}
Widget _buildSettingsBox({
    required IconData icon,
    required String label,
    required VoidCallback? function,
    Widget? rightside
  }) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 173, 173, 173).withValues(alpha: 0.1), // Background color for the whole box
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: const TextStyle(
                   fontSize: 23,
                ),
              ),
              const Spacer(),
              rightside ??
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios),
                ),
            ],
          ),
        ),
      ),
    );
  }

void importDataThis(BuildContext context) async{
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
  Map corrections = {'Pull Up (Weighted)': 'Weighted Pull Up', 'Iso-Lateral Row (Machine)': 'Seated Lever Machine Row', 'Straight Arm Lat Pulldown (Cable)': 'Cable Pullover', 'Seated Cable Row - V Grip (Cable)': 'Cable seated row', 'Single Arm Curl (Cable)': 'Cable One Arm Biceps Curl', 'Bench Press (Barbell)': 'Barbell Bench Press', 'Triceps Dip (Weighted)': 'Weighted Tricep Dips', 'Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Triceps Rope Pushdown': 'Cable Pushdown (Rope)', 'Incline Bench Press (Dumbbell)': 'Dumbbell Incline Bench Press', 'Cable Wrist Curl (Single)': 'Cable One Arm Wrist Curl', 'Seated Palms Up Wrist Curl': 'Dumbbell Seated Palms Up Wrist Curl', 'Bent Over Row (Barbell)': 'Barbell Bent Over Row', 'Bench Press (Dumbbell)': 'Dumbbell Bench Press', 'Bicep Curl (Dumbbell)': 'Dumbbell Biceps Curl', 'Triceps Dip': 'Tricep Dips', 'Triceps Extension (Cable)': 'Cable Overhead Triceps Extension', 'T Bar Row': 'Lying T-Bar Row', 'Lat Pulldown (Machine)': 'Machine Lat Pulldowns', 'Lateral Raise (Dumbbell)': 'Dumbbell Lateral Raise', 'Standing Calf Raise (Smith)': 'Smith Calf Raise', 'Hip Thrust (Barbell)': 'Barbell Hip Thrust', 'Leg Extension (Machine)': 'Lever Leg Extension', 'Deadlift (Barbell)': 'Barbell Deadlift', 'Back Extension (Weighted Hyperextension)': 'Back Extensions', 'Incline Bench Press (Barbell)': 'Barbell Incline Bench Press', 'Chin Up': 'Chin Up', 'Overhead Press (Barbell)': 'Barbell Overhead press', 'Bicep Curl (Cable)': 'Cable Curl', 'Bicep Curl (Barbell)': 'Barbell Curl', 'Chest Fly (Machine)': 'Machine Chest Fly', 'Pull Up': 'Pull Up', 'Rear Delt Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Hammer Curl (Dumbbell)': 'Dumbbell Hammer Curl', 'Leg Press (Machine)': 'Sled 45 Leg Press', 'Shoulder Press (Dumbbell)': 'Dumbbell Seated Shoulder Press', 'Cable Pull Through': 'Cable pull through', 'Cable Fly Crossovers': 'Cable Standing Up Straight Crossovers', 'Preacher Curl (Barbell)': 'Barbell Preacher Curl', 'Single Arm Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Hammer Curl (Cable)': 'Cable Hammer Curl', 'Hack Squat': 'Sled Hack Squat', 'Dead Hang': 'Dead Hang', 'Seated Cable Row - Bar Grip': 'Cable Low Seated Row', 'Seated Cable Row - Bar Wide Grip': 'Wide Grip Overhand Row', 'Single Arm Cable Row': 'Cable One Arm Row', 'Lat Pulldown (Cable)': 'Cable Neutral Grip Lat Pulldown', 'Leg Raise Parallel Bars': 'Captain Seat Leg Raise', 'Hack Squat (Machine)': 'Sled Hack Squat', 'Farmers Walk': 'Farmer Walk', 'Incline Bench Press (Smith Machine)': 'Smith Machine Incline Bench Press', 'Chin Up (Weighted)': 'Weighted Chin Up', 'Low Cable Fly Crossovers': 'Low Cable Fly', 'Behind the Back Bicep Wrist Curl (Barbell)': 'Barbell Behind the Back Wrist Curls', 'Push Up - Close Grip': 'Push Up', 'Push Up': 'Push up', 'Flat Leg Raise': 'Seated Leg Raise', 'Overhead Press (Dumbbell)': 'Standing Overhead Press (Barbell)', 'Sit Up': 'Sit Up', 'Concentration Curl (Dumbbell)': 'Dumbbell Concentration Curl', 'Front Raise (Dumbbell)': 'Dumbbell Front Raise', 'Triceps Pushdown (Cable - Straight Bar)': 'Cable Pushdown', 'Shoulder Press (Machine)': 'Machine Shoulder Press', 'Chest Dip': 'Chest Dip', 'Incline Curl (Dumbbell)': 'Dumbbell Incline Curl', 'Chest Fly': 'Machine Chest Fly', 'Seated Row (Cable)': 'Cable seated row', 'Triceps Extension (Dumbbell)': 'Dumbbell Seated Triceps Extension', 'Triceps Dip (Assisted)': 'Assisted Tricep Dips', 'Reverse Curl (Barbell)': 'Barbell Reverse Curl', 'Seated Calf Raise (Plate Loaded)': 'Lever Calf Press (plate loaded)', 'Leg Press': 'Sled 45 Leg Press', 'Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Bulgarian Split Squat': 'Bulgarian Split Squat', 'Seated Leg Press (Machine)': 'Lever Seated Leg Press', 'Seated Leg Curl (Machine)': 'Lever Seated Leg Curl', 'Preacher Curl (Machine)': 'Lever Preacher Curl', 'Seated Palms Up Wrist Curl (Dumbbell)': 'Dumbbell Seated Palms Up Wrist Curl', 'flutter kicks': 'Seated Flutter Kick', 'scissors': 'Scissors (advanced)', 'Flutter kicks': 'Seated Flutter Kick', 'Bent Over One Arm Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Bent Over Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Skullcrusher (Dumbbell)': 'Dumbbell Lying Floor Skullcrusher', 'Pullover (Dumbbell)': 'Dumbbell Pullover', 'Reverse Curl (Dumbbell)': 'Dumbbell Biceps Curl Reverse', 'lever Row': 'Seated Lever Machine Row', 'Triceps Extension (Barbell)': 'Barbell Standing Overhead Triceps Extension', 'Skullcrusher (Barbell)': 'Barbell Lying Triceps Extension Skull Crusher', 'Plank': 'Plank', 'Jumping Jack': 'Jumping Jack', 'Crunch': 'Crunch', 'Running': 'Running', 'Reverse Grip Concentration Curl (Dumbbell)': 'Dumbbell Seated Reverse Concentration Curl', 'Arnold Press (Dumbbell)': 'Dumbbell Arnold Press', 'Walking': 'Walking', 'Pull Up (Assisted)': 'Assisted Pull Up', 'Iso-Lateral Chest Press (Machine)': 'Lever Chest Press (plate loaded)', 'Incline Chest Press (Machine)': 'Incline Lever Chest Press', 'Hip Abductor (Machine)': 'Hip Abductor', 'Side Plank': 'Side Plank'};
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
  Map corrections = {'Pull Up (Weighted)': 'Weighted Pull Up', 'Iso-Lateral Row (Machine)': 'Seated Lever Machine Row', 'Straight Arm Lat Pulldown (Cable)': 'Cable Pullover', 'Seated Cable Row - V Grip (Cable)': 'Cable seated row', 'Single Arm Curl (Cable)': 'Cable One Arm Biceps Curl', 'Bench Press (Barbell)': 'Barbell Bench Press', 'Triceps Dip (Weighted)': 'Weighted Tricep Dips', 'Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Triceps Rope Pushdown': 'Cable Pushdown (Rope)', 'Incline Bench Press (Dumbbell)': 'Dumbbell Incline Bench Press', 'Cable Wrist Curl (Single)': 'Cable One Arm Wrist Curl', 'Seated Palms Up Wrist Curl': 'Dumbbell Seated Palms Up Wrist Curl', 'Bent Over Row (Barbell)': 'Barbell Bent Over Row', 'Bench Press (Dumbbell)': 'Dumbbell Bench Press', 'Bicep Curl (Dumbbell)': 'Dumbbell Biceps Curl', 'Triceps Dip': 'Tricep Dips', 'Triceps Extension (Cable)': 'Cable Overhead Triceps Extension', 'T Bar Row': 'Lying T-Bar Row', 'Lat Pulldown (Machine)': 'Machine Lat Pulldowns', 'Lateral Raise (Dumbbell)': 'Dumbbell Lateral Raise', 'Standing Calf Raise (Smith)': 'Smith Calf Raise', 'Hip Thrust (Barbell)': 'Barbell Hip Thrust', 'Leg Extension (Machine)': 'Lever Leg Extension', 'Deadlift (Barbell)': 'Barbell Deadlift', 'Back Extension (Weighted Hyperextension)': 'Back Extensions', 'Incline Bench Press (Barbell)': 'Barbell Incline Bench Press', 'Chin Up': 'Chin Up', 'Overhead Press (Barbell)': 'Barbell Overhead press', 'Bicep Curl (Cable)': 'Cable Curl', 'Bicep Curl (Barbell)': 'Barbell Curl', 'Chest Fly (Machine)': 'Machine Chest Fly', 'Pull Up': 'Pull Up', 'Rear Delt Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Hammer Curl (Dumbbell)': 'Dumbbell Hammer Curl', 'Leg Press (Machine)': 'Sled 45 Leg Press', 'Shoulder Press (Dumbbell)': 'Dumbbell Seated Shoulder Press', 'Cable Pull Through': 'Cable pull through', 'Cable Fly Crossovers': 'Cable Standing Up Straight Crossovers', 'Preacher Curl (Barbell)': 'Barbell Preacher Curl', 'Single Arm Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Hammer Curl (Cable)': 'Cable Hammer Curl', 'Hack Squat': 'Sled Hack Squat', 'Dead Hang': 'Dead Hang', 'Seated Cable Row - Bar Grip': 'Cable Low Seated Row', 'Seated Cable Row - Bar Wide Grip': 'Wide Grip Overhand Row', 'Single Arm Cable Row': 'Cable One Arm Row', 'Lat Pulldown (Cable)': 'Cable Neutral Grip Lat Pulldown', 'Leg Raise Parallel Bars': 'Captain Seat Leg Raise', 'Hack Squat (Machine)': 'Sled Hack Squat', 'Farmers Walk': 'Farmer Walk', 'Incline Bench Press (Smith Machine)': 'Smith Machine Incline Bench Press', 'Chin Up (Weighted)': 'Weighted Chin Up', 'Low Cable Fly Crossovers': 'Low Cable Fly', 'Behind the Back Bicep Wrist Curl (Barbell)': 'Barbell Behind the Back Wrist Curls', 'Push Up - Close Grip': 'Push Up', 'Push Up': 'Push up', 'Flat Leg Raise': 'Seated Leg Raise', 'Overhead Press (Dumbbell)': 'Standing Overhead Press (Barbell)', 'Sit Up': 'Sit Up', 'Concentration Curl (Dumbbell)': 'Dumbbell Concentration Curl', 'Front Raise (Dumbbell)': 'Dumbbell Front Raise', 'Triceps Pushdown (Cable - Straight Bar)': 'Cable Pushdown', 'Shoulder Press (Machine)': 'Machine Shoulder Press', 'Chest Dip': 'Chest Dip', 'Incline Curl (Dumbbell)': 'Dumbbell Incline Curl', 'Chest Fly': 'Machine Chest Fly', 'Seated Row (Cable)': 'Cable seated row', 'Triceps Extension (Dumbbell)': 'Dumbbell Seated Triceps Extension', 'Triceps Dip (Assisted)': 'Assisted Tricep Dips', 'Reverse Curl (Barbell)': 'Barbell Reverse Curl', 'Seated Calf Raise (Plate Loaded)': 'Lever Calf Press (plate loaded)', 'Leg Press': 'Sled 45 Leg Press', 'Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Bulgarian Split Squat': 'Bulgarian Split Squat', 'Seated Leg Press (Machine)': 'Lever Seated Leg Press', 'Seated Leg Curl (Machine)': 'Lever Seated Leg Curl', 'Preacher Curl (Machine)': 'Lever Preacher Curl', 'Seated Palms Up Wrist Curl (Dumbbell)': 'Dumbbell Seated Palms Up Wrist Curl', 'flutter kicks': 'Seated Flutter Kick', 'scissors': 'Scissors (advanced)', 'Flutter kicks': 'Seated Flutter Kick', 'Bent Over One Arm Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Bent Over Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Skullcrusher (Dumbbell)': 'Dumbbell Lying Floor Skullcrusher', 'Pullover (Dumbbell)': 'Dumbbell Pullover', 'Reverse Curl (Dumbbell)': 'Dumbbell Biceps Curl Reverse', 'lever Row': 'Seated Lever Machine Row', 'Triceps Extension (Barbell)': 'Barbell Standing Overhead Triceps Extension', 'Skullcrusher (Barbell)': 'Barbell Lying Triceps Extension Skull Crusher', 'Plank': 'Plank', 'Jumping Jack': 'Jumping Jack', 'Crunch': 'Crunch', 'Running': 'Running', 'Reverse Grip Concentration Curl (Dumbbell)': 'Dumbbell Seated Reverse Concentration Curl', 'Arnold Press (Dumbbell)': 'Dumbbell Arnold Press', 'Walking': 'Walking', 'Pull Up (Assisted)': 'Assisted Pull Up', 'Iso-Lateral Chest Press (Machine)': 'Lever Chest Press (plate loaded)', 'Incline Chest Press (Machine)': 'Incline Lever Chest Press', 'Hip Abductor (Machine)': 'Hip Abductor', 'Side Plank': 'Side Plank'};
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