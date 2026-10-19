import 'package:exercise_app/Pages/Routines/routines_draft_notifier.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _tabWidth = 32;
const double _tabGap = 8;

class AddRoutine extends ConsumerStatefulWidget {
  const AddRoutine({super.key, this.routine});

  final Map? routine;

  @override
  ConsumerState<AddRoutine> createState() => _AddRoutineState();
}

class _AddRoutineState extends ConsumerState<AddRoutine> {
  late final RoutineSeed _seed = RoutineSeed(widget.routine);

  RoutineDraftNotifier get _draft =>
      ref.read(routineDraftProvider(_seed).notifier);

  void _save() {
    final draft = ref.read(routineDraftProvider(_seed));
    if (draft.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your routine a name first')),
      );
      return;
    }
    ref.read(routineDataProvider.notifier).updateValue(draft.id, draft.toJson());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(routineDraftProvider(_seed));

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: SizedBox(
            width: 200,
            child: TextFormField(
              initialValue: draft.name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter routine name',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              onChanged: _draft.setName,
            ),
          ),
        ),
        actions: [
          Center(
            child: MyIconButton(
              icon: Icons.check,
              width: 37,
              height: 37,
              borderRadius: 10,
              iconHeight: 20,
              iconWidth: 20,
              onTap: _save,
            ),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false, // the left tab is the drag handle
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        itemCount: draft.slots.length,
        onReorderItem: _draft.moveSlot,
        itemBuilder: (context, index) {
          final slot = draft.slots[index];
          return _SlotCard(
            key: ValueKey(slot.id),
            seed: _seed, 
            slot: slot, 
            index: index
          );
        },
        footer: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              if (draft.slots.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Add a slot for each part of the workout.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ElevatedButton(
                onPressed: _draft.addSlot,
                child: const Text('Add Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One slot:
///
///   [drag] 1  Title ______________ [+]
///   [tab ] ┌────────────────────┐ [tab]
///          │ Default      3 x 10│ (multi-select)
///          ├────────────────────┤
///          │ pic Pushdown 3 x 10│
///          │ pic Overhead 4 x 8 │
///          └────────────────────┘
class _SlotCard extends ConsumerWidget {
  const _SlotCard({
    super.key,
    required this.seed,
    required this.slot,
    required this.index,
  });

  final RoutineSeed seed;
  final RoutineSlot slot;
  final int index;

  Future<void> _pickExercises(
    BuildContext context,
    WidgetRef ref, {
    required bool multi,
  }) async {
    final response = await Navigator.push<ChooseExerciseResponse>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutList(setting: 'choose', multiSelect: multi),
      ),
    );
    if (!context.mounted || response == null) return;

    final skipped = ref
        .read(routineDraftProvider(seed).notifier)
        .addExercises(slot.id, response.selectedExercises);

    if (skipped.isNotEmpty) {
      final Map exercises = ref.read(exercisesProvider);
      final names = skipped.map((e) => getDisplayName(exercises, e)).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already in this routine: $names')),
      );
    }
  }

  void _openOption(BuildContext context, String exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        // Lift the sheet above the keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: _OptionSheet(seed: seed, slotId: slot.id, exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.read(routineDraftProvider(seed).notifier);
    final Map exercises = ref.watch(exercisesProvider);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: number, title, "+"
          Row(
            children: [
              SizedBox(
                width: _tabWidth + _tabGap,
                child: Center(
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 20)),
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: slot.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Slot name (optional)',
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                  ),
                  onChanged: (v) => draft.setTitle(slot.id, v),
                ),
              ),
              SizedBox(
                width: _tabWidth + _tabGap,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Delete slot',
                  onPressed: () => draft.removeSlot(slot.id), // todo add confirmation dialog
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Body: left tab, card, right tab
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const _SideTab(
                    icon: Icons.drag_indicator,
                    side: _TabSide.left,
                    tooltip: 'Drag to reorder',
                  ),
                ),
                const SizedBox(width: _tabGap),
                Expanded(
                  child: Material(
                    color: colors.surfaceContainerLow,
                    clipBehavior: Clip.antiAlias, // keeps ripples inside the corners
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DefaultTargetRow(slot: slot, draft: draft),
                        Divider(height: 1, color: colors.outlineVariant.withAlpha(200), indent: 14, endIndent: 14),
                        if (slot.options.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'Tap the right tab to add exercises',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        else ...[
                          for (final option in slot.options)
                            _OptionRow(
                              exercise: option.exercise,
                              name: getDisplayName(exercises, option.exercise),
                              option: option,
                              target: slot.targetFor(option),
                              onTap: () => _openOption(context, option.exercise),
                              onRemove: () =>
                                  draft.removeOption(slot.id, option.exercise),
                            ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(14, 2, 14, 10),
                            child: Text(
                              'Tap one to customise it.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: _tabGap),
                _SideTab(
                  icon: Icons.checklist,
                  side: _TabSide.right,
                  tooltip: 'Select several exercises',
                  onTap: () => _pickExercises(context, ref, multi: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Default  3 x 10": the target every exercise in the slot inherits.
class _DefaultTargetRow extends StatelessWidget {
  const _DefaultTargetRow({required this.slot, required this.draft});

  final RoutineSlot slot;
  final RoutineDraftNotifier draft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Default for this slot:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 48,
            child: TextFormField(
              initialValue: slot.defaultSets,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'sets', isDense: true, hintStyle: TextStyle(fontSize: 15, color: Colors.grey)),
              onChanged: (v) => draft.setDefaultSets(slot.id, v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('x'),
          ),
          SizedBox(
            width: 72,
            child: TextFormField(
              initialValue: slot.defaultReps,
              // digits and a dash, so "8-12" works
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
              ],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'reps', isDense: true, hintStyle: TextStyle(fontSize: 15, color: Colors.grey)),
              onChanged: (v) => draft.setDefaultReps(slot.id, v),
            ),
          ),
        ],
      ),
    );
  }
}

/// One exercise in a slot. Each half of the target is grey when inherited
/// from the slot default and accented when this exercise overrides it.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.exercise,
    required this.name,
    required this.option,
    required this.target,
    required this.onTap,
    required this.onRemove,
  });

  final String exercise;
  final String name;
  final RoutineOption option;
  final ({String sets, String reps}) target;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inherited = TextStyle(color: colors.onSurfaceVariant, fontSize: 15);
    final custom = TextStyle(
      color: colors.primary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    String show(String value) => value.isEmpty ? '–' : value;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/Exercises/$exercise.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.fitness_center, size: 20, color: colors.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (option.note.isNotEmpty)
                    Text(
                      option.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: show(target.sets),
                    style: option.sets != null ? custom : inherited,
                  ),
                  TextSpan(text: ' x ', style: inherited),
                  TextSpan(
                    text: show(target.reps),
                    style: option.reps != null ? custom : inherited,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for one exercise: its own sets and reps (empty = use the slot
/// default), a note, reset and remove.
class _OptionSheet extends ConsumerStatefulWidget {
  const _OptionSheet({
    required this.seed,
    required this.slotId,
    required this.exercise,
  });

  final RoutineSeed seed;
  final String slotId;
  final String exercise;

  @override
  ConsumerState<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends ConsumerState<_OptionSheet> {
  late final TextEditingController _sets;
  late final TextEditingController _reps;

  @override
  void initState() {
    super.initState();
    final option = ref
        .read(routineDraftProvider(widget.seed))
        .slotById(widget.slotId)
        ?.optionFor(widget.exercise);
    _sets = TextEditingController(text: option?.sets ?? '');
    _reps = TextEditingController(text: option?.reps ?? '');
  }

  @override
  void dispose() {
    _sets.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(routineDraftProvider(widget.seed));
    final slot = draft.slotById(widget.slotId);
    final option = slot?.optionFor(widget.exercise);
    if (slot == null || option == null) return const SizedBox.shrink();

    final notifier = ref.read(routineDraftProvider(widget.seed).notifier);
    final Map exercises = ref.watch(exercisesProvider);

    String hint(String defaultValue) => defaultValue.isEmpty ? '–' : defaultValue;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getDisplayName(exercises, widget.exercise),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sets,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Sets',
                      hintText: hint(slot.defaultSets),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (v) =>
                        notifier.setOptionSets(widget.slotId, widget.exercise, v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _reps,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      hintText: hint(slot.defaultReps),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (v) =>
                        notifier.setOptionReps(widget.slotId, widget.exercise, v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Leave empty to use the slot default (shown in grey).',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: option.note,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'e.g. elbows tucked, slow negative',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              onChanged: (v) =>
                  notifier.setOptionNote(widget.slotId, widget.exercise, v),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: option.hasOverride
                      ? () {
                          _sets.clear();
                          _reps.clear();
                          notifier.resetOption(widget.slotId, widget.exercise);
                        }
                      : null,
                  child: const Text('Reset to slot default'),
                ),
                TextButton(
                  onPressed: () {
                    notifier.removeOption(widget.slotId, widget.exercise);
                    Navigator.pop(context);
                  },
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _TabSide { left, right }

/// The rounded tab on the screen edge beside a slot's card.
class _SideTab extends StatelessWidget {
  const _SideTab({
    required this.icon,
    required this.side,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final _TabSide side;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const round = Radius.circular(12);
    final radius = side == _TabSide.left
        ? const BorderRadius.horizontal(right: round)
        : const BorderRadius.horizontal(left: round);

    final tab = Material(
      color: colors.surfaceContainerHighest,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: _tabWidth,
          child: Center(child: Icon(icon, size: 20)),
        ),
      ),
    );

    return tooltip == null ? tab : Tooltip(message: tooltip!, child: tab);
  }
}