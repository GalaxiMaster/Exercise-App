import 'package:exercise_app/Pages/Add_Workout/achievement_popup.dart';
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Add_Workout/slot_picker.dart';
import 'package:exercise_app/Pages/Add_Workout/timer.dart';
import 'package:exercise_app/Pages/Add_Workout/workout_draft_notifier.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/Add_Workout/confirm_workout.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/models/workout_stats.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class AddWorkout extends ConsumerStatefulWidget {
  final WorkoutDetails? initialData;
  final bool editing;
  final WorkoutMetaData? metaData;

  final Map? routine;

  const AddWorkout({
    super.key,
    this.initialData,
    this.editing = false,
    this.metaData,
    this.routine,
  });

  @override
  AddWorkoutState createState() => AddWorkoutState();
}

class AddWorkoutState extends ConsumerState<AddWorkout> {
  final ScrollController _scrollController = ScrollController();

  late final WorkoutSeed _seed = WorkoutSeed(
    initialData: widget.initialData,
    editing: widget.editing,
    metaData: widget.metaData,
    routine: widget.routine,
  );

  /// Call methods on the draft (add set, swap, validate)
  WorkoutDraftNotifier get _draft => ref.read(workoutDraftProvider(_seed).notifier);

  // read the current draft value
  WorkoutDraft get _state => ref.read(workoutDraftProvider(_seed));

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider(_seed));
    final settings = WorkoutSettings.fromMap(
      ref.watch(settingsProvider).value ?? const {},
    );
    final history = ref.watch(workoutHistoryProvider);
    final Map<String, Exercise> exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: myAppBar(
        context,
        'Workout',
        button: MyIconButton(
          icon: Icons.check,
          width: 37,
          height: 37,
          borderRadius: 10,
          iconHeight: 20,
          iconWidth: 20,
          onTap: _confirm,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            for (final item in draft.items)
              _buildItem(item, settings, history, exercises),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _addExercise,
                child: const Text('Select Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // actions

  Future<void> _addExercise() async {
    final Map workoutData = ref.read(workoutDataProvider).value ?? const {};
    final ChooseExerciseResponse? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutList(setting: 'choose', preData: workoutData),
      ),
    );
    if (!mounted || result == null || result.selectedExercises.isEmpty) return;

    _draft.addExercises(result.selectedExercises);

        final first = result.selectedExercises.first;
    final group = ref.read(exercisesProvider)[first]?.group;
    final groupCount = ref.read(exerciseGroupingProvider)[group]?.length ?? 0;
    if (result.listType == ExerciseListType.grouped &&
        result.selectedExercises.length == 1 &&
        groupCount > 1) {
      final entry = _state.entryNamed(first);
      if (entry != null) await _switchExerciseInGroup(entry);
    }
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 300);
    }
  }

  Future<void> _swapViaPicker(ExerciseEntry entry) async {
    final response = await Navigator.push<ChooseExerciseResponse>(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutList(setting: 'choose', multiSelect: false),
      ),
    );
    if (!mounted) return;
    final newName = response?.selectedExercises.first;
    if (newName != null) _draft.swapExercise(entry, newName);
  }

  Future<void> _switchExerciseInGroup(ExerciseEntry entry) async {
    final exercises = ref.read(exercisesProvider);
    final groups = ref.read(exerciseGroupingProvider);
    final Map? groupData = groups[exercises[entry.name]?.group];
    if (groupData == null) return;

    final String? newName = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: ListView.builder(
          itemCount: groupData.length,
          itemBuilder: (context, index) {
            final MapEntry item = groupData.entries.toList()[index];
            final bool isCurrent = item.value == entry.name;
            return InkWell(
              onTap: () => Navigator.pop(context, item.value),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isCurrent ? Colors.grey.withAlpha(50) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        "assets/Exercises/${item.value}.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                    Expanded(child: Text(item.key)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    if (!mounted || newName == null) return;
    _draft.swapExercise(entry, newName);
  }

  Future<void> _confirm() async {
    if (!_draft.validate()) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please enter a number in every weight and reps field.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Unchosen routine slots are dropped from the saved workout.
    final unfilled = _state.pendingSlots.length;
    if (unfilled > 0) {
      final finish = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Slots not filled'),
          content: Text(
            unfilled == 1
                ? '1 routine slot has no exercise chosen. Finish without it?'
                : '$unfilled routine slots have no exercise chosen. Finish without them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Go back'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Finish anyway'),
            ),
          ],
        ),
      );
      if (finish != true || !mounted) return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmWorkout(
          data: _state.toDetails(),
          editing: widget.editing,
        ),
      ),
    );
  }

  /// Focus the first field the user needs to fill in on a new set.
  void _focusFirstField(ExerciseEntry entry, SetEntry set) {
    if (entry.type.isTimed) return;
    final field = entry.type.hidesWeightInput ? SetField.reps : SetField.weight;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(set.focusFor(field));
      set.selectAll(field);
    });
  }

  /// Keyboard "done": add a set after the last one, else jump to the next set's same field.
  void _onSubmitted(ExerciseEntry entry, SetEntry set, SetField field) {
    final index = entry.sets.indexOf(set);
    if (index == entry.sets.length - 1) {
      _focusFirstField(entry, _draft.addSet(entry));
    } else {
      FocusScope.of(context).requestFocus(entry.sets[index + 1].focusFor(field));
    }
  }

  /// [fromTick]: true when the result came from ticking a box. With tick boxes enabled the popup shows only on tick; otherwise it shows on edit.
  void _maybePopup(
    ExerciseEntry entry,
    SetEntry set,
    PRResult result,
    WorkoutSettings settings, {
    required bool fromTick,
  }) {
    if (!result.isPR || settings.tickBoxes != fromTick) return;

    final subtitle = switch (result.type) {
      PRType.weight => 'Heaviest Weight - ${set.weightText} kg',
      PRType.reps   => 'Highest Reps - ${set.repsText}',
      PRType.first  => 'First Record!',
      _             => '',
    };
    if (subtitle.isEmpty) return;

    AchievementPopup.show(
      context,
      title: entry.name,
      subtitle: subtitle,
      icon: Icons.emoji_events,
    );
  }

  // routine slots

  Widget _buildItem(
    WorkoutItem item,
    WorkoutSettings settings,
    WorkoutHistory history,
    Map<String, Exercise> exercises,
  ) {
    switch (item) {
      case ExerciseEntry():
        return _buildExerciseCard(item, settings, history, exercises);
      case PendingSlot():
        return PendingSlotCard(
          key: ValueKey('slot-${item.slot.id}'),
          slot: item.slot,
          exercises: exercises,
          onPick: (exercise) => _pickSlotOption(item, exercise),
          onSkip: () => _draft.skipSlot(item),
        );
    }
  }

  void _pickSlotOption(PendingSlot pending, String exercise) {
    if (_draft.pickOption(pending, exercise)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('That exercise is already in this workout')),
    );
  }

    Future<void> _openSwitcher(ExerciseEntry entry) async {
    final exercises = ref.read(exercisesProvider);
    final groups = ref.read(exerciseGroupingProvider);
    final Map? members = groups[exercises[entry.name]?.group];
 
    final chosen = await showExerciseSwitcher(
      context,
      current: entry.name,
      exercises: exercises,
      slot: entry.slot,
      groupMembers: members,
    );
    if (!mounted || chosen == null || chosen == entry.name) return;
 
    if (!_draft.swapExercise(entry, chosen)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That exercise is already in this workout')),
      );
    }
  }

  // exercise card
  Widget _buildExerciseCard(
    ExerciseEntry entry,
    WorkoutSettings settings,
    WorkoutHistory history,
    Map<String, Exercise> exercises,
  ) {
    return Column(
      key: ValueKey(entry.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseScreen(exercises: [entry.name]),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(
                      "assets/Exercises/${entry.name}.png",
                      height: 50,
                      width: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            "assets/profile.svg",
                            height: 35,
                            width: 35,
                            colorFilter: ColorFilter.mode(Colors.grey.shade900, BlendMode.srcATop),
                          ),
                        );
                      },
                    ),
                    Text(
                      exercises[entry.name]?.name ?? entry.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () => _openSwitcher(entry),
                      child: const Icon(Icons.compare_arrows, color: Colors.blueAccent),
                    ),
                  ),
                  if (entry.type.showsBodyweightButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            builder: (context) => MeasurementPopup(
                              initialMeasurement: settings.bodyweightText,
                            ),
                          );
                        },
                        child: const Icon(Icons.person_2_outlined, color: Colors.blueAccent),
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'Swap':
                          await _swapViaPicker(entry);
                        case 'Delete':
                          _draft.removeExercise(entry);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'Swap', child: Text('Swap')),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    elevation: 2,
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        // The routine's plan for this exercise
        if (entry.slot != null) _buildRoutineInfo(entry),

        // Notes field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            key: ValueKey('note-${entry.id}'),
            initialValue: entry.note,
            decoration: const InputDecoration(
              hintText: 'Enter your notes here...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            onChanged: (value) => _draft.setNote(entry, value),
          ),
        ),

        // Sets table
        Column(
          children: [
            _buildSetTableHeader(entry, settings),
            for (var i = 0; i < entry.sets.length; i++)
              _buildSetRow(entry, entry.sets[i], i, settings, history),
          ],
        ),

        // Add set button
        Center(
          child: ElevatedButton(
            onPressed: () => _focusFirstField(entry, _draft.addSet(entry)),
            child: const Text('Add Set'),
          ),
        ),
      ],
    );
  }

  /// Slot name, planned target and the routine's note for this exercise.
  /// Read-only: the editable [ExerciseEntry.note] below is what gets saved.
  Widget _buildRoutineInfo(ExerciseEntry entry) {
    final colors = Theme.of(context).colorScheme;
    final target = entry.routineTarget;
    final label = target == null ? '' : targetLabel(target);
    final slotTitle = entry.slot!.title.trim();
    final note = entry.routineNote;

    final parts = [
      if (slotTitle.isNotEmpty) slotTitle,
      if (label.isNotEmpty) 'Target $label',
    ];
    if (parts.isEmpty && note.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parts.isNotEmpty)
            Text(
              parts.join(' · '),
              style: TextStyle(fontSize: 13, color: colors.primary),
            ),
          if (note.isNotEmpty)
            Text(
              note,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetTableHeader(ExerciseEntry entry, WorkoutSettings settings) {
    return Row(
      children: [
        const Expanded(flex: 1, child: Center(child: Text('Set'))),
        if (!entry.type.isTimed) ...[
          const Expanded(flex: 2, child: Center(child: Text('Weight (kg)'))),
          const Expanded(flex: 2, child: Center(child: Text('Reps'))),
        ] else ...[
          const Expanded(flex: 2, child: Center(child: Text('Time (s)'))),
        ],
        if (settings.tickBoxes)
          const Expanded(flex: 1, child: Center(child: Icon(Icons.check))),
      ],
    );
  }

  // set row
  Widget _buildSetRow(
    ExerciseEntry entry,
    SetEntry set,
    int index,
    WorkoutSettings settings,
    WorkoutHistory history,
  ) {
    return SwipeDismissable(
      key: ValueKey(set.id), // stable per set, not the list index
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _focusFirstField(entry, _draft.addSet(entry, copyOf: set));
        } else {
          _draft.removeSet(entry, set);
        }
        return false;
      },
      maxSwipeFraction: 0.2,
      background: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Icon(Icons.repeat, color: Colors.teal),
          ),
          Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      child: Container(
        color: set.checked
            ? const Color.fromARGB(255, 111, 223, 36).withAlpha(175)
            : (index.isOdd ? ThemeColors.bg : ThemeColors.accent),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showSetTypeMenu(entry, set),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      set.type.badge ?? '${entry.normalSetNumber(set)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            _buildInputCell(entry, set, index, SetField.weight, settings, history),
            if (!entry.type.isTimed)
              _buildInputCell(entry, set, index, SetField.reps, settings, history),
            if (settings.tickBoxes)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    value: set.checked,
                    onChanged: (value) {
                      final checked = value ?? false;
                      final result = _draft.setChecked(entry, set, checked);
                      if (checked) {
                        _maybePopup(entry, set, result, settings, fromTick: true);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCell(
    ExerciseEntry entry,
    SetEntry set,
    int index,
    SetField field,
    WorkoutSettings settings,
    WorkoutHistory history,
  ) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: set.hasError(field)
                ? Colors.redAccent.withValues(alpha: .7)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7.5),
          ),
          child: Center(
            child: _buildInput(entry, set, index, field, settings, history),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    ExerciseEntry entry,
    SetEntry set,
    int index,
    SetField field,
    WorkoutSettings settings,
    WorkoutHistory history,
  ) {
    if (field == SetField.weight) {
      if (entry.type.hidesWeightInput) {
        return const Text('-', style: TextStyle(color: Colors.white, fontSize: 33.5));
      }
      if (entry.type.isTimed) {
        return SizedBox(
          height: 50,
          child: TimerScreen(
            updateVariable: (int seconds) {
              final result = _draft.setTimerSeconds(entry, set, seconds);
              _maybePopup(entry, set, result, settings, fromTick: false);
            },
          ),
        );
      }
    }

    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(field.inputPattern)),
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      focusNode: set.focusFor(field),
      controller: set.controllerFor(field),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: set.isPR ? colors.primary : colors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: history.previous(entry.name, entry.practicalSetCount(set), field, set.type),
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
      onChanged: (_) {
        final result = _draft.onFieldEdited(entry, set, field);
        _maybePopup(entry, set, result, settings, fromTick: false);
      },
      onFieldSubmitted: (_) => _onSubmitted(entry, set, field),
      onTap: () => set.selectAll(field),
    );
  }

  void _showSetTypeMenu(ExerciseEntry entry, SetEntry set) {
    final setNumber = entry.normalSetNumber(set);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final type in SetType.values)
              ListTile(
                leading: Text(
                  type.badge ?? '$setNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(type.storageName),
                onTap: () {
                  _draft.setSetType(entry, set, type);
                  Navigator.pop(sheetContext);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Set', style: TextStyle(color: Colors.red)),
              onTap: () {
                _draft.removeSet(entry, set);
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}