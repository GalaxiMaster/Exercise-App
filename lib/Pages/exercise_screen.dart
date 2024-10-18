import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
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
  String selector = 'volume';

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
              exerciseMuscles[widget.exercise]['type'] != 'bodyweight' ? double.parse(entry.value[selector].toString()) : double.parse(entry.value['reps'].toString()), // Parse the weight (Y value)
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
                              // isCurved: true, // lets the graph be extrapolated, turned off due to incorrect points
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
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          gridData: const FlGridData(show: true),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        selectorBox('Weight', selector == 'weight'),
                        selectorBox('Volume', selector == 'volume'),
                        selectorBox('Reps', selector == 'reps'),
                      ],
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
  Widget selectorBox(String text, bool selected){
    return GestureDetector(
      onTap: () async{
        setState(() {
          switch(text){
            case 'Weight': selector = 'weight';
            case 'Volume': selector = 'volume';
            case 'Reps': selector = 'reps';
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              text
            ),
          ),
        ),
      ),
    );
  }
}

Future<List> getStats(String target) async {
  Map data = await readData();
  List targetData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};

  for (var day in data.keys.toList().reversed) {
    Map dayHeaviestWeight = {};
    Map dayHeaviestVolume = {};

    for (var exercise in data[day]['sets'].keys) {
      if (exercise == target) {
        for (var set in data[day]['sets'][exercise]) {
          set = {
            'weight': double.parse(set['weight']),
            'reps': double.parse(set['reps']),
            'type': set['type'],
            'date': day,
            'volume': double.parse(set['reps']) * double.parse(set['weight'])
          };

          if (dayHeaviestWeight.isEmpty || set['weight'] > dayHeaviestWeight['weight']) {
            dayHeaviestWeight = set;
          }

          if (dayHeaviestVolume.isEmpty || set['volume'] > dayHeaviestVolume['volume']) {
            dayHeaviestVolume = set;
          }
        }

        if (dayHeaviestWeight.isNotEmpty) {
          targetData.add(dayHeaviestWeight);
        }

        if (heaviestWeight.isEmpty || dayHeaviestWeight['weight'] > heaviestWeight['weight']) {
          heaviestWeight = dayHeaviestWeight;
        }

        if (heaviestVolume.isEmpty || dayHeaviestVolume['volume'] > heaviestVolume['volume']) {
          heaviestVolume = dayHeaviestVolume;
        }
      }
    }
  }

  return [targetData, heaviestWeight, heaviestVolume];
}
