import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/sync_controller.dart';
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual_models.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/workout_stats.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// day_screen_providers.dart
/// The stored details for one day, parsed once. Rebuilds only when that day's stored entry changes.
final dayDetailsProvider = Provider.autoDispose.family<WorkoutDetails?, String>((ref, dayKey) {
  final raw = ref.watch(workoutDataProvider.select((a) => a.value?[dayKey]));
  if (raw == null) return null;
  return WorkoutDetails.fromJson(Map<String, dynamic>.from(raw));
});

final dayWorkoutProvider = Provider.autoDispose.family<DayWorkout?, String>((ref, dayKey) {
  final details = ref.watch(dayDetailsProvider(dayKey));
  if (details == null) return null;

  final exercises = ref.watch(exercisesProvider);
  final Map custom = ref.watch(customExercisesProvider);

  return DayWorkout.fromDetails(
    dayKey,
    details,
    typeOf: (id) => ExerciseType.parse(
      findExerciseById(id, exercises: exercises, custom: custom)?.type,
    ),
  );
});

final muscleSplitProvider = Provider.autoDispose.family<List<MuscleShare>, String>((ref, dayKey) {
  final workout = ref.watch(dayWorkoutProvider(dayKey));
  if (workout == null) return const [];

  final exercises = ref.watch(exercisesProvider);
  final Map custom = ref.watch(customExercisesProvider);

  return computeMuscleSplit(
    setsPerExercise: {
      for (final e in workout.exercises) e.id: e.sets.length,
    },
    profileOf: (id) {
      final exercise = findExerciseById(id, exercises: exercises, custom: custom);
      return exercise == null
          ? null
          : (primary: exercise.primary, secondary: exercise.secondary);
    },
    groups: muscleGroups,
  );
});

final friendWorkoutProvider = FutureProvider.autoDispose.family<DayWorkout?, ({String uid, String key})>((ref, args) async {
  final snap = await FirebaseFirestore.instance
    .collection('User Data')
    .doc(args.uid)
    .collection('workouts')
    .doc(args.key)
    .get();
  final data = snap.data();

  final Map<String, Exercise> exercises = ref.watch(exercisesProvider);
  final Map<String, Exercise> custom = ref.watch(customExercisesProvider);

  return data == null ? null : DayWorkout.fromMap(
    args.key,
    fromCloud(data),
    typeOf: (id) => ExerciseType.parse(
      findExerciseById(id, exercises: exercises, custom: custom)?.type,
    ),
  );
});