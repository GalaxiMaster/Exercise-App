import 'dart:math';
import 'dart:ui';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ExerciseGoals extends ConsumerStatefulWidget {
  const ExerciseGoals({super.key});   
    @override
  // ignore: library_private_types_in_public_api
  _ExerciseGoalsState createState() => _ExerciseGoalsState();
}

class _ExerciseGoalsState extends ConsumerState<ExerciseGoals> {
  int weeksAgo = 0;
  late PageController pageController;
  final ValueNotifier<int> headerState = ValueNotifier(0);
  final ValueNotifier<Map<String, dynamic>> listState = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> chartState = ValueNotifier({});
  late Map<String, dynamic> settings;

  late List<PieChartSectionData> graphSections;
  late double percentageComplete;
  @override
  initState(){
    super.initState();
    pageController = PageController(initialPage: 99999);
    pageController.addListener(() {
      if (pageController.page! > 99999) {
        pageController.jumpToPage(99999);
      }
    });
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
    headerState.dispose();
    listState.dispose();
  }
   void updateHeader(int weeks) {
    headerState.value = weeks; // Update Header state
  }

  void updateList(Map<String, dynamic> newState) {
    listState.value = newState; // Update ListThing state
  }
  void updateChart(Map<String, dynamic> newState) {
    chartState.value = newState; // Update chart state
  }

  List calculatePieSections(Map settings, Map data) {
    List<PieChartSectionData> graphSections = [];
    double notComplete = 0;
    double complete = 0;

    for (String exercise in settings['Exercise Goals'].keys) {
      graphSections.add(PieChartSectionData(
        color: Color.fromRGBO(settings['Exercise Goals'][exercise][1][0],
            settings['Exercise Goals'][exercise][1][1], settings['Exercise Goals'][exercise][1][2], 1),
        value: clampDouble(
            (data[exercise] ?? 0).toDouble(), 0, settings['Exercise Goals'][exercise][0].toDouble()),
        radius: 30,
        titleStyle: const TextStyle(color: Colors.transparent),
      ));
      graphSections.add(PieChartSectionData(
        color: Color.fromRGBO(settings['Exercise Goals'][exercise][1][0],
            settings['Exercise Goals'][exercise][1][1], settings['Exercise Goals'][exercise][1][2], 0.2),
        value: clampDouble(
            settings['Exercise Goals'][exercise][0].toDouble() - (data[exercise] ?? 0), 0, 100),
        radius: 30,
        titleStyle: const TextStyle(color: Colors.transparent),
      ));
      complete += data[exercise] ?? 0;
      notComplete += settings['Exercise Goals'][exercise][0].toDouble() - (data[exercise] ?? 0);
    }
    double percentageComplete = complete / (notComplete + complete);
    return [graphSections, percentageComplete];
  }
  
  @override
  Widget build(BuildContext context) {
    final allDataProvider = Provider.family<AsyncValue<Map<String, Map>>, int>((ref, weeksAgo) {
      final workoutAsyncValue = ref.watch(workoutDataProvider);
      settings = ref.watch(settingsProvider).value ?? {};

      return workoutAsyncValue.whenData((data) {
        DateTime now = DateTime.now();
        DateTime date = now.subtract(Duration(days: weeksAgo * 7));
        String weekStr = DateFormat('MMM dd').format(findMonday(date));
        Map<String, dynamic> exerciseData = {};
        for (String day in data.keys) {
          if (DateFormat('MMM dd').format(findMonday(DateTime.parse(day.split(' ')[0]))) == weekStr){
            for (String exercise in data[day]['sets'].keys){
              exerciseData[exercise] = (exerciseData[exercise] ?? 0) + 1;
            }
          }
        }

        List result = calculatePieSections(settings, exerciseData);
        graphSections = result[0];
        percentageComplete = result[1];

        listState.value = {
          'settings': settings,
          'data': exerciseData,
        };
        updateChart({
          'settings': settings,
          'sections': graphSections,
          'percent': percentageComplete,
        });

        graphSections = [];
        percentageComplete = 0;
        return {};
      });
    });
    final allDataAsync = ref.watch(allDataProvider(weeksAgo));
    return allDataAsync.when(
      data: (data){
        return Scaffold(
          appBar: myAppBar(context, 'Exercise goals',
          button: GestureDetector(
            onTap: () {
              addExerciseGoal(settings);
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(child: Icon(Icons.add)),
            ),
          )),
          body: Column(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: headerState,
                builder: (context, value, _) {
                  return Header(
                    weeksAgo: value,
                    onArrow: ({required int delta}){
                      if (pageController.hasClients) {
                          pageController.animateToPage(
                            pageController.page!.round() + delta, 
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                    },
                  );
                },
              ),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: chartState,
                builder: (context, chartData, _) {
                  return CenterChart(
                    pageController: pageController, 
                    settings: chartData['settings'], 
                    graphSections: chartData['sections'], 
                    percentageComplete: chartData['percent'], 
                    addWeeksAgo: (direction){
                      setState(() {
                        weeksAgo += direction;
                      });
                      updateHeader(weeksAgo);
                      // fetchNewData();
                    },
                  );
                },
              ),
              const Divider(),
              Expanded(
                child: ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: listState,
                  builder: (context, listData, _) {
                    return ListThing(
                      settings: listData['settings'] ?? {},
                      data: listData['data'] ?? {}, 
                      updateSettings: updatSettings
                    );
                  },
                ),
              ),
              ],
            )
          );
      },
      error: (Object error, StackTrace stackTrace) => Text('Error fetching settings $error'), 
      loading: () => CircularProgressIndicator()
    );
  }
  void updatSettings(Map newState){
    ref.read(settingsProvider.notifier).updateValue('Exercise Goals', newState);
  }

  void addExerciseGoal(Map<String, dynamic> settings) async{
    List? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutList(setting: 'choose'))
    );
    if (result == null) return;

    String exercise = result[0];
    int? currentValue = 0;
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
                currentValue = int.tryParse(value);
              },
            ),
          ),
          
          actions: <Widget>[
            TextButton(
              child: const Center(child: Text('OK', style: TextStyle(color: Colors.blue),)),
              onPressed: () {
                if (currentValue == null) return;
                Navigator.of(context).pop(); // Dismiss the dialog
                debugPrint('$exercise: $currentValue');
                var generatedColor = Random().nextInt(Colors.primaries.length);
                var color = Colors.primaries[generatedColor];
                setState(() {
                  settings['Exercise Goals'][exercise] = [currentValue, [color.redVal, color.greenVal, color.blueVal]];
                  updateList({
                    'settings': settings, // Real settings
                    'data': listState.value['data'],     // Real data
                  });
                  List results = calculatePieSections(settings, listState.value['data']);
                  updateChart({
                      'settings': settings, // Real settings
                      'sections': results[0],
                      'percent': results[1],    
                  });
                });
                ref.read(settingsProvider.notifier).updateValue('Exercise Goals', settings['Exercise Goals']);
              },
            ),
          ],
        );
      }
    );
  }
}

