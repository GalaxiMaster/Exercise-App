import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nanoid/nanoid.dart';

/// One draft per [RoutineSeed], auto-disposed when the page closes.
/// The page must create the seed ONCE and reuse it (the family keys on it).
final routineDraftProvider = NotifierProvider.autoDispose.family<RoutineDraftNotifier, RoutineDraft, RoutineSeed>(
  RoutineDraftNotifier.new,
);

/// What the editor was opened with: the saved routine map, or null for a new
/// routine.
class RoutineSeed {
  const RoutineSeed(this.raw);

  final Map? raw;
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// One exercise a slot can use. When the routine is performed you do ONE
/// option per slot.
///
/// [sets] and [reps] are overrides. `null` means "use the slot's default", so
/// a target is only stored when it differs from the default.
class RoutineOption {
  const RoutineOption({
    required this.exercise,
    this.sets,
    this.reps,
    this.note = '',
  });

  factory RoutineOption.fromJson(Map json) => RoutineOption(
        exercise: json['exercise'].toString(),
        sets: _clean(json['sets']?.toString()),
        reps: _clean(json['reps']?.toString()),
        note: json['note']?.toString() ?? '',
      );

  /// Exercise id.
  final String exercise;

  /// `null` = inherit the slot default. Reps are text so ranges like "8-10"
  /// work.
  final String? sets;
  final String? reps;
  final String note;

  bool get hasOverride => sets != null || reps != null;

  // Not a generic copyWith, because "set this to null" must be expressible.
  RoutineOption withSets(String? value) =>
      RoutineOption(exercise: exercise, sets: _clean(value), reps: reps, note: note);

  RoutineOption withReps(String? value) =>
      RoutineOption(exercise: exercise, sets: sets, reps: _clean(value), note: note);

  RoutineOption withNote(String value) =>
      RoutineOption(exercise: exercise, sets: sets, reps: reps, note: value);

  /// Back to the slot default. Keeps the note.
  RoutineOption withoutOverrides() => RoutineOption(exercise: exercise, note: note);

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        if (sets != null) 'sets': sets,
        if (reps != null) 'reps': reps,
        'note': note,
      };
}

/// One part of the workout, e.g. "upper chest", with a default target and the
/// exercises that can fill it.
class RoutineSlot {
  const RoutineSlot({
    required this.id,
    this.title = '',
    this.defaultSets = '',
    this.defaultReps = '',
    this.options = const [],
  });

  factory RoutineSlot.empty() => RoutineSlot(id: nanoid());

  factory RoutineSlot.fromJson(Map json) {
    final rawOptions = json['options'];
    final List<RoutineOption> options;
    if (rawOptions is List) {
      options = [for (final o in rawOptions) RoutineOption.fromJson(o as Map)];
    } else {
      // Earlier draft format: a plain list of exercise ids plus one
      // slot-level note. The note moves onto the first exercise.
      final names = [
        for (final e in (json['exercises'] as List? ?? const [])) e.toString(),
      ];
      final note = json['note']?.toString() ?? '';
      options = [
        for (var i = 0; i < names.length; i++)
          RoutineOption(exercise: names[i], note: i == 0 ? note : ''),
      ];
    }

    return RoutineSlot(
      id: json['id']?.toString() ?? nanoid(),
      title: json['title']?.toString() ?? '',
      defaultSets: (json['defaultSets'] ?? json['targetSets'])?.toString() ?? '',
      defaultReps: (json['defaultReps'] ?? json['targetReps'])?.toString() ?? '',
      options: options,
    );
  }

  /// Stable identity for widget keys and updates.
  final String id;

  /// Optional label, e.g. "short tricep".
  final String title;

  /// Target used by every option that doesn't override it.
  final String defaultSets;
  final String defaultReps;

  final List<RoutineOption> options;

  /// The target you'll actually aim for on [option]. This is the only place
  /// the inheritance rule lives, so UI and workout code never repeat it.
  ({String sets, String reps}) targetFor(RoutineOption option) => (
        sets: option.sets ?? defaultSets,
        reps: option.reps ?? defaultReps,
      );

  RoutineOption? optionFor(String exercise) {
    for (final o in options) {
      if (o.exercise == exercise) return o;
    }
    return null;
  }

  /// Nothing worth saving.
  bool get isBlank => title.trim().isEmpty && options.isEmpty;

  RoutineSlot copyWith({
    String? title,
    String? defaultSets,
    String? defaultReps,
    List<RoutineOption>? options,
  }) =>
      RoutineSlot(
        id: id,
        title: title ?? this.title,
        defaultSets: defaultSets ?? this.defaultSets,
        defaultReps: defaultReps ?? this.defaultReps,
        options: options ?? this.options,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
        'options': [for (final o in options) o.toJson()],
      };
}

/// The routine being edited. Deliberately has no `==`: every change creates a
/// new instance, which is what makes Riverpod 3 notify listeners.
class RoutineDraft {
  const RoutineDraft({
    required this.id,
    required this.name,
    required this.color,
    required this.slots,
  });

