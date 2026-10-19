import 'package:exercise_app/Pages/Routines/routines_draft_notifier.dart';
import 'package:exercise_app/utils.dart'; // getDisplayName
import 'package:flutter/material.dart';

/// "3 x 8-10", or an empty string when nothing is planned.
String targetLabel(({String sets, String reps}) target) {
  if (target.sets.isEmpty && target.reps.isEmpty) return '';
  String show(String value) => value.isEmpty ? '–' : value;
  return '${show(target.sets)} x ${show(target.reps)}';
}

/// A routine slot that has several exercises and none chosen yet. Tap the one
/// you want and the card turns into that exercise's set table.
///
/// Styled like the routine editor's slot card: same fill, corners, divider and
/// caption, no border.
class PendingSlotCard extends StatelessWidget {
  const PendingSlotCard({
    super.key,
    required this.slot,
    required this.exercises,
    required this.onPick,
    required this.onSkip,
  });

  final RoutineSlot slot;

  /// The exercises map, used to show display names.
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

/// One exercise in a slot: image, name, routine note and planned target.
/// Each half of the target is accented when this exercise overrides the slot
/// default, same as in the routine editor.
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

  /// Highlights the current choice with the same grey tint the group
  /// switcher uses.
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

/// Bottom sheet listing a slot's exercises, with [current] highlighted like
/// the group switcher. Returns the chosen exercise id, or null if dismissed.
Future<String?> showSlotOptionSheet(
  BuildContext context, {
  required RoutineSlot slot,
  required Map exercises,
  required String current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              slot.title.trim().isEmpty ? 'Switch exercise' : slot.title.trim(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          for (final option in slot.options)
            SlotOptionTile(
              exercise: option.exercise,
              name: getDisplayName(exercises, option.exercise),
              option: option,
              target: slot.targetFor(option),
              selected: option.exercise == current,
              onTap: () => Navigator.pop(sheetContext, option.exercise),
            ),
        ],
      ),
    ),
  );
}