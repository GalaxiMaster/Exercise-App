import 'package:exercise_app/Pages/Exercise_screen/body_heat_map.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_models.dart';
import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseInfoTab extends ConsumerWidget {
  const ExerciseInfoTab({super.key, required this.exercises});

  final List<String> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(muscleBreakdownProvider(ExerciseKey(exercises)));

    if (breakdown.isEmpty) {
      return const Center(child: Text('No muscle data available'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          BodyHeatMap(
            assetPath: 'assets/Muscle_heatmap.svg',
            muscleMap: breakdown.heatMap,
          ),
          _MuscleList(title: 'Primary muscles:', shares: breakdown.primary),
          _MuscleList(title: 'Secondary muscles:', shares: breakdown.secondary),
        ],
      ),
    );
  }
}

class _MuscleList extends StatelessWidget {
  const _MuscleList({required this.title, required this.shares});

  final String title;
  final Map<String, double> shares;

  @override
  Widget build(BuildContext context) {
    final entries = shares.entries.toList();

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('${entry.value}% ${entry.key}'),
              );
            },
          ),
        ),
      ],
    );
  }
}