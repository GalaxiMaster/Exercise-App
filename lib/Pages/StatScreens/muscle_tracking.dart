import 'package:exercise_app/Providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

class MuscleTracking extends ConsumerStatefulWidget {
  const MuscleTracking({super.key});

  @override
  MuscleTrackingState createState() => MuscleTrackingState();
}

class MuscleTrackingState extends ConsumerState<MuscleTracking> {
  int weeksAgo = 0;
  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(chartViewModelProvider);

    return Scaffold(
      appBar: myAppBar(context, 'Muscle Tracking'),
      body: dataProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {
          final muscleGoals = ref.watch(settingsProvider).value?['Muscle Goals'];
          return SingleChildScrollView(
            child: Column(
              children: [
                Header(
                  weeksAgo: weeksAgo, 
                  findMondayDate: false,
                  onArrow: ({required int delta}){
                    setState(() {
                      weeksAgo -= delta;
                    });
                  }
                ),
                FlexibleMuscleLayout(
                  data: data[0]?[weeksAgo],
                  normalData: data[1]?[weeksAgo] ?? {},
                  goals: muscleGoals!,
                  weeksAgo: weeksAgo,
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

class FlexibleMuscleLayout extends StatefulWidget {
  final Map data;
  final Map normalData;
  final Map goals;
  final int weeksAgo;

  const FlexibleMuscleLayout({super.key, required this.data, required this.normalData, required this.goals, required this.weeksAgo});

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
                goal: widget.goals[muscle],
                onTap: () => setState(() => expandedMuscle = null),
                data: getMuscleSpecifics(widget.normalData, muscle),
                weeksAgo: widget.weeksAgo,
              );
            } else {
              return SetProgressTile(
                muscle: muscle,
                value: value,
                goal: widget.goals[muscle],
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

class SetProgressTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                                    ref.read(settingsProvider.notifier).updateMuscleGoal(muscle, currentValue);
                                    Navigator.of(context).pop(); // Dismiss the dialog
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
                  child: CaloriesSpeedometer(value: value, maxValue: goal),
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
  final int weeksAgo;
  
  const ExpandedSetProgressTile({
    super.key,
    required this.muscle,
    required this.value,
    required this.goal,
    required this.onTap, 
    required this.data, 
    required this.weeksAgo,
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
                      child: WeeklyProgressChart(muscle: muscle, weeksAgo: weeksAgo,),
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

class WeeklyProgressChart extends ConsumerWidget {
  final String muscle;
  final int weeksAgo;
  const WeeklyProgressChart({super.key, required this.muscle, required this.weeksAgo});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, double> data = ref.watch(weeklyMuscleDataProvider.select((data){
      return data[weeksAgo]?[muscle] ?? {};
    }));
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.isNotEmpty ? data.values.reduce((a, b) => a + b) : 0, // get the max value out of the array with data!.values.cast<num>().toList().reduce(max).toDouble()
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
          barGroups: data.entries.toList().asMap().entries.map((entry) {
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
  }
}

final weeklyMuscleDataProvider = Provider<Map>((ref) {
  final dataAsync = ref.watch(workoutDataProvider);
  final Map customExercisesData = ref.read(customExercisesProvider).value ?? {};

  return dataAsync.maybeWhen(
    data: (data) {
      Map<int, Map<String, Map<String, double>>> groupedWeeklyData = {};

      for (var day in data.keys){
        Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
        int weekRef = difference.inDays ~/ 7;

        groupedWeeklyData[weekRef] ??= {};
        for (var exercise in data[day]['sets'].keys){
          bool isCustom = customExercisesData.containsKey(exercise);
          Map exerciseData = {};

          if (isCustom){
            exerciseData = customExercisesData[exercise];
          } else {
            exerciseData = exerciseMuscles[exercise] ?? {};
          }
          String dayName = DateFormat('EEE').format(DateTime.parse(day.split(' ')[0]));

          if (exerciseData.isEmpty) continue;

          Map<String, int> allMuscles = {...(exerciseData['Primary'] ?? {}), ...(exerciseData['Secondary'] ?? {})};

          for (int i = 0; i < data[day]['sets'][exercise].length; i++){
            for (MapEntry muscle in allMuscles.entries){
              String? category = muscleGroups.entries
                .firstWhere((entry) => entry.value.contains(muscle.key), orElse: () => MapEntry('', []))
                .key;
              groupedWeeklyData[weekRef]![category] ??= {'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0};
              groupedWeeklyData[weekRef]![category]![dayName] = (groupedWeeklyData[weekRef]?[category]?[dayName] ?? 0) + 1 * (muscle.value!/100);
            }
          }
        }
      }
      return groupedWeeklyData;
    },
    orElse: () => {},
  );
});

class CaloriesSpeedometer extends StatelessWidget {
  final double value;
  final double maxValue;

  const CaloriesSpeedometer({
    super.key,
    required this.value,
    required this.maxValue,
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
                progress: value / maxValue,
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
                  '${value.toStringAsFixed(2)} of',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$maxValue sets',
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

final chartViewModelProvider = Provider<AsyncValue<List>>((ref) {
  final rawDataAsync = ref.watch(workoutDataProvider);
  final Map customExercisesData = ref.read(customExercisesProvider).value ?? {};

  return rawDataAsync.whenData((data) {
    Map groupedData = {}; // muscleData but grouped into their higher level muscle group
    Map muscleData = {};
    int maxWeeksAgo = 0;
    for (var day in data.keys){
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
      int weekRef = difference.inDays ~/ 7;
      maxWeeksAgo = math.max(maxWeeksAgo, weekRef);

      muscleData[weekRef] ??= {};
      for (var exercise in data[day]['sets'].keys){
        bool isCustom = customExercisesData.containsKey(exercise);
        Map exerciseData = {};

        if (isCustom){
          exerciseData = customExercisesData[exercise];
        } else {
          exerciseData = exerciseMuscles[exercise] ?? {};
        }

        if (exerciseData.isEmpty) continue;

        for (int i = 0; i < data[day]['sets'][exercise].length; i++){
          for (var muscle in (exerciseData['Primary'] ?? {}).keys){
            if (muscleData[weekRef].containsKey(muscle)){
              muscleData[weekRef][muscle] += 1*(exerciseData['Primary']![muscle]!/100);
            } else{
              muscleData[weekRef][muscle] = 1*(exerciseData['Primary']![muscle]!/100);
            }
          }
          for (var muscle in (exerciseData['Secondary'] ?? {}).keys){
            if (muscleData[weekRef].containsKey(muscle)){
              muscleData[weekRef][muscle] += 1*(exerciseData['Secondary']![muscle]!/100);
            } else{
              muscleData[weekRef][muscle] = 1*(exerciseData['Secondary']![muscle]!/100);
            }
          }
        }
      }
    }
    int buffer = 5; // default 5 buffer
    for (int weekRef = 0; weekRef < (maxWeeksAgo + buffer); weekRef++) {
      groupedData[weekRef] = {};
      for (String group in muscleGroups.keys){
        for (int i = 0; i < (muscleGroups[group]?.length ?? 0); i++) {
          double muscleNum = (muscleData[weekRef]?[muscleGroups[group]?[i]] ?? 0);
            if (groupedData[weekRef][group] == null) {
              groupedData[weekRef][group] = 0;
            }
            groupedData[weekRef][group] += muscleNum;
        }
      }
      List<MapEntry> entries = groupedData[weekRef].entries.toList();
      entries.sort((a, b) => b.value.compareTo(a.value)); // Sorts by Desc order
      groupedData[weekRef] = Map.fromEntries(entries);
    }

    return [groupedData,  muscleData];
  });
});