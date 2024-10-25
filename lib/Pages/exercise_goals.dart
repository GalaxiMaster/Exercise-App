import 'dart:math';
import 'dart:ui';

import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ExerciseGoals extends StatefulWidget {
  const ExerciseGoals({super.key});   
    @override
  // ignore: library_private_types_in_public_api
  _ExerciseGoalsState createState() => _ExerciseGoalsState();
}

class _ExerciseGoalsState extends State<ExerciseGoals> {
  int weeksAgo = 0;

  @override
  Widget build(BuildContext context) {
    // writeData({}, path: 'settings', append: false);
    return FutureBuilder(
        future: Future.wait([getExerciseStuff(weeksAgo), getAllSettings()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map data = snapshot.data![0];
            Map settings = snapshot.data![1];
            List<PieChartSectionData> graphSections = [];
            double notComplete = 0;
            double complete = 0;

            for (String exercise in settings['Exercise Goals'].keys){
              graphSections.add(PieChartSectionData(
                color: Color.fromRGBO(settings['Exercise Goals'][exercise][1][0], settings['Exercise Goals'][exercise][1][1], settings['Exercise Goals'][exercise][1][2], 1),
                value: clampDouble((data[exercise] ?? 0).toDouble(), 0, settings['Exercise Goals'][exercise][0].toDouble()),
                radius: 30,
                titleStyle: const TextStyle(color: Colors.transparent),
              ));
              graphSections.add(PieChartSectionData(
                color: Color.fromRGBO(settings['Exercise Goals'][exercise][1][0], settings['Exercise Goals'][exercise][1][1], settings['Exercise Goals'][exercise][1][2], 0.2),
                value: clampDouble(settings['Exercise Goals'][exercise][0].toDouble() - (data[exercise] ?? 0), 0, 100),
                radius: 30,
                titleStyle: const TextStyle(color: Colors.transparent),
              ));
              complete += data[exercise] ?? 0;
              notComplete += settings['Exercise Goals'][exercise][0].toDouble() - (data[exercise] ?? 0);
            }
            double percentageComplete = complete/notComplete;
            DateTime now = DateTime.now();
            DateTime date = now.subtract(Duration(days: weeksAgo * 7));
            String weekStr = DateFormat('MMM dd').format(findMonday(date));

            return Scaffold(
              appBar: myAppBar(context, 'Exercise goals', button: GestureDetector(
                onTap: (){addExerciseGoal(settings);},
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(child: Icon(Icons.add)),
                ),
              )),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              weeksAgo += 1;
                            });
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        Text(
                          weeksAgo == 0 ? 'This week' : weekStr,
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              if (weeksAgo > 0){weeksAgo -= 1;}
                            });
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 310,
                          child: Stack(
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: -87,
                                  centerSpaceRadius: 100,
                                  sections: (settings['Exercise Goals'] ?? {}).isNotEmpty 
                                    ? graphSections.reversed.toList()
                                    : [PieChartSectionData(
                                        color: const Color.fromARGB(255, 82, 82, 82),
                                        value: 100,
                                        radius: 30,
                                        titleStyle: const TextStyle(color: Colors.transparent),
                                      )]
                                )
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: TickFillWidget(fillPercentage: percentageComplete,)
                              )
                            ]
                          ),
                        ),
                      ),
                    ]
                  ),
                  const Divider(),
                  settings['Exercise Goals'].isNotEmpty ?
                  ListView.builder(
                    itemCount: settings['Exercise Goals'].keys.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      String exercise = settings['Exercise Goals'].keys.toList()[index];
                      return ExerciseBox(
                        exercise: MapEntry(exercise, data[exercise] ?? 0), 
                        goal: settings['Exercise Goals'][exercise][0], 
                        color: Color.fromRGBO(
                          settings['Exercise Goals'][exercise][1][0], 
                          settings['Exercise Goals'][exercise][1][1], 
                          settings['Exercise Goals'][exercise][1][2], 1), 
                        settings: settings, 
                        functions: {'Edit': editGoal, 'Delete': deleteGoal},
                      );
                    }
                  )
                  : const Center(child: Text('No goals set')),
                   
                ],
              )
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      );
  }
  void deleteGoal(settings, exercise){
    setState(() {
      settings['Exercise Goals'].remove(exercise);
    });
    writeData(settings, path: 'settings',append: false);
  }
  void editGoal(Map settings, String exercise, int currentValue){
    debugPrint('called');
    List value = settings['Exercise Goals'][exercise];
    value[0] = currentValue;
    setState(() {
      settings['Exercise Goals'][exercise] = value;
    });
    writeData(settings, path: 'settings',append: false);
  }

  void addExerciseGoal(settings) async{
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutList(setting: 'choose'))
    );
    if(result != null){
      int currentValue = 0;
      showDialog(
        // ignore: use_build_context_synchronously
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
                      if (0 > number  && number > 100) {
                        return oldValue;
                      }
                      if (text.contains('.')) {
                        return oldValue;
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
                initialValue: '',
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
                  currentValue = int.tryParse(value) ?? currentValue;
                },
              ),
            ),
            
            actions: <Widget>[
              TextButton(
                child: const Center(child: Text('OK', style: TextStyle(color: Colors.blue),)),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  debugPrint('$result: $currentValue');
                  var generatedColor = Random().nextInt(Colors.primaries.length);
                  var color = Colors.primaries[generatedColor];
                  setState(() {
                    settings['Exercise Goals'][result] = [currentValue, [color.red, color.green, color.blue]];
                  });
                  writeData(settings, path: 'settings',append: false);
                },
              ),
            ],
          );
        }
      );
    }
  }
  
  Future<Map> getExerciseStuff(int weeksAgo) async {
    DateTime now = DateTime.now();
    DateTime date = now.subtract(Duration(days: weeksAgo * 7));
    String weekStr = DateFormat('MMM dd').format(findMonday(date));
    Map data = await readData();
    Map exerciseData = {};
    for (String day in data.keys){
      if (DateFormat('MMM dd').format(findMonday(DateTime.parse(day.split(' ')[0]))) == weekStr){
        for (String exercise in data[day]['sets'].keys){
          exerciseData[exercise] = (exerciseData[exercise] ?? 0) + 1;
        }
      }
    }

    return exerciseData;
  }
}

