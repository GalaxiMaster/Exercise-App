import 'package:exercise_app/Pages/Routines/routines_draft_notifier.dart';
import 'package:flutter/widgets.dart';

enum ExerciseType {
  weighted('Weighted'),
  bodyweight('Bodyweight'),
  assisted('Assisted'),
  timed('Timed');

  const ExerciseType(this.storageName);

  final String storageName;

  /// Unknown or missing values fall back to [weighted].
  static ExerciseType parse(String? raw) => ExerciseType.values.firstWhere(
        (t) => t.storageName == raw,
        orElse: () => ExerciseType.weighted,
      );

  bool get isTimed => this == timed;

  /// Bodyweight exercises have no weight input (the weight is fixed at 1).
  bool get hidesWeightInput => this == bodyweight;

  /// Types that use the user's body weight, so show the measurement button.
  bool get showsBodyweightButton => this == bodyweight || this == assisted;

  /// Default text for a freshly created set.
  String get initialWeight => this == bodyweight ? '1' : '';
  String get initialReps => this == timed ? '1' : '';
}

enum SetType {
  warmup('Warmup', badge: 'W'),
  normal('Normal'),
  failure('Failure', badge: 'F'),
  dropset('Dropset', badge: 'D');

  const SetType(this.storageName, {this.badge});

  final String storageName;

  /// Short label shown in the set column. `null` means "show the set number".
  final String? badge;

  static SetType parse(String? raw) => SetType.values.firstWhere(
        (t) => t.storageName == raw,
        orElse: () => SetType.normal,
      );
}

/// Which of the two number inputs in a set row.
enum SetField {
  weight(r'^-?\d*\.?\d{0,2}'),
  reps(r'^-?\d*\.?\d{0,1}');

  const SetField(this.inputPattern);

  /// Allowed-input regex for the text field.
  final String inputPattern;
}

class SetEntry {
  SetEntry({
    required this.type,
    String weight = '',
    String reps = '',
    this.isPR = false,
    Map<String, dynamic>? extra,
  })  : weightController = TextEditingController(text: weight),
        repsController = TextEditingController(text: reps),
        weightFocus = FocusNode(),
        repsFocus = FocusNode(),
        _extra = extra ?? const {} {
    // Listeners capture this set's own objects, so they can never point at
    // the wrong field after other sets are removed.
    weightFocus.addListener(() {
      if (weightFocus.hasFocus) selectAll(SetField.weight);
    });
    repsFocus.addListener(() {
      if (repsFocus.hasFocus) selectAll(SetField.reps);
    });
  }

  /// A new empty set with the defaults for [exerciseType].
  factory SetEntry.blank(ExerciseType exerciseType) => SetEntry(
        type: SetType.normal,
        weight: exerciseType.initialWeight,
        reps: exerciseType.initialReps,
      );

  /// A copy of [other]'s type, weight and reps (swipe-to-repeat).
  factory SetEntry.copyOf(SetEntry other) => SetEntry(
        type: other.type,
        weight: other.weightText,
        reps: other.repsText,
        extra: Map.of(other._extra),
      );

  /// Parse from the saved map format. Unknown keys are kept and written back.
  factory SetEntry.fromJson(Map<String, dynamic> json) {
    final extra = Map<String, dynamic>.of(json)
      ..removeWhere((key, _) => _knownKeys.contains(key));
    return SetEntry(
      type: SetType.parse(json['type']?.toString()),
      weight: json['weight']?.toString() ?? '',
      reps: json['reps']?.toString() ?? '',
      isPR: json['PR'] == 'yes',
      extra: extra,
    );
  }

  static const _knownKeys = {'weight', 'reps', 'type', 'PR'};
  static int _nextId = 0;

  /// Stable identity for widget keys. Unlike the list index, it doesn't
  /// change when other sets are removed.
  final int id = _nextId++;

  SetType type;
  bool checked = false;
  bool isPR;
  bool weightError = false;
  bool repsError = false;

  final TextEditingController weightController;
  final TextEditingController repsController;
  final FocusNode weightFocus;
  final FocusNode repsFocus;
  final Map<String, dynamic> _extra;

  bool _disposed = false;

  String get weightText => weightController.text;
  String get repsText => repsController.text;

  /// Numbers are parsed from the text; `null` means empty or invalid.
  double? get weight => _parse(weightController.text);
  double? get reps => _parse(repsController.text);

