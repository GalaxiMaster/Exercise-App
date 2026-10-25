import 'package:exercise_app/Pages/Add_Workout/add_workout.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual_models.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class IndividualDayScreen extends ConsumerStatefulWidget {
  const IndividualDayScreen({super.key, required this.dayKey});

  final String dayKey;

  @override
  ConsumerState<IndividualDayScreen> createState() => _IndividualDayScreenState();
}

class _IndividualDayScreenState extends ConsumerState<IndividualDayScreen> {
  late String _dayKey = widget.dayKey;

  Future<void> _edit() async {
    final details = ref.read(dayDetailsProvider(_dayKey));
    if (details == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkout(initialData: details, editing: true),
      ),
    );
    if (!mounted || result is! Map) return;

    final stats = result['stats'];
    final startTime = stats is Map ? stats['startTime']?.toString() : null;
    if (startTime == null) return;

    final target = editedWorkoutKey(oldKey: _dayKey, newStartTime: startTime);
    final workouts = ref.read(workoutDataProvider.notifier);

    if (target.replacesOld) {
      workouts.deleteDay(_dayKey);
      setState(() => _dayKey = target.key);
    }
    workouts.updateValue(target.key, result);
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(dayWorkoutProvider(_dayKey));
    if (workout == null) {
      return _WorkoutPlaceholder(
        loaded: ref.watch(workoutDataProvider.select((a) => a.hasValue)),
      );
    }

    final Map<String, Exercise> exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: myAppBar(context, 'Workout Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DayHeader(workout: workout),
            _SummaryRow(summary: DaySummary.of(workout)),
            const _SectionDivider(),
            _MuscleSplitSection(dayKey: _dayKey),
            const _SectionDivider(),
            _WorkoutTitleRow(onEdit: _edit),
            for (final exercise in workout.exercises)
              _ExerciseSection(
                key: ValueKey(exercise.id),
                exercise: exercise,
                name: getDisplayName(exercises, exercise.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown while the data loads, or when the workout no longer exists.
class _WorkoutPlaceholder extends StatelessWidget {
  const _WorkoutPlaceholder({required this.loaded});

  final bool loaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Workout Details'),
      body: Center(
        child: loaded
            ? const Text('Workout not found')
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: .1, thickness: 0.5, color: Colors.grey);
  }
}

/// Date and start - end time.
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.workout});

  final DayWorkout workout;

  @override
  Widget build(BuildContext context) {
    final start = workout.start;
    final end = workout.end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            // Falls back to the stored key if the start time can't be read.
            start == null ? workout.key : DateFormat('EEEE dd MMM yyyy').format(start),
            style: const TextStyle(fontSize: 28),
          ),
        ),
        if (start != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            child: Row(
              children: [
                Text(
                  DateFormat('h:mm a').format(start),
                  style: const TextStyle(fontSize: 17),
                ),
                if (end != null) ...[
                  const Text('  -  '),
                  Text(
                    DateFormat('h:mm a').format(end),
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoBox(header: 'Time', content: formatDuration(summary.duration)),
          _InfoBox(header: 'Volume', content: '${summary.volume.toStringAsFixed(2)}kg'),
          _InfoBox(header: "PR's", content: '${summary.prs}'),
          _InfoBox(header: 'Sets', content: '${summary.sets}'),
          _InfoBox(header: 'Exercises', content: '${summary.exercises}'),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.header, required this.content});

  final String header;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(header, style: const TextStyle(fontSize: 15)),
        Text(content, style: const TextStyle(fontSize: 22)),
      ],
    );
  }
}

class _MuscleSplitSection extends ConsumerWidget {
  const _MuscleSplitSection({required this.dayKey});

  final String dayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final split = ref.watch(muscleSplitProvider(dayKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Muscle split', style: TextStyle(fontSize: 20)),
              // Placeholder until other chart types exist.
              Row(
                children: [
                  Text('Bar Chart', style: TextStyle(fontSize: 16)),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: split.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No muscle data for these exercises',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final share in split) _MuscleBar(share: share),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MuscleBar extends StatelessWidget {
  const _MuscleBar({required this.share});

  static const double _labelWidth = 56;

  final MuscleShare share;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(share.group, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final room = (constraints.maxWidth - _labelWidth).clamp(0.0, double.infinity).toDouble();
              final fraction = (share.percent / 100).clamp(0.0, 1.0).toDouble();

              return Row(
                children: [
                  Container(
                    width: room * fraction,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${share.percent}%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutTitleRow extends StatelessWidget {
  const _WorkoutTitleRow({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Workout', style: TextStyle(fontSize: 20)),
          InkWell(
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('Edit workout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

/// One exercise and its sets.
class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({
    super.key,
    required this.exercise,
    required this.name,
  });

  final DayExercise exercise;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                ExerciseAvatar(exerciseId: exercise.id),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(name, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          for (var i = 0; i < exercise.sets.length; i++)
            _SetRow(exercise: exercise, index: i),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.exercise, required this.index});

  final DayExercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    final set = exercise.sets[index];

    return Container(
      color: index.isOdd ? ThemeColors.bg : ThemeColors.accent,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            set.type.badge ?? '${exercise.normalNumberOf(index)}',
            style: const TextStyle(fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              set.describe(exercise.type),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}