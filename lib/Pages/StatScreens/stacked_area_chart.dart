import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimeCharts extends ConsumerWidget {
  final int range;
  final String musclesSelected;
  final String target;
  final String selectedGraph;
  const TimeCharts({super.key, required this.range, required this.musclesSelected, required this.target, required this.selectedGraph});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataAsync = ref.watch(chartViewModelProvider);
    return chartDataAsync.when(
      data: (data) {
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
              for (MapEntry<String, List<ChartData>> muscleEntry in data.entries)
              buildSeries(selectedGraph, muscleEntry)
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error loading data $error')),
    );
  }
}

class ChartData {
  ChartData(this.year, this.value);
  final DateTime year;
  final double value;
}

final chartViewModelProvider = Provider.autoDispose<AsyncValue<Map<String, List<ChartData>>>>((ref) {
  final filters = ref.watch(chartFilterProvider);
  final rawDataAsync = ref.watch(workoutDataProvider);
  final customExercisesData = ref.read(customExercisesProvider).value ?? {};

  return rawDataAsync.whenData((data) {
    final Map<DateTime, Map<String, double>> byDate = {};

    for (final day in data.keys) {
      final dateRaw = DateTime.parse(day.split(' ').first);
      final date = DateTime(dateRaw.year, dateRaw.month);
      final diff = DateTime.now().difference(date).inDays;
      if (diff > filters.range && filters.range != -1) continue;

      final Map<String, double> dayData = {};

      for (final exercise in data[day]['sets'].keys) {
        final bool isCustom = customExercisesData.containsKey(exercise);
        final exerciseData = isCustom ? customExercisesData[exercise] : exerciseMuscles[exercise];

        if (exerciseData == null) continue;

        for (final set in data[day]['sets'][exercise]) {
          double selector = 0;
          switch (filters.chartTarget) {
            case 'Volume':
              selector = double.parse(set['weight'].toString()) * double.parse(set['reps'].toString());
            case 'kg':
              selector = double.parse(set['weight'].toString());
            case 'Sets':
              selector = 1;
            default:
              selector = 1;
          }

          void addMuscles(Map<dynamic, dynamic> muscles) {
            for (final entry in muscles.entries) {
              final percent = (entry.value as num).toDouble();
              dayData[entry.key] = (dayData[entry.key] ?? 0.0) + selector * (percent / 100.0);
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
  });
});

CartesianSeries<ChartData, DateTime> buildSeries(
  String type,
  MapEntry<String, List<ChartData>> e,
) {
  final common = _CommonSeries(
    data: e.value,
    name: e.key,
    color: getColor(e.key),
  );

  return switch (type) {
    '100p Area Chart' => StackedArea100Series(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),

    'Spline Area' => SplineAreaSeries(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),
    'Spline Line' => SplineSeries(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),
    'Stacked Line' => StackedLineSeries(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),
    'Step Area' => StepAreaSeries(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),
    _ => StackedColumnSeries(
      dataSource: common.data,
      xValueMapper: common.x,
      yValueMapper: common.y,
      name: common.name,
      color: common.color,
    ),
  };
}

class _CommonSeries {
  final List<ChartData> data;
  final String name;
  final Color color;

  const _CommonSeries({
    required this.data,
    required this.name,
    required this.color,
  });

  DateTime x(ChartData d, _) => d.year;
  num y(ChartData d, _) => d.value;
}
