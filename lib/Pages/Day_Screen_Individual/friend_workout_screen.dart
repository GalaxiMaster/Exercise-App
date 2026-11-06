import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual.dart';
import 'package:exercise_app/models/day_screen_individual_models.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_providers.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendMuscleSplitProvider = Provider.autoDispose.family<List<MuscleShare>, AsyncValue<DayWorkout?>>((ref, workoutAsync) { // todo improve?
  return workoutAsync.maybeWhen(
    data: (workout) {
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
    },
    orElse: () => const [],
  );
});

class FriendWorkoutScreen extends ConsumerWidget {
  const FriendWorkoutScreen({
    super.key,
    required this.friendUid,
    required this.friendName,
    required this.dayKey,
    required this.preview,
  });

  final String friendUid, friendName, dayKey;
  final FeedWorkout preview; // the feed summary

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(friendWorkoutProvider((uid: friendUid, key: dayKey)));
    final exercises = ref.watch(exercisesProvider);
    final workout = async.value;
    final split = ref.watch(friendMuscleSplitProvider(async));

    if (async.hasError || (async.hasValue && workout == null)) {
      return Scaffold(
        appBar: myAppBar(context, friendName),
        body: Center(
          child: Text(async.hasError ? 'Could not load workout ${async.error}' : 'Workout not found'),
        ),
      );
    }

    return Scaffold(
      appBar: myAppBar(context, friendName),
      body: WorkoutDetailView(
        fallbackTitle: dayKey,
        summary: workout != null
            ? DaySummary.of(workout)
            : DaySummary(
                duration: preview.duration ?? Duration.zero,
                volume: preview.volume,
                prs: preview.prCount,
                sets: preview.setCount,
                exercises: preview.exercises.length,
              ),
        workout: workout,
        split: split,
        exercises: exercises,
        // no onEdit: you can't edit a friend's workout
      ),
    );
  }
}