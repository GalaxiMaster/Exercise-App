import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual_models.dart'; 
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier(initialFilters: ChartFilters.weight());
});

/// Best set per exercise per day, for the chosen time range.
final exerciseStatsProvider = Provider.autoDispose.family<AsyncValue<ExerciseStats>, ExerciseKey>((ref, key) {
  final range = ref.watch(chartFilterProvider.select((f) => f.range));
  return ref.watch(workoutDataProvider).whenData(
    (data) => buildExerciseStats(
      rawData: data,
      targets: key.ids.toSet(),
      range: range,
    ),
  );
});

/// Everything the graph tab draws, for the chosen metric, scale and multipliers.
final exerciseChartProvider = Provider.autoDispose.family<AsyncValue<ExerciseChart>, ChartRequest>((ref, request) {
  final stats = ref.watch(exerciseStatsProvider(request.exercises));
  final target = ref.watch(chartFilterProvider.select((f) => f.chartTarget));
  final multipliers = parseMultipliers(
    ref.watch(settingsProvider.select((a) => a.value?['Multipliers'])),
  );

  final exercises = ref.watch(exercisesProvider);
  final Map custom = ref.watch(customExercisesProvider);
  ExerciseType typeOf(String id) => ExerciseType.parse(
    findExerciseById(id, exercises: exercises, custom: custom)?.type,
  );

  final ids = request.exercises.ids;
  final bodyweight = ids.isNotEmpty && ids.every((id) => typeOf(id) == ExerciseType.bodyweight);
  final metric = bodyweight ? ChartMetric.reps : ChartMetric.fromKey(target);

  return stats.whenData(
    (data) => buildExerciseChart(
      stats: data,
      metric: metric,
      scale: request.scale,
      multipliers: multipliers,
      typeOf: typeOf,
      bodyweight: bodyweight,
    ),
  );
});

final exerciseHistoryProvider = Provider.autoDispose.family<AsyncValue<List<ExerciseHistoryDay>>, ExerciseKey>((ref, key) {
  final exercises = ref.watch(exercisesProvider);
  final Map custom = ref.watch(customExercisesProvider);

  return ref.watch(workoutDataProvider).whenData(
    (data) => buildExerciseHistory(
      rawData: data,
      targets: key.ids.toSet(),
      typeOf: (id) => ExerciseType.parse(
        findExerciseById(id, exercises: exercises, custom: custom)?.type,
      ),
    ),
  );
});

final muscleBreakdownProvider = Provider.autoDispose.family<MuscleBreakdown, ExerciseKey>((ref, key) {
  final exercises = ref.watch(exercisesProvider);
  final Map custom = ref.watch(customExercisesProvider);

  return computeMuscleBreakdown(
    exerciseIds: key.ids,
    profileOf: (id) {
      final exercise = findExerciseById(id, exercises: exercises, custom: custom);
      return exercise == null
        ? null
        : (primary: exercise.primary, secondary: exercise.secondary);
    },
  );
});