import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  Map exerciseData = {};
  Map stats = {'volume' : 0};
  @override
  initState(){
    super.initState();
    _loadHighlightedDays();
  }
  Future<void> _loadHighlightedDays() async {
    var data = await gatherData();
    double totalVolume = 0;
    for (var day in data.keys) {
      for (var exercise in data[day].keys){
        for (var set in data[day][exercise]){
          totalVolume += set['Weight'] * set['Reps'];
        }
      }
    }
    setState(() {
      stats = {'volume' : totalVolume};
      exerciseData = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Text(stats['volume'].toString()),
    );
  }
}
AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Stats',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      actions: [
        Center(
          child: MyIconButton(
            filepath: 'Assets/settings.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: const Color.fromRGBO(163, 163, 163, .7),
            color: const Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            onTap: (){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => 
              //     const Settings()
              //   )
              // );
            },
            ),
        )
      ],
    );
  }
Future<Map> gatherData() async {
  Map exerciseData = {};
  List data = await readFromCsv();
  for (var set in data){
    String day = set[0].split(' ')[0];
    if (exerciseData.containsKey(day) && exerciseData[day].containsKey(set[2])){
      exerciseData[day][set[2]].add({'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]});
    } else if(exerciseData.containsKey(day)){
      exerciseData[day][set[2]] = [{'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]}];
    } else{
      exerciseData[day] = {};
      exerciseData[day][set[2]] = [{'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]}];
    }
  }
  return exerciseData;
}
Future<List<List<dynamic>>> readFromCsv() async {
  List<List<dynamic>> csvData = [];
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
  return csvData;
}