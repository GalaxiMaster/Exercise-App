// NOTE: Lift, liftFromSet, isBetter, PRResult and PRType already exist in your
// project. If the analyzer says one is undefined, fix the imports below.
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/workout_stats.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// One draft per [WorkoutSeed]. Auto-disposed when the page goes away, which disposes every controller and focus node via `ref.onDispose`.

final workoutDraftProvider = NotifierProvider.autoDispose.family<WorkoutDraftNotifier, WorkoutDraft, WorkoutSeed>(
  WorkoutDraftNotifier.new,
);

/// What the page was opened with.
class WorkoutSeed {
  const WorkoutSeed({this.initialData, this.editing = false, this.metaData});

  final WorkoutDetails? initialData;
  final bool editing;
  final WorkoutMetaData? metaData;
}

/// Snapshot of the workout. The entries inside hold TextEditingControllers and FocusNodes.
class WorkoutDraft {
  WorkoutDraft({
    required this.exercises,
    required this.startTime,
    required this.extraStats,
  });

  final List<ExerciseEntry> exercises;
  final String startTime;

  /// Extra stats merged into the saved stats (from `WorkoutMetaData`).
  final Map extraStats;

  bool get isEmpty => exercises.isEmpty;

  bool contains(String name) => exercises.any((e) => e.name == name);

  ExerciseEntry? entryNamed(String name) {
    for (final e in exercises) {
      if (e.name == name) return e;
    }
    return null;
  }

  // wrapper around the same entries, to trigger a rebuild.
  WorkoutDraft rebuilt() => WorkoutDraft(
    exercises: exercises,
    startTime: startTime,
    extraStats: extraStats,
  );

  Map<String, List<Map<String, dynamic>>> get setsJson => {
    for (final e in exercises) e.name: [for (final s in e.sets) s.toJson()],
  };

  Map<String, dynamic> get statsJson => {
    'notes': {
      for (final e in exercises)
        if (e.note.isNotEmpty) e.name: e.note,
    },
    'startTime': startTime,
    ...extraStats,
  };

  /// to json for storage
  Map<String, dynamic> toStorage() => {'stats': statsJson, 'sets': setsJson};

  /// What the confirm page expects.
  WorkoutDetails toDetails() => WorkoutDetails(sets: setsJson, startTime: startTime);
}


// Notifier: All methods that edit the workout
class WorkoutDraftNotifier extends Notifier<WorkoutDraft> {
  WorkoutDraftNotifier(this.seed);

  final WorkoutSeed seed;

  @override
  WorkoutDraft build() {
    final exercises = <ExerciseEntry>[];
    var startTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final details = seed.initialData;
    if (details != null) { // Editing an existing workout
      startTime = details.startTime;
      _loadInto(exercises, details.sets, details.notes ?? const {});
    } else { // Resume the in progress workout.
      final Map saved = ref.read(currentWorkoutProvider);
      final savedStart = saved['stats']?['startTime'];
      if (savedStart is String) startTime = savedStart;
      final rawSets = saved['sets'];

      if (rawSets != null) {
        final notes = saved['stats']?['notes'];
        _loadInto(exercises, rawSets as Map, notes is Map ? notes : const {});
      }
    }

    // Disposes every entry still in the list
    ref.onDispose(() {
      for (final e in exercises) {
        e.dispose();
      }
    });

    return WorkoutDraft(
      exercises: exercises,
      startTime: startTime,
      extraStats: {if (seed.metaData != null) ...seed.metaData!.toMap()},
    );
  }

  void _loadInto(List<ExerciseEntry> into, Map rawSets, Map notes) {
    for (final item in rawSets.entries) {
      final name = item.key.toString();
      final sets = [
        for (final raw in (item.value as List? ?? const []))
          SetEntry.fromJson(Map<String, dynamic>.from(raw as Map)),
      ];
      into.add(ExerciseEntry(
        name: name,
        type: _typeOf(name),
        sets: sets.isEmpty ? null : sets, // null => one blank set
        note: notes[name]?.toString() ?? '',
      ));
    }
  }

  // exercises

  /// Adds every name not already in the workout. Returns the new entries.
  List<ExerciseEntry> addExercises(Iterable<String> names) {
    final added = <ExerciseEntry>[];
    for (final name in names) {
      if (state.contains(name)) continue;
      final entry = ExerciseEntry(name: name, type: _typeOf(name));
      state.exercises.add(entry);
      added.add(entry);
    }
    if (added.isNotEmpty) _commit();
    return added;
  }

  void removeExercise(ExerciseEntry entry) {
    if (!state.exercises.remove(entry)) return;
    entry.disposeAfterFrame();
    _commit();
  }

  /// Replaces [entry]'s exercise with [newName], keeping its note and position. 
  /// If its a different type, sets are cleared
  /// Returns false if [newName] is already in the workout.
  bool swapExercise(ExerciseEntry entry, String newName) {
    if (state.contains(newName)) return false;

    final newType = _typeOf(newName);
    if (newType != entry.type) {
      final oldSets = List<SetEntry>.of(entry.sets);
      entry.sets
        ..clear()
        ..add(SetEntry.blank(newType));
      for (final s in oldSets) {
        s.disposeAfterFrame();
      }
    }
    entry.name = newName;
    entry.type = newType;

    _refreshPRs(entry); // the record to beat is now a different exercise's
    _commit();
    return true;
  }

