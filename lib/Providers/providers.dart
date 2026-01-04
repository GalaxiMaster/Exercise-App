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