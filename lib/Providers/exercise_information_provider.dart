import 'dart:convert';
import 'package:exercise_app/file_handling.dart';
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

class CustomExercisesNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    return await ref.read(storageServiceProvider).readData(path: 'customExercises');
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    ref.read(storageServiceProvider).writeKey(key, value, path: 'customExercises');
  }

  Future<void> deleteExercise(String key) async {
    final updated = {...state.value ?? {}}..remove(key);
    state = AsyncData(updated);
    await ref.read(storageServiceProvider).deleteKey(key, path: 'customExercises');
  }
}

final customExercisesAsyncProvider = AsyncNotifierProvider<CustomExercisesNotifier, Map<String, dynamic>>(
  CustomExercisesNotifier.new,
);

final customExercisesProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(customExercisesAsyncProvider).value ?? {};
});

class ExerciseGroupingRepository {
  Future<Map<String, Map>> loadExercises() async {
    final raw = await rootBundle.loadString('data/grouped_exercises.json');
    final Map<String, Map> jsonMap = jsonDecode(raw).cast<String, Map>();

    return jsonMap;
  }
}

final exerciseGroupingRepositoryProvider = Provider<ExerciseGroupingRepository>((ref) {
  return ExerciseGroupingRepository();
});

final exerciseGroupingAsyncProvider = FutureProvider<Map<String, Map>>((ref) async {
  final repo = ref.watch(exerciseGroupingRepositoryProvider);
  return repo.loadExercises();
});

final exerciseGroupingProvider = Provider<Map<String, Map>>((ref) {
  return ref.watch(exerciseGroupingAsyncProvider).value ?? {};
});
