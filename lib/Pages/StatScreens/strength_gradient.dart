import 'dart:math';

import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/widgets.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class StrengthGradiant extends StatefulWidget {
  const StrengthGradiant({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StrengthGradiantState createState() => _StrengthGradiantState();
}

class _StrengthGradiantState extends State<StrengthGradiant> {
  String timeSelected = 'All Time';
  int range = -1;
  String muscleSelected = 'All Muscles';
  @override
  initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: myAppBar(context, 'Strength Gradient'),
      body: FutureBuilder(
      future: getGradient(range, muscleSelected),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data ${snapshot.error}'));
        } else if (snapshot.hasData) {
          double msAverage = snapshot.data![0];
          List msData = snapshot.data![1].reversed.toList();
          double gradient = double.parse(msAverage.toStringAsFixed(2));
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selectorBox(muscleSelected, 'muscles', (entry) {
                    setState(() {
                      muscleSelected = entry.key;
                    });
                  }, context),
                  selectorBox(timeSelected, 'time', (entry) {
                    setState(() {
                      timeSelected = entry.key;
                      range = entry.value;
                    });
                  }, context),
                ],
              ),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: ThemeColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Center(
                    child: GradientText(
                      'Increase: $gradient%',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                      colors: const [
                        Colors.blue,
                        Colors.yellow,
                      ],
                      gradientType: GradientType.radial,
                      radius: 7,
                    ),
                  ),
                ),
              ),
              const Divider(thickness: .35,),
              Expanded(
                child: ListView.builder(
                  itemCount: msData.length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => ExerciseScreen(exercises: [msData[index].key])
                                )
                              );
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300), // Adjust width as needed
                              child: Text(
                                '${msData[index].key}: ',
                                style: const TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Text(
                            '${msData[index].value.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              )
            ],
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
      ),
    );
  }
}
Future<List> getGradient(int range, String muscleGroup) async{
  Map data = await readData();
  Map exercisesMap = {};
  for (String day in data.keys){
    Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
    int diff = difference.inDays;
    if (diff <= range || range == -1){
      for (String exercise in data[day]['sets'].keys){
        for (String muscle in (muscleGroups[muscleGroup] ?? ['muscle'])){
          if ((exerciseMuscles[exercise]?['Primary'].containsKey(muscle) ?? false) || muscleGroup == 'All Muscles'){ //  || (exerciseMuscles[exercise]?['Secondary'].containsKey(muscle) ?? false)
            // for (Map set in data[day]['sets'][exercise]){
            List sets = data[day]['sets'][exercise];
            String target = 'weight';
            (exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'Weighted' ? target = 'reps' : null;
            sets.sort((a, b) => double.parse(a[target].toString()).compareTo(double.parse(b[target].toString())));
            Map set = sets[sets.length-1];
            if (!exercisesMap.containsKey(exercise)){
              exercisesMap[exercise] = [];
            }
            // Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0]));
            exercisesMap[exercise].add(set);
          // }
          }
        }
      }
    }
  }
  Map ms = {};
  for (String exercise in exercisesMap.keys){
    if (exercisesMap[exercise].length > 1){
      List<num> x = [];
      List<num> y = [];
      exercisesMap[exercise] = exercisesMap[exercise].reversed.toList();
      for (var pair in exercisesMap[exercise]!) {
        y.add((exerciseMuscles[exercise]?['type'] ?? 'Weighted') == 'Weighted' ?  double.parse(pair['weight'].toString()) : double.parse(pair['reps'].toString())); // x value is the first element
      }
      x = List.generate(y.length, (index) => index);

      int n = y.length;
      if (n != 0){
        // num minValue = x.reduce(min);
        // num maxValue = x.reduce(max);

        // double m = minValue/maxValue;

        FlSpot a = FlSpot(x[0].toDouble(), y[0].toDouble());
        FlSpot b = FlSpot(x[x.length-1].toDouble(), y[y.length-1].toDouble());
        double m = 0;
        if (a.y < 0 && b.y < 0){
          m = ((b.y-a.y).abs()/(min(a.y.abs(), b.y.abs())))*100;
        }else{
          m = ((b.y-a.y)/a.y.abs())*100;
        }
        ms[exercise] = m;

      }
    }
    
  }
double mAverage = 0;
List filteredData = [];

if (ms.isNotEmpty) {
  // Sort ms by values
  var sortedEntries = ms.entries.toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  var sortedValues = sortedEntries.map((entry) => entry.value).toList();

  // Calculate Q1, Q3, and IQR
  num q1 = sortedValues[(sortedValues.length * 0.25).floor()];
  num q3 = sortedValues[(sortedValues.length * 0.75).floor()];
  num iqr = q3 - q1;

  // Adjust bounds for outliers
  num lowerBound = q1 - 2.5 * iqr;
  num upperBound = q3 + 2.5 * iqr;

  // Filter entries within bounds
  filteredData = sortedEntries
      .where((entry) => entry.value >= lowerBound && entry.value <= upperBound)
      .toList();

  // Calculate the average
  if (filteredData.isNotEmpty) {
    mAverage = filteredData
            .map((entry) => entry.value)
            .reduce((a, b) => a + b) /
        ms.length;
  }
}


  return [mAverage, filteredData];
}

num toNum(weight) {
  return int.tryParse(weight.toString()) ?? double.parse(weight.toString());
}