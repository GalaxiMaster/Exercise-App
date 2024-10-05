import 'package:exercise_app/Pages/muscle_data.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

class MuscleTracking extends StatelessWidget {
  final Map setData;
  const MuscleTracking({super.key, required this.setData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Muscle Tracking'),
      body: FutureBuilder<List>(
        future: getSetAmounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            return FlexibleMuscleLayout(data: snapshot.data![0], normalData: snapshot.data![1]);
          } else {
            return const Text('No data available');
          }
        }
      )
    );
  }
}

class FlexibleMuscleLayout extends StatefulWidget {
  final Map data;
  final Map normalData;
  const FlexibleMuscleLayout({super.key, required this.data, required this.normalData});

  @override
  // ignore: library_private_types_in_public_api
  _FlexibleMuscleLayoutState createState() => _FlexibleMuscleLayoutState();
}

class _FlexibleMuscleLayoutState extends State<FlexibleMuscleLayout> {
  String? expandedMuscle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.data.entries.map((entry) {
            final muscle = entry.key;
            final value = entry.value;
            final isExpanded = muscle == expandedMuscle;

            if (isExpanded) {
              return ExpandedSetProgressTile(
                muscle: muscle,
                value: value,
                goal: 30,
                onTap: () => setState(() => expandedMuscle = null),
                data: getMuscleSpecifics(widget.normalData, muscle),
              );
            } else {
              return SetProgressTile(
                muscle: muscle,
                value: value,
                goal: 30,
                onTap: () => setState(() => expandedMuscle = muscle),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
Map getMuscleSpecifics(Map data, String muscle) {
  Map<String, double> sortedData = {};

  if (muscleGroups.containsKey(muscle)) {
    List<String> muscleList = muscleGroups[muscle]!;

    for (String muscleName in muscleList) {
      if (data.containsKey(muscleName)) {
        sortedData[muscleName] = data[muscleName];
      }
    }
  }

  return sortedData;
}
}

class SetProgressTile extends StatelessWidget {
  final String muscle;
  final double value;
  final double goal;
  final VoidCallback onTap;

  const SetProgressTile({
    super.key,
    required this.muscle,
    required this.value,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 24) / 2, // Subtracting padding and calculating half width
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  muscle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: CaloriesSpeedometer(calories: value, maxCalories: goal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandedSetProgressTile extends StatelessWidget {
  final String muscle;
  final double value;
  final double goal;
  final Map data;
  final VoidCallback onTap;

  const ExpandedSetProgressTile({
    super.key,
    required this.muscle,
    required this.value,
    required this.goal,
    required this.onTap, required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    muscle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: Stack(
                          children: [ 
                            PieChart(
                              PieChartData(
                                centerSpaceRadius: 65,
                                sections: data.entries.map((entry) {
                                  return PieChartSectionData(
                                    color: getColor(entry.key),
                                    value: entry.value,
                                    title: '${entry.key}\n${entry.value}%',
                                    radius: 20,
                                    titleStyle: const TextStyle(color: Colors.transparent),
                                  );
                                }).toList()
                              )
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < data.keys.length; i++)
                                  Text(data.keys.toList()[i], style: TextStyle(color: getColor(data.keys.toList()[i])),)
                                ],
                              ),
                            )
                          ]
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: WeeklyProgressChart(muscle: muscle,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class WeeklyProgressChart extends StatelessWidget {
  final String muscle;
  const WeeklyProgressChart({super.key, required this.muscle});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getWeekData(muscle),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4, // TODO set this to something
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  ['M', 'Tu', 'W', 'Th', 'F', 'Sa', 'Su'][value.toInt()],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: 
          snapshot.data!.entries.toList().asMap().entries.map((entry) {
            int index = entry.key;
            var data = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data,
                  color: Colors.green,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  } else {
    return const Text('No data available');
  }
  });
}
  Future<Map> getWeekData(String mainMuscle) async{
  Map weekData = {'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0}; // double format
  Map data = await readData();
  for (var day in data.keys){
    if (DateTime.now().difference(DateTime.parse(day.split(' ')[0])).inDays < 7){
      String dayName = DateFormat('EEE').format(DateTime.parse(day.split(' ')[0]));
      for (var exercise in data[day]['sets'].keys){
        if(exerciseMuscles.containsKey(exercise))
        // ignore: unused_local_variable, curly_braces_in_flow_control_structures
        for (var set in data[day]['sets'][exercise]){
          for (var muscle in exerciseMuscles[exercise]!['Primary']!.keys){
            if (muscleGroups[mainMuscle]!.contains(muscle)){
              weekData[dayName] = (weekData[dayName] ?? 0) + 1 * (exerciseMuscles[exercise]!['Primary']![muscle]!/100);
            }
          }
          for (var muscle in exerciseMuscles[exercise]!['Secondary']!.keys){
            if (muscleGroups[mainMuscle]!.contains(muscle)){
              weekData[dayName] = (weekData[dayName] ?? 0) + 1 * (exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
            }
          }
        }
      }
    }
  }
  return weekData;
}
}

  Future<List> getSetAmounts() async {
  Map data = {};
  Map muscleData = {};
    Map sets = await readData();
    for (var day in sets.keys){
      for (var exercise in sets[day]['sets'].keys){
        if (exerciseMuscles.containsKey(exercise)){
          // ignore: unused_local_variable
          for (var set in sets[day]['sets'][exercise]){
            for (var muscle in exerciseMuscles[exercise]!['Primary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += 1*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              } else{
                muscleData[muscle] = 1*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              }
            }
            for (var muscle in exerciseMuscles[exercise]!['Secondary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += 1*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              } else{
                muscleData[muscle] = 1*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              }
            }
          }
        } else{
          debugPrint('Unknown exercise: $exercise');
        }
      }
    }
    sets = muscleData;
    data['Back'] = (sets['Lats'] ?? 0) + (sets['Erector Spinae'] ?? 0) + (sets['Rhomboids'] ?? 0) + (sets['Lower Back'] ?? 0).roundToDouble(); // Back
    data['Chest'] = (sets['Pectorals'] ?? 0) + (sets['Pectorals (Upper)'] ?? 0) + (sets['Pectorals (Lower)'] ?? 0).roundToDouble(); // Chest
    data['Shoulders'] = (sets['Front Delts'] ?? 0) + (sets['Side Delts'] ?? 0) + (sets['Posterior Delts'] ?? 0) + (sets['Trapezius'] ?? 0).roundToDouble(); // Shoulders
    data['Arms'] = (sets['Biceps'] ?? 0) + (sets['Triceps'] ?? 0) + (sets['Forearms'] ?? 0) + (sets['Brachialis'] ?? 0).roundToDouble(); // Arms
    data['Legs'] = (sets['Quadriceps'] ?? 0) + (sets['Hamstrings'] ?? 0) + (sets['Glutes'] ?? 0) + (sets['Calves'] ?? 0).roundToDouble();// Legs
    data['Core'] = (sets['Rectus Abdominis'] ?? 0) + (sets['Obliques'] ?? 0) + (sets['Core'] ?? 0) + (sets['Hip Flexors'] ?? 0).roundToDouble(); // Core
    List<MapEntry> entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    data = Map.fromEntries(entries);
    return [data,  sets];

  }

class CaloriesSpeedometer extends StatelessWidget {
  final double calories;
  final double maxCalories;

  const CaloriesSpeedometer({
    super.key,
    required this.calories,
    required this.maxCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Center(  // Center the Stack within the Container
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(130, 30),
              painter: SpeedometerPainter(
                progress: calories / maxCalories,
                backgroundColor: const Color(0xFF3F51B5).withOpacity(0.3),
                progressColor: const Color(0xFF4CAF50),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${calories.toStringAsFixed(2)} of',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$maxCalories sets',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class SpeedometerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  SpeedometerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);  // Moved center down slightly
    final radius = size.width / 2;
    const startAngle = 130 * math.pi / 180;
    const sweepAngle = 280 * math.pi / 180;
    const strokeWidth = 20.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * math.min(progress, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

