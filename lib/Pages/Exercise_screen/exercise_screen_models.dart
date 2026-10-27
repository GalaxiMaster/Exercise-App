import 'dart:math' as math;
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart'; // ExerciseType
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual_models.dart'; // DayWorkout, DayExercise, MuscleProfile
import 'package:exercise_app/models/workout_stats.dart'; // WorkoutDetails
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum ScaleSetting {
  equalIntervals,
  scaled,
}

/// What the chart plots. [key] is the string the chart filter stores.
enum ChartMetric {
  weight('weight', 'Weight'),
  volume('volume', 'Volume'),
  reps('reps', 'Reps'),
  oneRepMax('1rm', '1rm');

  const ChartMetric(this.key, this.label);

  final String key;
  final String label;

  static ChartMetric fromKey(String? key) => ChartMetric.values.firstWhere(
    (m) => m.key == key,
    orElse: () => ChartMetric.weight,
  );
}

/// The exercises a screen contains
class ExerciseKey {
  ExerciseKey(Iterable<String> ids) : ids = List.unmodifiable(ids);

  final List<String> ids;

  @override
  bool operator == (Object other) => other is ExerciseKey && listEquals(ids, other.ids);

  @override
  int get hashCode => Object.hashAll(ids);
}

/// Everything the chart provider depends on that the page controls.
class ChartRequest {
  ChartRequest(this.exercises, this.scale);

  final ExerciseKey exercises;
  final ScaleSetting scale;

  @override
  bool operator ==(Object other) =>
      other is ChartRequest && other.exercises == exercises && other.scale == scale;

  @override
  int get hashCode => Object.hash(exercises, scale);
}

/// A point the user touched on the chart: which exercise, on which day.
typedef ChartSelection = ({String exercise, String dayKey});

/// Reads the saved per-exercise multipliers (strings in settings). Anything
/// that isn't a number is ignored, so that exercise uses 1.0.
Map<String, double> parseMultipliers(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, double>{};
  for (final entry in raw.entries) {
    final value = double.tryParse(entry.value?.toString() ?? '');
    if (value != null) result[entry.key.toString()] = value;
  }
  return result;
}

