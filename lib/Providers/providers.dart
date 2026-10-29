import 'dart:ui';

import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Functions/file_handling.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return await ref.read(storageServiceProvider).getAllSettings();
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    ref.read(storageServiceProvider).writeKey(key, value, path: 'settings');
  }
  
  Future<void> saveSettings() async {
    final Map<String, dynamic>? currentSettings = state.value;
    if (currentSettings != null) {
      ref.read(storageServiceProvider).writeData(currentSettings, path: 'settings');
    }
  }

  Future<void> writeState(Map<String, dynamic> data) async {
    if (data.isEmpty) { // Guard
      data = await ref.read(storageServiceProvider).getAllSettings();
    }
    state = AsyncData(data);
    // TODO, validate
    await ref.read(storageServiceProvider).writeData(data, path: 'settings', append: false);
  }

  void updateMuscleGoal(String muscle, double newGoal) {
    final currentSettings = state.value ?? {};
    final muscleGoals = Map<String, dynamic>.from(currentSettings['Muscle Goals'] ?? {});
    muscleGoals[muscle] = newGoal;

    final updatedSettings = {
      ...currentSettings,
      'Muscle Goals': muscleGoals,
    };

    state = AsyncData(updatedSettings);
    ref.read(storageServiceProvider).writeKey('Muscle Goals', muscleGoals, path: 'settings');
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(SettingsNotifier.new);

class WorkoutDataNotifier extends AsyncNotifier<Map<String, dynamic>> {
  int sessions = 0;
  int streak = 0;
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    final data = await ref.read(storageServiceProvider).readData();
    setStats(data);
    return data;
  }
  void updateValue(String key, dynamic value) {
    Map<String, dynamic> oldState = state.value ?? {};
    bool isNewKey = !oldState.containsKey(key);

    Map<String, dynamic> newState = {
      ...oldState,
      key: value
    };

    if (isNewKey) {
      setStats(newState);
    }
    state = AsyncData(newState);
    ref.read(storageServiceProvider).writeData(newState);
  }

  Future<void> writeState(Map<String, dynamic> data) async {
    state = AsyncData(data);
    return ref.read(storageServiceProvider).writeData(data, append: false);
  }

  Future<void> deleteDay(String key) async {
    final stateVal = Map<String, dynamic>.from(state.value ?? {});
    stateVal.remove(key);
    state = AsyncData(stateVal);
    setStats(state.value ?? {});
    ref.read(storageServiceProvider).deleteKey(key);
  }

  void setStats(Map<String, dynamic> data) async{
    int tempStreak = 0;
    List counted = [];
    int week = weekNumber(DateTime.now());
    List dayKeys = data.keys.toList();
    dayKeys.sort((a, b) => a.compareTo(b));
    for (final day in dayKeys.reversed) {
      final weekNum = weekNumber(DateTime.parse(day.split(' ')[0]));
      if (counted.contains(weekNum)) continue;
      counted.add(weekNum);

      if (week - weekNum <= 1) {
        tempStreak++;
        week = weekNum;
      } else {
        break;
      }
    }
    sessions = data.keys.length;
    streak = tempStreak;
  }
}

final workoutDataProvider = AsyncNotifierProvider<WorkoutDataNotifier, Map<String, dynamic>>(WorkoutDataNotifier.new);

final workoutHistoryProvider = Provider<WorkoutHistory>((ref) { // todo split all these providers into different files or at least comment some seperations
  final Map data = ref.watch(workoutDataProvider).value ?? const {};
  return WorkoutHistory(data);
});

class RecordsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    
    final workoutData = await ref.watch(workoutDataProvider.future);
    
    return _calculateRecords(workoutData);
  }

  Map<String, dynamic> _calculateRecords(Map<String, dynamic> data) {
    final recordsTemp = <String, Lift>{};

    for (final day in data.keys) {
      final exercises = Map<String, dynamic>.from(
        data[day]?['sets'] as Map? ?? {},
      );

      for (final exercise in exercises.keys) {
        final setsList = exercises[exercise] as List<dynamic>? ?? [];

        for (var setData in setsList) {
          final lift = liftFromSet(setData);
          if (lift == null) continue;

          final current = recordsTemp[exercise];
          if (current == null || isBetter(lift, current)) {
            recordsTemp[exercise] = lift;
          }
        }
      }
    }

    final records = {
      for (final e in recordsTemp.entries)
        e.key: {
          'weight': e.value.weight,
          'reps': e.value.reps,
        }
    };

    ref.read(storageServiceProvider).writeData(records, path: 'records', append: false);

    return records;
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    ref.read(storageServiceProvider).writeKey(key, value, path: 'records');
  }
  
  Future<void> writeState(Map<String, dynamic> data) async {
    state = AsyncData(data);
    await ref.read(storageServiceProvider).writeData(data, path: 'records', append: false);
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
          Map? currentPr = state.value?[exercise];
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


final currentWorkoutAsyncProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.read(storageServiceProvider).readData(path: 'current');
  return Map<String, dynamic>.from(data);
});

class CurrentWorkoutNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    return ref.watch(currentWorkoutAsyncProvider).value ?? {};
  }

  Future<void> updateValue(String key, dynamic value) async {
    final updatedData = {...state, key: value};

    state = updatedData;
    await ref.read(storageServiceProvider).writeData(updatedData, path: 'current');
  }

  Future<void> writeState(Map<String, dynamic> data) async {
    state = data;
    await ref
        .read(storageServiceProvider)
        .writeData(data, path: 'current', append: false);
  }

  Future<void> deleteExercise(String key) async {
    final updatedData = Map<String, dynamic>.from(state)..remove(key);

    state = updatedData;
    await ref.read(storageServiceProvider).deleteKey(key, path: 'current');
  }
}

final currentWorkoutProvider = NotifierProvider<CurrentWorkoutNotifier, Map<String, dynamic>>(CurrentWorkoutNotifier.new );


final routineAsyncProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.read(storageServiceProvider).readData(path: 'routines');
  return Map<String, dynamic>.from(data);
});

class RoutineDataNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    return ref.watch(routineAsyncProvider).value ?? {};
  }

  void updateValue(String key, dynamic value) {
    state = {
      ...state,
      key: value,
    };
    ref.read(storageServiceProvider).writeData(state, path: 'routines');
  }
  
  Future<void> writeState(Map<String, dynamic> data) async {
    state = data;
    await ref.read(storageServiceProvider).writeData(data, path: 'routines', append: false);
  }

  Future<void> updateColor(String id, String color) async {
    final currentValue = Map<String, dynamic>.from(state)[id];
    currentValue['data'] = {
      ...Map<String, dynamic>.from(currentValue['data'] ?? {}),
      'color': color,
    };
    updateValue(id, currentValue);

    Map workoutData = await ref.read(workoutDataProvider.future);
    for (MapEntry day in workoutData.entries){
      if ((day.value['stats']?['routineId'] ?? '') == id) {
        day.value['stats']['color'] = color;
        ref.read(workoutDataProvider.notifier).updateValue(day.key, day.value);
      }
    }
  }

  void deleteRoutine(String key) {
    Map<String, dynamic> stateVal = state;
    stateVal.remove(key);
    state = stateVal;
    ref.read(storageServiceProvider).deleteKey(key, path: 'routines');
  }

  Color? getColorForRoutine(String routineId) {
    final routineData = state[routineId];
    if (routineData != null && routineData['data'] != null && routineData['data']['color'] != null) {
      return HexColor.fromHex(routineData['data']['color']);
    }
    return null;
  }
}

final routineDataProvider = NotifierProvider<RoutineDataNotifier, Map<String, dynamic>>(RoutineDataNotifier.new);

class CacheNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void put(String key, int value) {
    state = {...state, key: value};
  }

  void putAll(Map<String, int> entries) {
    state = {...state, ...entries};
  }

  void remove(String key) {
    final next = {...state}..remove(key);
    state = next;
  }

  void clear() => state = {};
}