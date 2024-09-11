import 'package:exercise_app/file_handling.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExerciseScreen extends StatefulWidget {
  final String exercise;

  const ExerciseScreen({super.key, required this.exercise});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List exerciseData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};

  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }

  Future<void> _loadHighlightedDays() async {
    var data = await getStats(widget.exercise);
    debugPrint(data.toString());
    setState(() {
      exerciseData = data[0];
      if (data[0].isNotEmpty){
        heaviestWeight = data[1];
        heaviestVolume = data[2];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        final List dates = exerciseData.map((data) => data['date'].split(' ')[0]).toList();
    final List<FlSpot> spots = exerciseData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(), // Use the index as the X value
              double.parse(entry.value['weight'].toString()), // Parse the weight (Y value)
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
                    const SizedBox(height: 20),
                    Text('Most weight : ${heaviestWeight['weight']}kg x ${heaviestWeight['reps']}'),
                    Text('Most volume : ${heaviestVolume['weight']}kg x ${heaviestVolume['reps']}'),
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
  Map data = await readData();
  List targetData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};
  for (var day in data.keys.toList().reversed){
    for(var exercise in data[day]['sets'].keys){
      if (exercise == target){      
        for(var set in data[day]['sets'][exercise]){
          set = {'weight' : double.parse(set['weight']), 'reps' : double.parse(set['reps']), 'type' : set['type'], 'date' : day};
          targetData.add(set);
          if (heaviestVolume.isEmpty){
            heaviestVolume = set;
          }else if(set['weight'] * set['reps'] > heaviestVolume['weight'] * heaviestVolume['reps']){
            heaviestVolume = set;
          }
          if (heaviestWeight.isEmpty){
            heaviestWeight = set;
          }else if(set['weight'] > heaviestWeight['weight']){
            heaviestWeight = set;
          }        
        }
      }
    }
  }
  return [targetData, heaviestWeight, heaviestVolume];
}