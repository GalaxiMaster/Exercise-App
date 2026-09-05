import 'dart:convert';
import 'package:exercise_app/models/exercise.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseRepository {
  Future<Map<String, Exercise>> loadExercises() async {
    final raw = await rootBundle.loadString('data/exercise_muscles.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw) as Map<String, dynamic>;

    return jsonMap.map(
      (key, value) => MapEntry(
        key,
        Exercise.fromJson(key, value as Map<String, dynamic>),
      ),
    );
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});
final exercisesAsyncProvider = FutureProvider<Map<String, Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.loadExercises();
});

final exercisesProvider = Provider<Map<String, Exercise>>((ref) {
  return ref.watch(exercisesAsyncProvider).value ?? {};
});