import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual.dart';
import 'package:exercise_app/Pages/Day_Screen_Individual/day_screen_individual_models.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_providers.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Every past workout that included these exercises, newest first.
class ExerciseHistoryTab extends ConsumerWidget {
  const ExerciseHistoryTab({super.key, required this.exercises});

  final List<String> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(exerciseHistoryProvider(ExerciseKey(exercises)));
    return history.when(
      data: (days) => days.isEmpty
        ? const Center(
            child: Text(
              'No history for this exercise yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) => _HistoryDay(day: days[index]),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _HistoryDay extends ConsumerWidget {
  const _HistoryDay({required this.day});

  final ExerciseHistoryDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);

    return Column(
      children: [
        _HistoryDayHeader(workout: day.workout),
        for (final exercise in day.exercises)
          _HistoryExercise(
            exercise: exercise,
            name: getDisplayName(exercises, exercise.id),
          ),
      ],
    );
  }
}

/// The date and time; tap to open that workout.
class _HistoryDayHeader extends StatelessWidget {
  const _HistoryDayHeader({required this.workout});

  final DayWorkout workout;

  @override
  Widget build(BuildContext context) {
    final start = workout.start;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualDayScreen(dayKey: workout.key),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            Text(
              // Falls back to the stored key if the start time can't be read.
              start == null ? workout.key : DateFormat('dd MMM, yyyy').format(start),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            if (start != null)
              Text(
                DateFormat('h:mma').format(start).toLowerCase(),
                style: TextStyle(fontSize: 16, color: muted),
              ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryExercise extends StatelessWidget {
  const _HistoryExercise({required this.exercise, required this.name});

  final DayExercise exercise;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ExerciseAvatar(exerciseId: exercise.id),
              Text(name),
            ],
          ),
        ),
        _HistorySetTable(exercise: exercise),
      ],
    );
  }
}

class _HistorySetTable extends StatelessWidget {
  const _HistorySetTable({required this.exercise});

  final DayExercise exercise;

  @override
  Widget build(BuildContext context) {
    final timed = exercise.type == ExerciseType.timed;

    return Table(
      border: const TableBorder.symmetric(inside: BorderSide.none),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            const _HeaderCell('Set'),
            _HeaderCell(timed ? 'Time (s)' : 'Weight (kg)'),
            if (!timed) const _HeaderCell('Reps'),
          ],
        ),
        for (var i = 0; i < exercise.sets.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isOdd ? ThemeColors.bg : ThemeColors.accent,
            ),
            children: [
              _BodyCell(
                Text(
                  exercise.sets[i].type.badge ?? '${exercise.normalNumberOf(i)}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              _BodyCell(
                exercise.type == ExerciseType.bodyweight
                    ? const Text('-', style: TextStyle(fontSize: 33.5))
                    : Text(
                        exercise.sets[i].weightText,
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              if (!timed)
                _BodyCell(
                  Text(
                    exercise.sets[i].repsText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Center(child: Text(label)),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 50, child: Center(child: child));
  }
}