  bool get isComplete => weight != null && reps != null;

  TextEditingController controllerFor(SetField field) =>
      field == SetField.weight ? weightController : repsController;

  FocusNode focusFor(SetField field) =>
      field == SetField.weight ? weightFocus : repsFocus;

  bool hasError(SetField field) =>
      field == SetField.weight ? weightError : repsError;

  void setError(SetField field, bool value) {
    if (field == SetField.weight) {
      weightError = value;
    } else {
      repsError = value;
    }
  }

  void selectAll(SetField field) {
    final controller = controllerFor(field);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  /// for storage
  Map<String, dynamic> toJson() => {
        ..._extra,
        'weight': weightController.text,
        'reps': repsController.text,
        'type': type.storageName,
        'PR': isPR ? 'yes' : 'no',
      };

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    weightController.dispose();
    repsController.dispose();
    weightFocus.dispose();
    repsFocus.dispose();
  }

  /// Use when removing a set that is still on screen. Disposing immediately would break the row during its last frame.
  void disposeAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => dispose());
  }

  static double? _parse(String text) => double.tryParse(text.trim());
}

sealed class WorkoutItem {
  const WorkoutItem();
}

class PendingSlot extends WorkoutItem {
  const PendingSlot(this.slot);
  final RoutineSlot slot;
}

class ExerciseEntry extends WorkoutItem {
  ExerciseEntry({
    required this.name,
    required this.type,
    List<SetEntry>? sets,
    this.note = '',
    this.slot,
  }) : sets = sets ?? [SetEntry.blank(type)];

  static int _nextId = 0;

  /// static identity for widget keys
  final int id = _nextId++;

  String name;
  ExerciseType type;
  String note;
  final List<SetEntry> sets;

  /// The routine slot this exercise was chosen for
  final RoutineSlot? slot;

  ({String sets, String reps})? get routineTarget {
    final s = slot;
    if (s == null) return null;
    final option = s.optionFor(name);
    return option == null
        ? (sets: s.defaultSets, reps: s.defaultReps)
        : s.targetFor(option);
  }

  String get routineNote => slot?.optionFor(name)?.note ?? '';

  int normalNumberOf(SetEntry set) {
    var count = 0;
    for (final s in sets) {
      if (s.type != SetType.warmup) count++;
      if (identical(s, set)) break;
    }
    return count;
  }

  void dispose() {
    for (final s in sets) {
      s.dispose();
    }
  }

  void disposeAfterFrame() {
    for (final s in sets) {
      s.disposeAfterFrame();
    }
  }
}


class WorkoutSettings { // todo move the entire settings to models like this instead of just parsing it here
  const WorkoutSettings({
    this.tickBoxes = false,
    this.bodyweightText = '0',
  });

  factory WorkoutSettings.fromMap(Map raw) => WorkoutSettings(
        tickBoxes: raw['Tick Boxes'] == true,
        bodyweightText: raw['Bodyweight']?.toString() ?? '0',
      );

  final bool tickBoxes;
  final String bodyweightText;
}


class WorkoutHistory {
  WorkoutHistory(this._data);

  final Map _data;
  final Map<String, String> _cache = {};

  /// Newest workout first
  late final List _daysNewestFirst = _data.keys.toList().reversed.toList();

  /// [setNumber] is 1-based. Returns '0' when there is no matching history.
  String previous(
    String exercise,
    int setNumber,
    SetField field,
    SetType type,
  ) {
    final key = '$exercise|$setNumber|${field.name}|${type.name}';
    return _cache.putIfAbsent(key, () => _lookup(exercise, setNumber, field, type));
  }

  String _lookup(String exercise, int setNumber, SetField field, SetType type) {
    for (final day in _daysNewestFirst) {
      final exerciseSets = _data[day]['sets'];
      if (!exerciseSets.containsKey(exercise)) continue;
      final sets = exerciseSets[exercise] as List;
      if (setNumber - 1 >= sets.length) continue;
      final set = sets[setNumber - 1];
      if (set['type'] == type.storageName) {
        return (field == SetField.weight ? set['weight'] : set['reps']).toString();
      }
    }
    return '0';
  }

  int dayKeyCount(String day) {
    int count = 1;
    for (int i = 0; i < _data.keys.length; i++) {
      if (_data.keys.toList()[i]?.split(' ')[0] == day) {
        count++;
      }
    }
    return count;
  }
}