  void setNote(ExerciseEntry entry, String text) {
    entry.note = text;
    _persist();
  }

  /// Adds a set (blank, or a copy of [copyOf]) and returns it.
  SetEntry addSet(ExerciseEntry entry, {SetEntry? copyOf}) {
    final set = copyOf == null
        ? SetEntry.blank(entry.type)
        : SetEntry.copyOf(copyOf);
    entry.sets.add(set);
    _refreshPRs(entry);
    _commit();
    return set;
  }

  void removeSet(ExerciseEntry entry, SetEntry set) {
    if (entry.sets.length == 1 && identical(entry.sets.first, set)) { // Removing the only set of an exercise removes the exercise.
      removeExercise(entry);
      return;
    }
    if (!entry.sets.remove(set)) return;
    set.disposeAfterFrame();
    _refreshPRs(entry);
    _commit();
  }

  void setSetType(ExerciseEntry entry, SetEntry set, SetType type) {
    set.type = type;
    _refreshPRs(entry);
    _commit();
  }

  /// Returns the PR result for [set] so the page can show a popup.
  PRResult onFieldEdited(ExerciseEntry entry, SetEntry set, SetField field) {
    set.setError(field, false);
    final result = _refreshPRs(entry, report: set);
    _commit();
    return result;
  }

  /// For timed exercises, the timer writes the seconds into the weight field.
  PRResult setTimerSeconds(ExerciseEntry entry, SetEntry set, int seconds) {
    set.weightController.text = seconds.toString();
    return onFieldEdited(entry, set, SetField.weight);
  }

  PRResult setChecked(ExerciseEntry entry, SetEntry set, bool checked) {
    set.checked = checked;
    final result = _refreshPRs(entry, report: set);
    _commit(persist: false); // ticks aren't saved
    return result;
  }

  /// Marks every empty or non-numeric field with an error and rebuilds once.
  /// Returns true if the whole workout is valid.
  bool validate() {
    var valid = true;
    for (final entry in state.exercises) {
      for (final set in entry.sets) {
        set.weightError = set.weight == null;
        set.repsError = set.reps == null;
        if (set.weightError || set.repsError) valid = false;
      }
    }
    _commit(persist: false);
    return valid;
  }

  // private
  ExerciseType _typeOf(String name) => exerciseTypeFor(
        name,
        exercises: ref.read(exercisesProvider),
        customExercises: ref.read(customExercisesProvider),
      );

  Lift? _recordFor(String name) {
    final Map records = ref.read(recordsProvider).value ?? const {};
    return RecordBook(records).bestFor(name);
  }

  PRResult _refreshPRs(ExerciseEntry entry, {SetEntry? report}) {
    final results = evaluateSetPRs(entry.sets, _recordFor(entry.name));
    for (final item in results.entries) {
      item.key.isPR = item.value.isPR;
    }
    return results[report] ?? PRResult(false, PRType.none);
  }

  void _commit({bool persist = true}) {
    state = state.rebuilt();
    if (persist) _persist();
  }

  /// Saves the in-progress workout. Editing an old workout isn't saved as a
  /// draft.
  void _persist() {
    if (seed.editing) return;
    ref.read(currentWorkoutProvider.notifier).writeState(
          state.isEmpty ? <String, dynamic>{} : state.toStorage(),
        );
  }
}

ExerciseType exerciseTypeFor(
  String name, {
  required Map<String, Exercise> exercises,
  required Map customExercises,
}) {
  final builtIn = exercises[name]?.type;
  if (builtIn != null) return ExerciseType.parse(builtIn);

  // Handles a custom exercise stored as either an object or a plain map.
  final dynamic custom = customExercises[name]; // todo  —  standardise
  final dynamic raw = custom is Map ? custom['type'] : custom?.type;
  return ExerciseType.parse(raw?.toString());
}

/// Typed wrapper around the raw `records` map.
class RecordBook { // todo move records to typed provider instead of passing the raw map around
  const RecordBook(this._records);

  final Map _records;

  /// The best recorded lift for [exercise], or null if there is none yet.
  Lift? bestFor(String exercise) {
    final record = _records[exercise];
    return record == null ? null : liftFromSet(record);
  }
}

/// Decides whether [candidate] beats [record].
PRResult evaluatePR({required Lift candidate, Lift? record}) {
  if (record == null) return PRResult(true, PRType.first);
  if (candidate.weight > record.weight) return PRResult(true, PRType.weight);
  if (candidate.weight == record.weight && candidate.reps > record.reps) {
    return PRResult(true, PRType.reps);
  }
  return PRResult(false, PRType.none);
}

Map<SetEntry, PRResult> evaluateSetPRs(List<SetEntry> sets, Lift? record) {
  final results = {
    for (final s in sets) s: PRResult(false, PRType.none),
  };

  SetEntry? bestSet;
  Lift? bestLift;
  for (final s in sets) {
    final lift = liftFromSet(s.toJson());
    if (lift == null) continue;
    if (bestLift == null || isBetter(lift, bestLift)) {
      bestLift = lift;
      bestSet = s;
    }
  }

  if (bestSet != null && bestLift != null) {
    results[bestSet] = evaluatePR(candidate: bestLift, record: record);
  }
  return results;
}