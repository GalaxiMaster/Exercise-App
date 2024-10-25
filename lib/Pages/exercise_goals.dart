import 'dart:math';

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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([getExerciseStuff(0), getAllSettings()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Map data = snapshot.data![0];
            Map settings = snapshot.data![1];
            return Scaffold(
              appBar: myAppBar(context, 'Workout week thing', button: GestureDetector(
                onTap: (){addExerciseGoal(settings);},
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(child: Icon(Icons.add)),
                ),
              )),
              body: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                        ),
                        Text(
                          'Week',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
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
                                  centerSpaceRadius: 120,
                                  sections: (settings['Exercise Goals'] ?? {}).isNotEmpty 
                                    ? (settings['Exercise Goals'] as Map<String, dynamic>).entries.map<PieChartSectionData>((entry) {
                                        return PieChartSectionData(
                                          color: Colors.blue,
                                          value: entry.value.toDouble(),
                                          radius: 30,
                                          titleStyle: const TextStyle(color: Colors.transparent),
                                        );
                                      }).toList()
                                    : [PieChartSectionData(
                                        color: const Color.fromARGB(255, 82, 82, 82),
                                        value: 100,
                                        radius: 30,
                                        titleStyle: const TextStyle(color: Colors.transparent),
                                      )]
                                )
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Icon(Icons.check, size: 150, color: Colors.green,)
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
                      return ExerciseBox(exercise: MapEntry(exercise, data[exercise] ?? 0), goal: settings['Exercise Goals'][exercise],);
                    }
                  )
                  : const Center(child: Text('No goals set'))
                ],
              )
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      );
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
                    settings['Exercise Goals'][result] = currentValue;
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
  const ExerciseBox({
    super.key,
    required this.exercise, required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          FutureBuilder<bool>(
            future: fileExists("Assets/Exercises/${exercise.key}.png"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Loading state
              } else if (snapshot.hasError) {
                return const Icon(Icons.error); // Show error icon if something went wrong
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              exercise.key,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${exercise.value}/$goal',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );
  }
}

