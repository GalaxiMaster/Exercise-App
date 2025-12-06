import 'package:flutter/services.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

class MuscleTracking extends StatefulWidget {
  final Map setData;
  const MuscleTracking({super.key, required this.setData});

  @override
  MuscleTrackingState createState() => MuscleTrackingState();
}

class MuscleTrackingState extends State<MuscleTracking> {
  Map<String, dynamic>? muscleGoals;

  void onGoalUpdate(String muscle, double newGoal) {
    setState(() {
      muscleGoals?[muscle] = newGoal;
    });
    // Persist the updated goal
    writeMuscleGoal(muscle, newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Muscle Tracking'),
      body: FutureBuilder(
        future: getSetAmounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            // Initialize muscleGoals if it's null
            muscleGoals ??= Map<String, dynamic>.from(snapshot.data![2]['Muscle Goals']);
            return FlexibleMuscleLayout(
              data: snapshot.data![0],
              normalData: snapshot.data![1],
              goals: muscleGoals!,
              onGoalUpdate: onGoalUpdate,
            );
          } else {
            return const Text('No data available');
          }
        }
      )
    );
  }
}
// ignore: must_be_immutable
class FlexibleMuscleLayout extends StatefulWidget {
  final Map data;
  final Map normalData;
  Map goals;
    final Function(String, double) onGoalUpdate;

  FlexibleMuscleLayout({super.key, required this.data, required this.normalData, required this.goals, required this.onGoalUpdate});

  @override
  // ignore: library_private_types_in_public_api
  _FlexibleMuscleLayoutState createState() => _FlexibleMuscleLayoutState();
}

class _FlexibleMuscleLayoutState extends State<FlexibleMuscleLayout> {
  String? expandedMuscle;

  void reloadState(){
    setState(() {

    });
  }

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
                goal: widget.goals[muscle],
                onTap: () => setState(() => expandedMuscle = null),
                data: getMuscleSpecifics(widget.normalData, muscle),
              );
            } else {
              return SetProgressTile(
                muscle: muscle,
                value: value,
                goal: widget.goals[muscle],
                onTap: () => setState(() => expandedMuscle = muscle),
                onGoalUpdate: widget.onGoalUpdate,
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

// ignore: must_be_immutable
class SetProgressTile extends StatelessWidget {
  final String muscle;
  final double value;
  double goal;
  final VoidCallback onTap;
  final Function(String, double) onGoalUpdate;

  SetProgressTile({
    super.key,
    required this.muscle,
    required this.value,
    required this.goal,
    required this.onTap, 
    required this.onGoalUpdate,
  });
 
  @override
  Widget build(BuildContext context) {
    double currentValue = 0.0;
    
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      muscle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Set Goal: '),
                              content: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 100),
                                child: TextFormField(
                                  inputFormatters: [
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                      try {
                                        final text = newValue.text;
                                        if (text.isEmpty) {
                                          return newValue;
                                        }
                                        double? number = double.tryParse(text);
                                        if (number == null) {
                                          return oldValue;
                                        }
                                        if (number > 100) {
                                          return oldValue;
                                        }
                                        if (text.contains('.')) {
                                          var parts = text.split('.');
                                          if (parts.length > 2 || parts[1].length > 1) {
                                            return oldValue;
                                          }
                                        }
                                        return newValue;
                                      } catch (e) {
                                        return oldValue;
                                      }
                                    }),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a number';
                                    }
                                    int? number = int.tryParse(value);
                                    if (number == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (number < 1 || number > 100) {
                                      return 'Please enter a number between 1 and 100';
                                    }
                                    return null;
                                  },                                  
                                  initialValue: goal.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    hintText: 'value...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey
                                    )
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    currentValue = double.tryParse(value) ?? currentValue;
                                  },
                                ),
                              ),
                              
                              actions: <Widget>[
                                TextButton(
                                  child: const Center(child: Text('OK', style: TextStyle(color: Colors.blue),)),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Dismiss the dialog
                                    writeMuscleGoal(muscle, currentValue);
                                    goal = currentValue;
                                    onGoalUpdate(muscle, currentValue);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                      child: const Icon(Icons.edit, size: 20)
                    )
                  ],
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
    required this.onTap, 
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // sort entries
    List<MapEntry> entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    Map sortedData = Map.fromEntries(entries);

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
                                sections: sortedData.entries.map((entry) {
                                  return PieChartSectionData(
                                    color: getColor(entry.key),
                                    value: entry.value,
                                    // title: '${entry.key}\n${entry.value}%',
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
                                  for (int i = 0; i < sortedData.keys.length; i++)
                                  Text('${sortedData.keys.toList()[i]} ${sortedData.values.toList()[i].toStringAsFixed(2)}', style: TextStyle(color: getColor(sortedData.keys.toList()[i])),)
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
          maxY: snapshot.data?.values.reduce((a, b) => a + b) ?? 10, // get the max value out of the array with snapshot.data!.values.cast<num>().toList().reduce(max).toDouble()
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

void writeMuscleGoal(String muscle, double value) async{
  Map<String, dynamic> settings = await getAllSettings();
  settings['Muscle Goals'][muscle] = value;
  writeData(settings, path: 'settings',append: false);
}

Future<List> getSetAmounts() async {
  Map data = {};
  Map muscleData = {};
    Map sets = await readData();
    for (var day in sets.keys){
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference

      if (difference.inDays < 7){
        for (var exercise in sets[day]['sets'].keys){
          if (exerciseMuscles.containsKey(exercise)){
            for (int i = 0; i < sets[day]['sets'][exercise].length; i++){
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
    }

    for (String group in muscleGroups.keys){
      for (int i = 0;i < (muscleGroups[group]?.length ?? 0); i++) {
        double muscleNum = (muscleData[muscleGroups[group]?[i]] ?? 0);
          if (data[group] == null) {
            data[group] = 0;
          }
          data[group] += muscleNum;
      }
    }
    List<MapEntry> entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    data = Map.fromEntries(entries);
    Map settings = await getAllSettings();
    return [data,  muscleData, settings];

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
                backgroundColor: const Color(0xFF3F51B5).withValues(alpha: 0.3),
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

