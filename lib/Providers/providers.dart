import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return await getAllSettings();
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    writeKey(key, value, path: 'settings');
  }
  
  Future<void> saveSettings() async {
    final Map<String, dynamic>? currentSettings = state.value;
    if (currentSettings != null) {
      writeData(currentSettings, path: 'settings');
    }
  }

  void updateState(Map<String, dynamic> data) {
    state = AsyncData(data);
    state.whenData((data){
      writeData(data, path: 'settings', append: false);
    });
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
    writeKey('Muscle Goals', muscleGoals, path: 'settings');
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(SettingsNotifier.new);

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
  int sessions = 0;
  int streak = 0;
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    final data = await readData();
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
    writeData(newState);
  }

  void updateState(Map<String, dynamic> data) {
    state = AsyncData(data);
    state.whenData((data){
      writeData(data, append: false);
    });
  }

  Future<void> deleteDay(String key) async {
    final stateVal = Map<String, dynamic>.from(state.value ?? {});
    stateVal.remove(key);
    state = AsyncData(stateVal);
    setStats(state.value ?? {});
    deleteKey(key);
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
      final exercises = data[day]['sets'] as Map<String, dynamic>? ?? {};

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

    writeData(records, path: 'records', append: false);

    return records;
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    writeKey(key, value, path: 'records');
  }
  
  void updateState(Map<String, dynamic> data) {
    state = AsyncData(data);
    state.whenData((data){
      writeData(data, path: 'records', append: false);
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

class CurrentWorkoutNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    ref.keepAlive();
    return await readData(path: 'current');
  }

  void updateValue(String key, dynamic value) {
    state = AsyncData({
      ...state.value ?? {},
      key: value,
    });
    state.whenData((data){
      writeData(data, path: 'current');
    });
  }
  
  void updateState(Map<String, dynamic> data) {
    state = AsyncData(data);
    state.whenData((data){
      writeData(data, path: 'current', append: false);
    });
  }

  Future<void> deleteExercise(String key) async {
    Map stateVal = state.value ?? {};
    stateVal.remove(key);
    state = AsyncData({
      ...stateVal
    });
    deleteKey(key, path: 'current');
  }
}

final currentWorkoutProvider = AsyncNotifierProvider<CurrentWorkoutNotifier, Map<String, dynamic>>(CurrentWorkoutNotifier.new);