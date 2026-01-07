import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimePieChart extends ConsumerWidget {
  const TimePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: setupData(ref, range: 365),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Center(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(),
              primaryYAxis: NumericAxis(
                labelFormat: '{value}%',
                minimum: 0,
                maximum: 100,
              ),
              legend: const Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: [
                for (MapEntry muscleEntry in snapshot.data!.entries)
                StackedArea100Series<ChartData, DateTime>(
                  dataSource: muscleEntry.value,
                  xValueMapper: (ChartData data, _) => data.year,
                  yValueMapper: (ChartData data, _) => data.value,
                  name: muscleEntry.key,
                  selectionBehavior: SelectionBehavior(enable: true),
                  color: getColor(muscleEntry.key),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}

class ChartData {
  ChartData(this.year, this.value);
  final DateTime year;
  final double value;
}

Future<Map<String, List<ChartData>>> setupData(
  WidgetRef ref, {
  String target = 'Sets',
  int range = -1,
}) async {
  final Map<DateTime, Map<String, double>> byDate = {};

  final data = await readData();
  final customExercisesData = await ref.read(customExercisesProvider.future);

  for (final day in data.keys) {
    final dateRaw = DateTime.parse(day.split(' ').first);
    final date = DateTime(dateRaw.year, dateRaw.month);
    final diff = DateTime.now().difference(date).inDays;
    if (diff > range && range != -1) continue;

    final Map<String, double> dayData = {};

    for (final exercise in data[day]['sets'].keys) {
      final bool isCustom = customExercisesData.containsKey(exercise);
      final exerciseData = isCustom ? customExercisesData[exercise] : exerciseMuscles[exercise];

      if (exerciseData == null) continue;

      for (final set in data[day]['sets'][exercise]) {
        double selector = 0;
        switch (target) {
          case 'Volume':
            selector = double.parse(set['weight'].toString()) * double.parse(set['reps'].toString());
            break;
          case 'Sets':
          default:
            selector = 1;
        }

        void addMuscles(Map<dynamic, dynamic> muscles) {
          for (final entry in muscles.entries) {
            final percent = (entry.value as num).toDouble();
            dayData[entry.key] =
                (dayData[entry.key] ?? 0.0) + selector * (percent / 100.0);
          }
        }


        addMuscles(exerciseData['Primary'] ?? {});
        addMuscles(exerciseData['Secondary'] ?? {});
      }
    }

    byDate[date] = dayData;
  }

  // ---- normalise to 100% and build chart series ----
  final Map<String, List<ChartData>> dataset = {};
  final muscles = byDate.values.expand((e) => e.keys).toSet();

  for (final date in byDate.keys) {
    final total =
        byDate[date]!.values.fold(0.0, (a, b) => a + b);

    for (final muscle in muscles) {
      final value = byDate[date]![muscle] ?? 0;
      dataset.putIfAbsent(muscle, () => []);
      dataset[muscle]!.add(
        ChartData(
          date,
          total == 0 ? 0 : (value / total) * 100,
        ),
      );
    }
  }
  final sortedEntries = dataset.entries.toList()
    ..sort((a, b) {
      final aTotal =
          a.value.fold(0.0, (s, p) => s + p.value);
      final bTotal =
          b.value.fold(0.0, (s, p) => s + p.value);
      return bTotal.compareTo(aTotal);
    });

  dataset
    ..clear()
    ..addEntries(sortedEntries);

  return dataset;
}