  /// Accepts the current format (`slots`) and the original one (`sets`, one
  /// entry per exercise). Original routines are converted: each exercise
  /// becomes a slot with that one option, and the set count and first set's
  /// reps become the slot default.
  factory RoutineDraft.fromRaw(Map? raw) {
    final data = raw?['data'];
    final dataMap = data is Map ? data : const {};

    final slots = <RoutineSlot>[];
    final rawSlots = raw?['slots'];
    final legacySets = raw?['sets'];

    if (rawSlots is List) {
      for (final s in rawSlots) {
        slots.add(RoutineSlot.fromJson(s as Map));
      }
    } else if (legacySets is Map) {
      for (final item in legacySets.entries) {
        final sets = item.value as List? ?? const [];
        final firstReps =
            sets.isEmpty ? '' : ((sets.first as Map)['reps']?.toString() ?? '');
        slots.add(RoutineSlot(
          id: nanoid(),
          defaultSets: sets.isEmpty ? '' : '${sets.length}',
          defaultReps: firstReps,
          options: [RoutineOption(exercise: item.key.toString())],
        ));
      }
    }

    return RoutineDraft(
      id: dataMap['id']?.toString() ?? nanoid(),
      name: dataMap['name']?.toString() ?? '',
      color: dataMap['color']?.toString(),
      slots: slots,
    );
  }

  final String id;
  final String name;
  final String? color;
  final List<RoutineSlot> slots;

  RoutineSlot? slotById(String slotId) {
    for (final s in slots) {
      if (s.id == slotId) return s;
    }
    return null;
  }

  /// Every exercise used anywhere in the routine. An exercise can appear only once, because the workout page can't hold the same exercise twice.
  Set<String> get usedExercises => {
    for (final s in slots)
      for (final o in s.options) o.exercise,
  };

  RoutineDraft copyWith({String? name, String? color, List<RoutineSlot>? slots}) =>
      RoutineDraft(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        slots: slots ?? this.slots,
      );

  // Blank slots are dropped.
  Map<String, dynamic> toJson() => {
    'data': {'name': name.trim(), 'id': id, 'color': color},
    'slots': [
      for (final s in slots)
        if (!s.isBlank) s.toJson(),
    ],
  };
}

class RoutineDraftNotifier extends Notifier<RoutineDraft> {
  RoutineDraftNotifier(this.seed);

  final RoutineSeed seed;

  @override
  RoutineDraft build() => RoutineDraft.fromRaw(seed.raw);

  void setName(String name) => state = state.copyWith(name: name);


  void addSlot() =>
      state = state.copyWith(slots: [...state.slots, RoutineSlot.empty()]);

  void removeSlot(String slotId) => state = state.copyWith(
    slots: [for (final s in state.slots) if (s.id != slotId) s],
  );

  /// [newIndex] follows Flutter's ReorderableListView convention.
  void moveSlot(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final slots = [...state.slots];
    slots.insert(newIndex, slots.removeAt(oldIndex));
    state = state.copyWith(slots: slots);
  }

  void setTitle(String slotId, String value) =>
      _updateSlot(slotId, (s) => s.copyWith(title: value));

  void setDefaultSets(String slotId, String value) =>
      _updateSlot(slotId, (s) => s.copyWith(defaultSets: value));

  void setDefaultReps(String slotId, String value) =>
      _updateSlot(slotId, (s) => s.copyWith(defaultReps: value));

  List<String> addExercises(String slotId, Iterable<String> names) {
    final used = {...state.usedExercises};
    final added = <RoutineOption>[];
    final skipped = <String>[];

    for (final name in names) {
      if (used.add(name)) {
        added.add(RoutineOption(exercise: name));
      } else {
        skipped.add(name);
      }
    }

    if (added.isNotEmpty) {
      _updateSlot(slotId, (s) => s.copyWith(options: [...s.options, ...added]));
    }
    return skipped;
  }

  void removeOption(String slotId, String exercise) => _updateSlot(
        slotId,
        (s) => s.copyWith(
          options: [for (final o in s.options) if (o.exercise != exercise) o],
        ),
      );

  /// An empty value clears the override, so the option inherits again.
  void setOptionSets(String slotId, String exercise, String value) =>
      _updateOption(slotId, exercise, (o) => o.withSets(value));

  void setOptionReps(String slotId, String exercise, String value) =>
      _updateOption(slotId, exercise, (o) => o.withReps(value));

  void setOptionNote(String slotId, String exercise, String value) =>
      _updateOption(slotId, exercise, (o) => o.withNote(value));

  void resetOption(String slotId, String exercise) =>
      _updateOption(slotId, exercise, (o) => o.withoutOverrides());

  void _updateSlot(String slotId, RoutineSlot Function(RoutineSlot) change) {
    state = state.copyWith(slots: [
      for (final s in state.slots) s.id == slotId ? change(s) : s,
    ]);
  }

  void _updateOption(
    String slotId,
    String exercise,
    RoutineOption Function(RoutineOption) change,
  ) {
    _updateSlot(
      slotId,
      (s) => s.copyWith(options: [
        for (final o in s.options) o.exercise == exercise ? change(o) : o,
      ]),
    );
  }
}