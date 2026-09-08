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
    Map<String, dynamic> stateVal = state.value ?? {};
    stateVal.remove(key);
    state = AsyncData({
      ...stateVal
    });
    ref.read(storageServiceProvider).deleteKey(key, path: 'customExercises');
  }
}

final customExercisesProvider = AsyncNotifierProvider<CustomExercisesNotifier, Map<String, dynamic>>(CustomExercisesNotifier.new);