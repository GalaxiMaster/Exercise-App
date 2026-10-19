// NOTE: Lift, liftFromSet, isBetter, PRResult and PRType already exist in your
// project. If the analyzer says one is undefined, fix the imports below.
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Routines/routines_draft_notifier.dart';
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
  const WorkoutSeed({
    this.initialData,
    this.editing = false,
    this.metaData,
    this.routine,
  });

  final WorkoutDetails? initialData;
  final bool editing;
  final WorkoutMetaData? metaData;

  final Map? routine;
}


/// Snapshot of the workout. The entries inside hold TextEditingControllers and FocusNodes.
class WorkoutDraft {
  WorkoutDraft({
    required this.items,
    required this.startTime,
    required this.extraStats,
  });

  /// In display order: real exercises and routine slots still to be chosen.
  final List<WorkoutItem> items;
  final String startTime;

  /// Extra stats merged into the saved stats (from `WorkoutMetaData`).
  final Map extraStats;

  Iterable<ExerciseEntry> get exercises => items.whereType<ExerciseEntry>();
  Iterable<PendingSlot> get pendingSlots => items.whereType<PendingSlot>();

  bool get isEmpty => items.isEmpty;

  bool contains(String name) => exercises.any((e) => e.name == name);

  ExerciseEntry? entryNamed(String name) {
    for (final e in exercises) {
      if (e.name == name) return e;
    }
    return null;
  }

  // wrapper around the same entries, to trigger a rebuild.
  WorkoutDraft rebuilt() => WorkoutDraft(
    items: items,
    startTime: startTime,
    extraStats: extraStats,
  );

  /// Only real exercises. Ignore slots
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
  Map<String, dynamic> toStorage() {
    final fromRoutine = items.any(
      (i) => i is PendingSlot || (i is ExerciseEntry && i.slot != null),
    );
    return {
      'stats': statsJson,
      'sets': setsJson,
      if (fromRoutine)
        'routine': {
          'items': [for (final i in items) _layoutJson(i)],
        },
    };
  }

  static Map<String, dynamic> _layoutJson(WorkoutItem item) {
    switch (item) {
      case ExerciseEntry():
        return {
          'exercise': item.name,
          if (item.slot != null) 'slot': item.slot!.toJson(),
        };
      case PendingSlot():
        return {'slot': item.slot.toJson()};
    }
  }

  /// What the confirm page expects.
  WorkoutDetails toDetails() => WorkoutDetails(sets: setsJson, startTime: startTime);
}


// Notifier: All methods that edit the workout
class WorkoutDraftNotifier extends Notifier<WorkoutDraft> {
  WorkoutDraftNotifier(this.seed);

  final WorkoutSeed seed;

  @override
  WorkoutDraft build() {
    final items = <WorkoutItem>[];
    var startTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final details = seed.initialData;
    final routine = seed.routine;

    if (details != null) { // Editing an existing workout
      startTime = details.startTime;
      _loadEntries(items, details.sets, details.notes ?? const {});
    } else if (routine != null) {
      items.addAll(_itemsFromRoutine(routine));
      Future.microtask(() {
        if (ref.mounted) _persist();
      });
    } else { // Resume the in progress workout.
      final Map saved = ref.read(currentWorkoutProvider);
      final savedStart = saved['stats']?['startTime'];
      if (savedStart is String) startTime = savedStart;
      final rawSets = saved['sets'];

      if (rawSets != null) {
        final notes = saved['stats']?['notes'];
        final routineInfo = saved['routine'];
        final layout = routineInfo is Map ? routineInfo['items'] : null;
        _loadEntries(
          items,
          rawSets as Map,
          notes is Map ? notes : const {},
          layout: layout is List ? layout : null,
        );
      }
    }

    // Disposes every entry still in the list
    ref.onDispose(() {
      for (final e in items.whereType<ExerciseEntry>()) {
        e.dispose();
      }
    });

    return WorkoutDraft(
      items: items,
      startTime: startTime,
      extraStats: {if (seed.metaData != null) ...seed.metaData!.toMap()},
    );
  }