class ExerciseBox extends StatelessWidget {
  final MapEntry exercise;
  final int goal;
  final Color color;
  final Map settings;
  final Map<String, Function> functions;
  const ExerciseBox({
    super.key,
    required this.exercise,
    required this.goal,
    required this.color,
    required this.settings,
    required this.functions,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: 150,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      int currentValue = 0;
                      // Close the bottom sheet first
                      Navigator.pop(context);
                      
                      // Then show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
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
                                      int? number = int.tryParse(text);
                                      if (number == null) {
                                        return oldValue;
                                      }
                                      if (number < 0 || number > 100) {
                                        return oldValue;
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
                                initialValue: goal.toString(), // Set initial value to current goal
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Enter value...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  currentValue = int.tryParse(value) ?? currentValue;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  if (currentValue > 0) {
                                    functions['Edit']!(settings, exercise.key, currentValue);
                                  }
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Goal', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      functions['Delete']!(settings, exercise.key);
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Goal', 
                            style: TextStyle(fontSize: 24, color: Colors.red)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            FutureBuilder<bool>(
              future: fileExists("Assets/Exercises/${exercise.key}.png"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else if (snapshot.hasData && snapshot.data!) {
                  return Image.asset(
                    "Assets/Exercises/${exercise.key}.png",
                    height: 50,
                    width: 50,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "Assets/profile.svg",
                      height: 35,
                      width: 35,
                    ),
                  );
                }
              },
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    exercise.key,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 15,
                    width: 250,
                    child: LinearProgressIndicator(
                      value: exercise.value / goal,
                      minHeight: 5,
                      backgroundColor: color.withOpacity(.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${exercise.value}/$goal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TickFillWidget extends StatelessWidget {
  final double fillPercentage; // Should be between 0.0 and 1.0

  TickFillWidget({required this.fillPercentage});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(125, 125), // Adjust size as needed
      painter: TickPainter(fillPercentage),
    );
  }
}

class TickPainter extends CustomPainter {
  final double fillPercentage;
  TickPainter(this.fillPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.green.shade700.withOpacity(0.3) // Greyed-out green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final Paint fillPaint = Paint()
      ..color = Colors.green.shade400 // Brighter green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    // Define the tick path
    final Path tickPath = Path();
    tickPath.moveTo(size.width * 0.2, size.height * 0.5);
    tickPath.lineTo(size.width * 0.4, size.height * 0.7);
    tickPath.lineTo(size.width * 0.8, size.height * 0.3);

    // Draw background tick (greyed-out)
    canvas.drawPath(tickPath, backgroundPaint);

    // Measure the total length of the path
    PathMetrics pathMetrics = tickPath.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      // Extract the portion of the tick based on fillPercentage
      Path partialPath = pathMetric.extractPath(
        0.0, 
        pathMetric.length * fillPercentage,
      );
      // Draw the filled portion
      canvas.drawPath(partialPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(TickPainter oldDelegate) => oldDelegate.fillPercentage != fillPercentage;
}
