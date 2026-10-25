import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/workout_stats.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

double? _number(String text) => double.tryParse(text.trim());

/// Case-insensitive, because older data may not use the same capitalisation.
SetType _parseSetType(Object? raw) {
  final text = raw?.toString().toLowerCase();
  return SetType.values.firstWhere(
    (t) => t.storageName.toLowerCase() == text,
    orElse: () => SetType.normal,
  );
}

/// One set as it was saved.
class LoggedSet {
  const LoggedSet({
    required this.type,
    this.weightText = '',
    this.repsText = '',
    this.isPR = false,
  });

  factory LoggedSet.fromJson(Map json) => LoggedSet(
        type: _parseSetType(json['type']),
        weightText: json['weight']?.toString() ?? '',
        repsText: json['reps']?.toString() ?? '',
        isPR: json['PR'] == 'yes',
      );

  final SetType type;

  /// The text exactly as the user entered it (for display).
  final String weightText;
  final String repsText;
  final bool isPR;

  /// `null` when empty or not a number.
  double? get weight => _number(weightText);
  double? get reps => _number(repsText);

  /// |weight| x |reps|; a missing or invalid value counts as 0.
  double get volume => (weight?.abs() ?? 0.0) * (reps?.abs() ?? 0.0);

  /// How the set is shown in a list: "60 x 8", "x12" for bodyweight, "45s" for timed.
  String describe(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.bodyweight:
        return 'x$repsText';
      case ExerciseType.timed:
        return '${weightText}s';
      case ExerciseType.weighted:
      case ExerciseType.assisted:
        return '$weightText x $repsText';
    }
  }
}

class DayExercise {
  const DayExercise({
    required this.id,
    required this.type,
    required this.sets,
  });

  final String id;
  final ExerciseType type;
  final List<LoggedSet> sets;

  /// The number shown for a normal set: how many normal sets come up to and
  /// including [index] (warmups, failures and dropsets are skipped). Matches
  /// the add-workout page.
  int normalNumberOf(int index) {
    var count = 0;
    for (var i = 0; i <= index && i < sets.length; i++) {
      if (sets[i].type == SetType.normal) count++;
    }
    return count;
  }
}

class DayWorkout {
  const DayWorkout({
    required this.key,
    required this.exercises,
    this.start,
    this.end,
  });

  /// Reads the stored details. [typeOf] resolves each exercise's type.
  factory DayWorkout.fromDetails(
    String key,
    WorkoutDetails details, {
    required ExerciseType Function(String exerciseId) typeOf,
  }) {
    final end = details.endTime;
    return DayWorkout(
      key: key,
      start: DateTime.tryParse(details.startTime),
      end: end == null ? null : DateTime.tryParse(end),
      exercises: [
        for (final item in details.sets.entries)
          DayExercise(
            id: item.key,
            type: typeOf(item.key),
            sets: [for (final s in item.value) LoggedSet.fromJson(s)],
          ),
      ],
    );
  }


  final String key;

  /// `null` when the stored time is missing or unreadable.
  final DateTime? start;
  final DateTime? end;
  final List<DayExercise> exercises;

  Duration? get duration => (start != null && end != null) ? end!.difference(start!) : null;
}

/// The headline numbers for a workout.
class DaySummary {
  const DaySummary({
    required this.volume,
    required this.sets,
    required this.prs,
    required this.exercises,
    required this.duration,
  });

  factory DaySummary.of(DayWorkout workout) {
    var volume = 0.0;
    var sets = 0;
    var prs = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        sets++;
        volume += set.volume;
        if (set.isPR) prs++;
      }
    }
    return DaySummary(
      volume: volume,
      sets: sets,
      prs: prs,
      exercises: workout.exercises.length,
      duration: workout.duration,
    );
  }

  final double volume;
  final int sets;
  final int prs;
  final int exercises;
  final Duration? duration;
}

/// "1h 15m", or a dash when the duration isn't known.
String formatDuration(Duration? duration) => duration == null ? '–' : '${duration.inHours}h ${duration.inMinutes % 60}m';

// Muscle split

/// How much of a workout went to one muscle group, as a percentage.
class MuscleShare {
  const MuscleShare(this.group, this.percent);

  final String group;
  final double percent;
}

/// A muscle name to number map for the primary and secondary muscles an
/// exercise works.
typedef MuscleProfile = ({Map primary, Map secondary});

/// Splits a workout's sets across muscle groups. Each set adds
/// (muscle share / 100) to every muscle the exercise works; muscles are then
/// summed into [groups] (group name to muscle names) and scaled to 100%.
///
/// Result is sorted largest first and leaves out groups that round to 0.
/// Returns an empty list when nothing is known about the exercises.
List<MuscleShare> computeMuscleSplit({
  required Map<String, int> setsPerExercise,
  required MuscleProfile? Function(String exerciseId) profileOf,
  required Map groups,
}) {
  final perMuscle = <String, double>{};

  void add(Map shares, int sets) {
    for (final item in shares.entries) {
      final share = item.value;
      if (share is! num) continue;
      final amount = share / 100 * sets;
      perMuscle.update(
        item.key.toString(),
        (current) => current + amount,
        ifAbsent: () => amount,
      );
    }
  }

  for (final item in setsPerExercise.entries) {
    final profile = profileOf(item.key);
    if (profile == null) continue;
    add(profile.primary, item.value);
    add(profile.secondary, item.value);
  }

  final perGroup = <String, double>{};
  for (final item in groups.entries) {
    final muscles = item.value as List? ?? const [];
    if (muscles.isEmpty) continue;
    perGroup[item.key.toString()] = muscles.fold<double>(
      0,
      (sum, muscle) => sum + (perMuscle[muscle.toString()] ?? 0),
    );
  }

  final total = perGroup.values.fold<double>(0, (a, b) => a + b);
  if (total <= 0) return const [];

  final scale = 100 / total;
  final shares = <MuscleShare>[
    for (final item in perGroup.entries)
      MuscleShare(item.key, double.parse((item.value * scale).toStringAsFixed(2))),
  ]..sort((a, b) => b.percent.compareTo(a.percent));

  return [
    for (final share in shares)
      if (share.percent > 0) share,
  ];
}

/// Custom exercises take priority over the built-in list.
Exercise? findExerciseById(
  String id, {
  required Map<String, Exercise> exercises,
  required Map custom,
}) {
  final candidate = custom[id];
  return candidate is Exercise ? candidate : exercises[id];
}

/// Where an edited workout is written, and whether the old entry must be
/// deleted first. This keeps the page's existing rule: the new key is the
/// date part of the new start time, and the old entry is removed only when
/// that date differs from the old key's date.
({String key, bool replacesOld}) editedWorkoutKey({
  required String oldKey,
  required String newStartTime,
}) {
  final newKey = newStartTime.split(' ').first;
  return (key: newKey, replacesOld: newKey != oldKey.split(' ').first);
}


/// The stored details for one day, parsed once. Rebuilds only when that day's stored entry changes.
final dayDetailsProvider = Provider.autoDispose.family<WorkoutDetails?, String>((ref, dayKey) {
  final raw = ref.watch(workoutDataProvider.select((a) => a.value?[dayKey]));
  if (raw == null) return null;
  return WorkoutDetails.fromJson(Map<String, dynamic>.from(raw));
});

final dayWorkoutProvider =
    Provider.autoDispose.family<DayWorkout?, String>((ref, dayKey) {
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

final muscleSplitProvider =
    Provider.autoDispose.family<List<MuscleShare>, String>((ref, dayKey) {
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