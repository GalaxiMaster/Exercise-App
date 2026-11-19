import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/day_screen_individual_models.dart';
import 'package:exercise_app/models/exercise_screen_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier(initialFilters: ChartFilters.weight());
});

/// Best set per exercise per day, for the chosen time range.
final exerciseStatsProvider = Provider.autoDispose.family<AsyncValue<ExerciseStats>, ExerciseKey>((ref, key) {
  final range = ref.watch(chartFilterProvider.select((f) => f.timeFilter.range));
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
  final metric = bodyweight ? TargetFilter.reps : target;

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

final exerciseLeaderboardProvider = FutureProvider.autoDispose.family<Map<String, Map<String, dynamic>>, ExerciseKey>((ref, key) async {
  final exercise = key.ids.first;
  
  final friendIds = await SocialService().friendIds().first;

  final myId = FirebaseAuth.instance.currentUser?.uid; // could use local records instead to avoid hitting the database an extra time?
  if (myId == null) return {};
  friendIds.add(myId);

  final entries = await Future.wait(
    friendIds.map((id) async {
      final doc = await FirebaseFirestore.instance
          .collection('User Data')
          .doc(id)
          .collection('exerciseStats')
          .doc(exercise)
          .get();

      final data = doc.data();
      return data != null ? MapEntry(id, data) : null;
    }),
  );  

  return Map.fromEntries(entries.nonNulls);
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