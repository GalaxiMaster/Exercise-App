import 'package:exercise_app/file_handling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<Map> {
  @override
  Future<Map<String, dynamic>> build() async {
    return await readData(path: 'settings');
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
  }
  
  Future<void> saveSettings() async {
    final Map<String, dynamic>? currentSettings = state.value as Map<String, dynamic>?;
    if (currentSettings != null) {
      await writeData(currentSettings, path: 'settings');
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map>(SettingsNotifier.new);

class CustomExercisesNotifier extends AsyncNotifier<Map> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    return await readData(path: 'customExercises');
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
  }
  
  Future<void> deleteExercise(String key) async {
    Map stateVal = state.value ?? {};
    stateVal.remove(key);
    state = AsyncData({
      ...stateVal
    });
    deleteKey(key, path: 'customExercises');
  }
}

final customExercisesProvider = AsyncNotifierProvider<CustomExercisesNotifier, Map>(CustomExercisesNotifier.new);