/// "60", "62.5", "12.34": whole numbers without ".0", at most 2 decimals.
String formatNumber(num value) {
  if (!value.isFinite) return '0';
  final rounded = double.parse(value.toStringAsFixed(2));
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// The workout keys that belong to [date] ("yyyy-MM-dd"). A key is its date,
List<String> dayKeysForDate(Iterable keys, String date) => [
  for (final key in keys)
    if (key.toString().split(' ').first == date) key.toString(),
];

class SetStat {
  const SetStat({
    required this.exercise,
    required this.dayKey,
    required this.day,
    required this.weight,
    required this.reps,
    this.typeText = '',
  });

  final String exercise;

  final String dayKey;

  /// The date of the workout (midnight).
  final DateTime day;
  final double weight;
  final double reps;
  final String typeText;

  int get xValue => day.millisecondsSinceEpoch;

  /// The date part of the key, "yyyy-MM-dd".
  String get dateLabel => dayKey.split(' ').first;

  double get volume => reps.abs() * weight.abs();

  /// Brzycki estimate. The formula breaks down at 37 reps (division by zero)
  double get oneRepMax => reps >= 37 ? weight : weight * (36 / (37 - reps)); // todo consider adding another formula as fallback

  double valueFor(ChartMetric metric) => switch (metric) {
    ChartMetric.weight => weight,
    ChartMetric.volume => volume,
    ChartMetric.reps => reps,
    ChartMetric.oneRepMax => oneRepMax,
  };

  /// The map shape the old `getStats` returned.
  Map<String, dynamic> toLegacyMap() => {
    'weight': weight,
    'reps': reps,
    'type': typeText,
    'date': dayKey,
    'volume': volume,
    'exercise': exercise,
    'x-value': xValue,
    '1rm': oneRepMax,
  };
}

class ExerciseStats {
  const ExerciseStats({
    required this.points,
    required this.heaviestWeight,
    required this.heaviestVolume,
  });

  /// For each day and exercise, the heaviest set that day (ties go to more reps). Oldest day first.
  final List<SetStat> points;

  final Map<String, SetStat> heaviestWeight;
  final Map<String, SetStat> heaviestVolume;

  /// Exercises that have data, in order of first appearance.
  List<String> get exerciseIds => points.map((p) => p.exercise).toSet().toList();
}

bool _isHeavier(SetStat a, SetStat b) =>  a.weight > b.weight || (a.weight == b.weight && a.reps > b.reps);

/// Reads [rawData] for the [targets].
/// [range] is the number of days back to include, or -1 for everything.
ExerciseStats buildExerciseStats({
  required Map rawData,
  required Set<String> targets,
  required int range,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final dayKeys = rawData.keys.map((k) => k.toString()).toList()..sort();

  final points = <SetStat>[];
  final heaviestWeight = <String, SetStat>{};
  final heaviestVolume = <String, SetStat>{};

  for (final dayKey in dayKeys) {
    final day = DateTime.tryParse(dayKey.split(' ').first);
    if (day == null) continue;
    if (range != -1 && today.difference(day).inDays > range) continue;

    final dayData = rawData[dayKey];
    final sets = dayData is Map ? dayData['sets'] : null;
    if (sets is! Map) continue;

    for (final item in sets.entries) {
      final exercise = item.key.toString();
      if (!targets.contains(exercise)) continue;

      SetStat? bestWeight;
      SetStat? bestVolume;
      for (final raw in (item.value as List? ?? const [])) {
        if (raw is! Map) continue;
        final weight = double.tryParse(raw['weight'].toString().trim());
        final reps = double.tryParse(raw['reps'].toString().trim());
        if (weight == null || reps == null) continue;

        final stat = SetStat(
          exercise: exercise,
          dayKey: dayKey,
          day: day,
          weight: weight,
          reps: reps,
          typeText: raw['type']?.toString() ?? '',
        );
        if (bestWeight == null || _isHeavier(stat, bestWeight)) bestWeight = stat;
        if (bestVolume == null || stat.volume > bestVolume.volume) bestVolume = stat;
      }
      if (bestWeight == null || bestVolume == null) continue;

      points.add(bestWeight);

      final allTimeWeight = heaviestWeight[exercise];
      if (allTimeWeight == null || _isHeavier(bestWeight, allTimeWeight)) {
        heaviestWeight[exercise] = bestWeight;
      }
      final allTimeVolume = heaviestVolume[exercise];
      if (allTimeVolume == null || bestVolume.volume > allTimeVolume.volume) {
        heaviestVolume[exercise] = bestVolume;
      }
    }
  }

  return ExerciseStats(
    points: points,
    heaviestWeight: heaviestWeight,
    heaviestVolume: heaviestVolume,
  );
}

/// Least-squares line through [dataPoints], as its start and end points.
List<FlSpot> calculateBestFitLine(List<FlSpot> dataPoints) {
  final n = dataPoints.length;
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (final point in dataPoints) {
    sumX += point.x;
    sumY += point.y;
    sumXY += point.x * point.y;
    sumX2 += point.x * point.x;
  }

  final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  final b = (sumY - m * sumX) / n;

  final minX = dataPoints.map((p) => p.x).reduce(math.min);
  final maxX = dataPoints.map((p) => p.x).reduce(math.max);

  return [FlSpot(minX, m * minX + b), FlSpot(maxX, m * maxX + b)];
}

// percentage change between points
double percentageChange(List<FlSpot> points) {
  if (points.length < 2) return 0;

  final start = points.first.y;
  final end = points.last.y;
  if (start == 0) return 0;

  return (end - start) / start.abs() * 100;
}


class ExercisePoint {
  const ExercisePoint({
    required this.stat,
    required this.x,
    required this.y,
    required this.colorIndex,
  });

  final SetStat stat;
  final double x;
  final double y;

  final int colorIndex;

  FlSpot get spot => FlSpot(x, y);
}

class ExerciseLine {
  const ExerciseLine({
    required this.exercise,
    required this.colorIndex,
    required this.type,
    required this.points,
    required this.bestFit,
    required this.percentChange,
  });

  final String exercise;
  final int colorIndex;
  final ExerciseType type;
  final List<ExercisePoint> points;

  final List<FlSpot> bestFit;
  final double percentChange;
}

class ExerciseChart {
  const ExerciseChart({
    required this.metric,
    required this.bodyweight,
    required this.scale,
    required this.lines,
    required this.xDays,
    required this.xInterval,
    required this.stats,
    required this.latest,
  });

  final ChartMetric metric;

  final bool bodyweight;
  final ScaleSetting scale;
  final List<ExerciseLine> lines;

  final List<DateTime> xDays;
  final double xInterval;
  final ExerciseStats stats;

  /// The most recent point, shown until the user touches the chart.
  final ExercisePoint? latest;

  String get unit => (bodyweight || metric == ChartMetric.reps) ? '' : 'kg';

  ExercisePoint? pointAt(String exercise, String dayKey) {
    for (final line in lines) {
      if (line.exercise != exercise) continue;
      for (final point in line.points) {
        if (point.stat.dayKey == dayKey) return point;
      }
    }
    return null;
  }

  /// The label for an x position on the bottom axis.
  String dateLabel(double x) {
    if (xDays.isEmpty) return '';
    final day = scale == ScaleSetting.scaled
        ? DateTime.fromMillisecondsSinceEpoch(x.toInt())
        : xDays[x.round().clamp(0, xDays.length - 1).toInt()];
    return DateFormat('MMM dd').format(day);
  }
}

/// Turns [stats] into lines for [metric]. [multipliers] scale each exercise's
/// values (not for bodyweight). With [ScaleSetting.equalIntervals] points are
/// spaced evenly, one step per distinct day across all exercises.
ExerciseChart buildExerciseChart({
  required ExerciseStats stats,
  required ChartMetric metric,
  required ScaleSetting scale,
  required Map<String, double> multipliers,
  required ExerciseType Function(String exercise) typeOf,
  required bool bodyweight,
}) {
  final indexOfX = <int, int>{};
  for (final point in stats.points) {
    indexOfX.putIfAbsent(point.xValue, () => indexOfX.length);
  }
  final xValues = indexOfX.keys.toList();

  final byExercise = <String, List<SetStat>>{};
  for (final point in stats.points) {
    byExercise.putIfAbsent(point.exercise, () => []).add(point);
  }

  final lines = <ExerciseLine>[];
  for (final entry in byExercise.entries) {
    final colorIndex = lines.length;
    final multiplier = bodyweight ? 1.0 : (multipliers[entry.key] ?? 1.0);

    final points = [
      for (final stat in entry.value)
        ExercisePoint(
          stat: stat,
          x: scale == ScaleSetting.equalIntervals
              ? indexOfX[stat.xValue]!.toDouble()
              : stat.xValue.toDouble(),
          y: stat.valueFor(metric) * multiplier,
          colorIndex: colorIndex,
        ),
    ];
    final spots = [for (final p in points) p.spot];

    lines.add(ExerciseLine(
      exercise: entry.key,
      colorIndex: colorIndex,
      type: typeOf(entry.key),
      points: points,
      bestFit: points.length > 1 ? calculateBestFitLine(spots) : const [],
      percentChange: percentageChange(spots),
    ));
  }

  final span = xValues.isEmpty
      ? 0.0
      : scale == ScaleSetting.equalIntervals
          ? (xValues.length - 1).toDouble()
          : (xValues.last - xValues.first).toDouble();
  final xInterval = span <= 0 ? 1.0 : math.max(span / 4, 1.0);

  ExercisePoint? latest;
  if (stats.points.isNotEmpty) {
    final last = stats.points.last;
    for (final line in lines) {
      if (line.exercise == last.exercise) latest = line.points.last;
    }
  }

  return ExerciseChart(
    metric: metric,
    bodyweight: bodyweight,
    scale: scale,
    lines: lines,
    xDays: [for (final x in xValues) DateTime.fromMillisecondsSinceEpoch(x)],
    xInterval: xInterval,
    stats: stats,
    latest: latest,
  );
}

class MuscleBreakdown {
  const MuscleBreakdown({required this.primary, required this.secondary});

  static const empty = MuscleBreakdown(primary: {}, secondary: {});

  final Map<String, double> primary;
  final Map<String, double> secondary;

  bool get isEmpty => primary.isEmpty && secondary.isEmpty;

  /// For the body heat map. A muscle in both lists shows its secondary value.
  Map<String, double> get heatMap => {...primary, ...secondary};
}

MuscleBreakdown computeMuscleBreakdown({
  required Iterable<String> exerciseIds,
  required MuscleProfile? Function(String exerciseId) profileOf,
}) {
  final primary = <String, double>{};
  final secondary = <String, double>{};

  void add(Map<String, double> into, Map shares) {
    for (final item in shares.entries) {
      final value = item.value;
      if (value is! num) continue;
      into.update(
        item.key.toString(),
        (current) => current + value,
        ifAbsent: () => value.toDouble(),
      );
    }
  }

  for (final id in exerciseIds) {
    final profile = profileOf(id);
    if (profile == null) continue;
    add(primary, profile.primary);
    add(secondary, profile.secondary);
  }

  final total = [...primary.values, ...secondary.values]
      .fold<double>(0, (a, b) => a + b);
  if (total <= 0) return MuscleBreakdown.empty;

  final scale = 100 / total;
  Map<String, double> scaled(Map<String, double> m) => {
        for (final e in m.entries)
          e.key: double.parse((e.value * scale).toStringAsFixed(2)),
      };

  return MuscleBreakdown(primary: scaled(primary), secondary: scaled(secondary));
}


class ExerciseHistoryDay {
  const ExerciseHistoryDay({required this.workout, required this.exercises});

  final DayWorkout workout;
  final List<DayExercise> exercises;
}

List<ExerciseHistoryDay> buildExerciseHistory({
  required Map rawData,
  required Set<String> targets,
  required ExerciseType Function(String exercise) typeOf,
}) {
  final dayKeys = rawData.keys.map((k) => k.toString()).toList()
    ..sort((a, b) => b.compareTo(a));

  final days = <ExerciseHistoryDay>[];
  for (final dayKey in dayKeys) {
    final raw = rawData[dayKey];
    if (raw is! Map) continue;

    final workout = DayWorkout.fromDetails(
      dayKey,
      WorkoutDetails.fromJson(Map<String, dynamic>.from(raw)),
      typeOf: typeOf,
    );
    final matching = [
      for (final exercise in workout.exercises)
        if (targets.contains(exercise.id)) exercise,
    ];
    if (matching.isEmpty) continue;

    days.add(ExerciseHistoryDay(workout: workout, exercises: matching));
  }
  return days;
}