class CenterChart extends StatelessWidget {
  const CenterChart({
    super.key,
    required this.pageController,
    required this.settings,
    required this.graphSections,
    required this.percentageComplete, 
    required this.addWeeksAgo,
  });

  final PageController pageController;
  final Map settings;
  final List<PieChartSectionData> graphSections;
  final double percentageComplete;
  final ValueChanged<int> addWeeksAgo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: pageController,
        onPageChanged: (value) {
          if (pageController.hasClients && pageController.page != null) {
            double diff = pageController.page! % 1;
            int direction;
            if (diff > 0.5){
              direction = -1;
            }else{
              direction = 1;
            }
            addWeeksAgo(direction);
          }
        },
        itemBuilder: (context, index) {
          return Row(children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -87,
                        centerSpaceRadius: 100,
                        sections: (settings['Exercise Goals'] ?? {}).isNotEmpty
                            ? graphSections.reversed.toList()
                            : [
                                PieChartSectionData(
                                  color: const Color.fromARGB(255, 30, 25, 25),
                                  value: 100,
                                  radius: 30,
                                  titleStyle: const TextStyle(color: Colors.transparent),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: TickFillWidget(
                              fillPercentage: percentageComplete,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]);
              },
            ),
          );
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
              future: fileExists("assets/Exercises/${exercise.key}.png"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else if (snapshot.hasData && snapshot.data!) {
                  return Image.asset(
                    "assets/Exercises/${exercise.key}.png",
                    height: 50,
                    width: 50,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/profile.svg",
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
                      value: exercise.value / (goal > 0 ? goal : 1),
                      minHeight: 5,
                      backgroundColor: color.withValues(alpha: .2),
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

  const TickFillWidget({super.key, required this.fillPercentage});

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
      ..color = Colors.green.shade700.withValues(alpha: 0.3) // Greyed-out green
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

class ListThing extends StatelessWidget {
  final Map<String, dynamic> settings;
  final Map data;
  final Function updateSettings;
  const ListThing({required this.settings, required this.data, super.key, required this.updateSettings});

  @override
  Widget build(BuildContext context) {
    return settings['Exercise Goals'].isNotEmpty
        ? ListView.builder(
            itemCount: settings['Exercise Goals'].keys.length,
            itemBuilder: (context, index) {
              String exercise = settings['Exercise Goals'].keys.toList()[index];
              return ExerciseBox(
                exercise: MapEntry(exercise, data[exercise] ?? 0),
                goal: settings['Exercise Goals'][exercise][0],
                color: Color.fromRGBO(
                  settings['Exercise Goals'][exercise][1][0],
                  settings['Exercise Goals'][exercise][1][1],
                  settings['Exercise Goals'][exercise][1][2],
                  1,
                ),
                settings: settings,
                functions: {'Edit': editGoal, 'Delete': deleteGoal},
              );
            },
          )
        : const Center(child: Text('No goals set'));
  }
  void deleteGoal(Map<String, dynamic> settings, String exercise){
    settings['Exercise Goals'].remove(exercise);
    updateSettings(settings);
  }
  void editGoal(Map<String, dynamic> settings, String exercise, int currentValue){
    List value = settings['Exercise Goals'][exercise]; // TODO wtf
    settings['Exercise Goals'][exercise] = [currentValue, value[1]];
    updateSettings(settings['Exercise Goals']);
  }
}