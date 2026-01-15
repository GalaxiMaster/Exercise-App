import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<Map> {
  @override
  Future<Map<String, dynamic>> build() async {
    return await getAllSettings();
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

class WorkoutDataNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    return await readData();
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
  }

  Future<void> deleteDay(String key) async {
    final stateVal = Map<String, dynamic>.from(state.value ?? {});
    stateVal.remove(key);
    state = AsyncData(stateVal);
    deleteKey(key);
  }
}

final workoutDataProvider = AsyncNotifierProvider<WorkoutDataNotifier, Map<String, dynamic>>(WorkoutDataNotifier.new);

class RecordsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    return await reloadRecords();
  }
  Future<Map<String, dynamic>> reloadRecords() async {
    final data = await readData();
    final recordsTemp = <String, Lift>{};

    for (final day in data.keys) {
      final exercises = data[day]['sets'];

      for (final exercise in exercises.keys) {
        final setsList = exercises[exercise];

        for (int i = 0; i < setsList.length; i++) {
          final lift = liftFromSet(setsList[i]);
          if (lift == null) continue;

          final current = recordsTemp[exercise];
          if (current == null || isBetter(lift, current)) {
            recordsTemp[exercise] = lift;
          }
        }
      }
    }
    Map<String, dynamic> records = {
      for (final e in recordsTemp.entries)
        e.key: {
          'weight': e.value.weight,
          'reps': e.value.reps,
        }
    };
    await writeData(
      records,
      path: 'records',
      append: false,
    );
    return records;
  }
  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    state.whenData((data) async {
      await writeData(
        data,
        path: 'records',
        append: false,
      );
    });
  }

  int? bestSetIndex(List sets) {
    int? bestIndex;
    Lift? bestLift;

    for (int i = 0; i < sets.length; i++) {
      final lift = liftFromSet(sets[i]);
      if (lift == null) continue;

      if (bestLift == null || isBetter(lift, bestLift)) {
        bestLift = lift;
        bestIndex = i;
      }
    }
    return bestIndex;
  }
  void writeNewRecords(Map exerciseData) {
    for (var exercise in exerciseData.keys){
      for (var set in exerciseData[exercise]){
        if (set['PR'] == 'yes'){    
          Map? currentPr = state.value![exercise];
          if (currentPr == null){
            updateValue(exercise, set);
          }
          else if (double.parse(set['weight'].toString()) > double.parse(currentPr['weight'].toString()) 
            || (double.parse(set['weight'].toString()) == double.parse(currentPr['weight'].toString()) 
              && double.parse(set['reps'].toString()) > double.parse(currentPr['reps'].toString())))
            {
            updateValue(exercise, set);
          }
        }
      }
    }
  }
}

final recordsProvider = AsyncNotifierProvider<RecordsNotifier, Map<String, dynamic>>(RecordsNotifier.new);
