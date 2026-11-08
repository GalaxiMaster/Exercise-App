import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<List<RadarEntry>> buildRadarSections(
  Map<String, dynamic> data,   // whatever your type is
  ChartFilters filters,
  Ref ref,
  {int? depth}
) {
  final percentageData = getPercentageData(
    data,
    filters.chartTarget,
    filters.timeFilter,
    ref, // temporary
    targetMuscleGroup: filters.muscleSelected,
    depth: depth ?? 2,
  );

  final sections = <List<RadarEntry>>[];
  for (final source in percentageData.values) {
    if (source.isEmpty) continue;

    sections.add([
      for (final group in muscleGroups.keys)
        RadarEntry(
          value: muscleGroups[group]!.fold<double>(0, (sum, m) => sum + (source[m] ?? 0)),
        ),
    ]);
  }
  return sections;
}