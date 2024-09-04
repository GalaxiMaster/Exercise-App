// import 'package:exercise_app/widgets.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class ExerciseScreen extends StatefulWidget {
  final String exercise;

  const ExerciseScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List exerciseData = [];

  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }

  Future<void> _loadHighlightedDays() async {
    var data = await getStats(widget.exercise);
    setState(() {
      exerciseData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
        final List dates = exerciseData.map((data) => data[0].split(' ')[0]).toList();
    final List<FlSpot> spots = exerciseData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(), // Use the index as the X value
              double.parse(entry.value[6].toString()), // Parse the weight (Y value)
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise),
      ),
      body: Center(
        child: spots.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  return SideTitleWidget(
                                    axisSide: AxisSide.bottom,
                                    child: Transform.rotate(
                                      angle: -40 * 3.14159 / 180, // Tilt by 60 degrees
                                      child: Text(
                                        dates[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  );
                                },
                                interval: 1, // Ensure all dates are shown
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  return Text(value.toInt().toString()); // Display as integer
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black),
                          ),
                          gridData: const FlGridData(show: true),
                        ),
                      ),
                    ),
                  ],
                ),
            )
            : const Text("No data available"),
      ),
    );
  }
}
AppBar appBar(BuildContext context, String exercise) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        exercise,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
  }

Future<List> getStats(String target) async{
  List data = await readFromCsv();
  List targetData = [];
  for (var set in data){
    if(set[2].toString() == target){
      targetData.add(set);
    }
  }
  return targetData;
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