  // loading

  ExerciseEntry _entryFrom(
    String name,
    dynamic rawSets,
    Map notes, {
    RoutineSlot? slot,
  }) {
    final sets = [
      for (final raw in (rawSets as List? ?? const []))
        SetEntry.fromJson(Map<String, dynamic>.from(raw as Map)),
    ];
    return ExerciseEntry(
      name: name,
      type: _typeOf(name),
      sets: sets.isEmpty ? null : sets, // null => one blank set
      note: notes[name]?.toString() ?? '',
      slot: slot,
    );
  }

  void _loadEntries(
    List<WorkoutItem> into,
    Map rawSets,
    Map notes, {
    List? layout,
  }) {
    final placed = <String>{};

    if (layout != null) {
      for (final raw in layout) {
        final item = raw as Map;
        final slotJson = item['slot'];
        final slot = slotJson is Map ? RoutineSlot.fromJson(slotJson) : null;
        final name = item['exercise']?.toString();

        if (name == null) {
          if (slot != null) into.add(PendingSlot(slot));
        } else if (rawSets.containsKey(name)) {
          into.add(_entryFrom(name, rawSets[name], notes, slot: slot));
          placed.add(name);
        }
      }
    }

    for (final item in rawSets.entries) {
      final name = item.key.toString();
      if (placed.contains(name)) continue;
      into.add(_entryFrom(name, item.value, notes));
    }
  }

  /// Single slots auto filled in
  List<WorkoutItem> _itemsFromRoutine(Map raw) {
    final items = <WorkoutItem>[];
    final used = <String>{};

    for (final slot in RoutineDraft.fromRaw(raw).slots) {
      if (slot.options.isEmpty) continue;
      if (slot.options.length > 1) {
        items.add(PendingSlot(slot));
        continue;
      }
      final exercise = slot.options.single.exercise;
      if (used.add(exercise)) items.add(_newEntry(exercise, slot));
    }
    return items;
  }

  ExerciseEntry _newEntry(String exercise, RoutineSlot slot) {
    final type = _typeOf(exercise);
    return ExerciseEntry(
      name: exercise,
      type: type,
      slot: slot,
      sets: [
        for (var i = 0; i < initialSetCount(slot, exercise); i++)
          SetEntry.blank(type),
      ],
    );
  }

  // routine slots
  bool pickOption(PendingSlot pending, String exercise) {
    final index = state.items.indexOf(pending);
    if (index < 0 || state.contains(exercise)) return false;

    state.items[index] = _newEntry(exercise, pending.slot);
    _commit();
    return true;
  }

  /// Drops an unfilled slot without doing anything for it.
  void skipSlot(PendingSlot pending) {
    if (!state.items.remove(pending)) return;
    _commit();
  }

  // exercises

  /// Adds every name not already in the workout. Returns the new entries.
  List<ExerciseEntry> addExercises(Iterable<String> names) {
    final added = <ExerciseEntry>[];
    for (final name in names) {
      if (state.contains(name)) continue;
      final entry = ExerciseEntry(name: name, type: _typeOf(name));
      state.items.add(entry);
      added.add(entry);
    }
    if (added.isNotEmpty) _commit();
    return added;
  }

  void removeExercise(ExerciseEntry entry) {
    if (!state.items.remove(entry)) return;
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
      final slot = entry.slot;
      final count = slot == null ? 1 : initialSetCount(slot, newName);
      entry.sets
        ..clear()
        ..addAll([for (var i = 0; i < count; i++) SetEntry.blank(newType)]);
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

  // sets

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

  /// Removing the only set of an exercise removes the exercise.
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

int initialSetCount(RoutineSlot slot, String exercise) {
  final option = slot.optionFor(exercise);
  final text = option == null ? slot.defaultSets : slot.targetFor(option).sets;
  final planned = int.tryParse(text.trim()) ?? 1;
  return planned.clamp(1, 10).toInt();
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