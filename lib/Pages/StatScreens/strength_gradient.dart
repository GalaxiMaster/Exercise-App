import 'dart:math';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/widgets.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class StrengthGradiant extends ConsumerWidget {
  const StrengthGradiant({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataProvider = ref.read(strengthGradientProvider);
    
    return Scaffold(
      appBar: myAppBar(context, 'Strength Gradient'),
      body: dataProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {
          double msAverage = data[0];
          List msData = data[1].reversed.toList();
          double gradient = double.parse(msAverage.toStringAsFixed(2));
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selectorBox(
                    ref.watch(chartFilterProvider).muscleSelected, 
                    'muscles', 
                    (entry) => ref.read(chartFilterProvider.notifier).setMuscle(entry.key), 
                    context
                  ),
                  selectorBox(
                    ref.watch(chartFilterProvider).timeLabel, 
                    'time', 
                    (entry) => ref.read(chartFilterProvider.notifier).setRange(entry.value, entry.key), 
                    context
                  ),
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
        },
      ),
    );
  }
}
final strengthGradientProvider = Provider.autoDispose<AsyncValue<List>>((ref) {
  final rawDataAsync = ref.watch(workoutDataProvider);
  final filters = ref.watch(chartFilterProvider);

  return rawDataAsync.whenData((data) {
    Map exercisesMap = {};
    for (String day in data.keys){
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
      int diff = difference.inDays;
      if (diff <= filters.range || filters.range == -1){
        for (String exercise in data[day]['sets'].keys){
          for (String muscle in (muscleGroups[filters.muscleSelected] ?? ['muscle'])){
            if ((exerciseMuscles[exercise]?['Primary'].containsKey(muscle) ?? false) || filters.muscleSelected == 'All Muscles'){ //  || (exerciseMuscles[exercise]?['Secondary'].containsKey(muscle) ?? false)
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
  });
});

final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});