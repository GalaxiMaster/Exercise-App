import 'package:exercise_app/Pages/Routines/routines_draft_notifier.dart';
import 'package:exercise_app/utils.dart'; // getDisplayName
import 'package:flutter/material.dart';

/// "3 x 8-10", or an empty string when nothing is planned.
String targetLabel(({String sets, String reps}) target) {
  if (target.sets.isEmpty && target.reps.isEmpty) return '';
  String show(String value) => value.isEmpty ? '–' : value;
  return '${show(target.sets)} x ${show(target.reps)}';
}

class PendingSlotCard extends StatelessWidget {
  const PendingSlotCard({
    super.key,
    required this.slot,
    required this.exercises,
    required this.onPick,
    required this.onSkip,
  });

  final RoutineSlot slot;

  final Map exercises;
  final ValueChanged<String> onPick;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = slot.title.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        color: colors.surfaceContainerLow,
        clipBehavior: Clip.antiAlias, // keeps ripples inside the corners
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isEmpty ? 'Choose an exercise' : title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(onPressed: onSkip, child: const Text('Skip')),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colors.outlineVariant.withAlpha(200),
              indent: 14,
              endIndent: 14,
            ),
            for (final option in slot.options)
              SlotOptionTile(
                exercise: option.exercise,
                name: getDisplayName(exercises, option.exercise),
                option: option,
                target: slot.targetFor(option),
                onTap: () => onPick(option.exercise),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 2, 14, 10),
              child: Text(
                'Tap the one you want to use.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlotOptionTile extends StatelessWidget {
  const SlotOptionTile({
    super.key,
    required this.exercise,
    required this.name,
    required this.option,
    required this.target,
    required this.onTap,
    this.selected = false,
  });

  final String exercise;
  final String name;
  final RoutineOption option;
  final ({String sets, String reps}) target;
  final VoidCallback onTap;

  final bool selected;

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
    final hasTarget = target.sets.isNotEmpty || target.reps.isNotEmpty;

    return Material(
      color: selected ? Colors.grey.withAlpha(50) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
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
              if (hasTarget)
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
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showExerciseSwitcher(
  BuildContext context, {
  required String current,
  required Map exercises,
  RoutineSlot? slot,
  Map? groupMembers,
}) {
  final routine = (slot != null && slot.options.length > 1) ? slot : null;
  final group = (groupMembers != null && groupMembers.length > 1) ? groupMembers : null;
  if (routine == null && group == null) return Future.value(null);

  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => _ExerciseSwitcherSheet(
      current: current,
      exercises: exercises,
      slot: routine,
      groupMembers: group,
    ),
  );
}

enum _SwitchSource { routine, group }

class _ExerciseSwitcherSheet extends StatefulWidget {
  const _ExerciseSwitcherSheet({
    required this.current,
    required this.exercises,
    this.slot,
    this.groupMembers,
  });

  final String current;
  final Map exercises;
  final RoutineSlot? slot;
  final Map? groupMembers;

  @override
  State<_ExerciseSwitcherSheet> createState() => _ExerciseSwitcherSheetState();
}

class _ExerciseSwitcherSheetState extends State<_ExerciseSwitcherSheet> {
  late _SwitchSource _source = widget.slot != null ? _SwitchSource.routine : _SwitchSource.group;

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final group = widget.groupMembers;
    final hasBoth = slot != null && group != null;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: hasBoth
                ? SegmentedButton<_SwitchSource>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment(
                        value: _SwitchSource.routine,
                        label: Text('Routine options'),
                      ),
                      ButtonSegment(
                        value: _SwitchSource.group,
                        label: Text('Same group'),
                      ),
                    ],
                    selected: {_source},
                    onSelectionChanged: (selection) =>
                        setState(() => _source = selection.first),
                  )
                : null
          ),
          if (_source == _SwitchSource.routine && slot != null)
            for (final option in slot.options)
              SlotOptionTile(
                exercise: option.exercise,
                name: getDisplayName(widget.exercises, option.exercise),
                option: option,
                target: slot.targetFor(option),
                selected: option.exercise == widget.current,
                onTap: () => Navigator.pop(context, option.exercise),
              )
          else if (group != null)
            for (final member in group.entries)
              _GroupMemberTile(
                exercise: member.value.toString(),
                label: member.key.toString(),
                selected: member.value == widget.current,
                onTap: () => Navigator.pop(context, member.value.toString()),
              ),
        ],
      ),
    );
  }
}

/// One member of an exercise group (image and name), the same look the group
/// switcher always had.
class _GroupMemberTile extends StatelessWidget {
  const _GroupMemberTile({
    required this.exercise,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String exercise;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? Colors.grey.withAlpha(50) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/Exercises/$exercise.png',
                  height: 50,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(Icons.fitness_center, size: 22, color: colors.onSurfaceVariant),
                  ),
                ),
              ),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}