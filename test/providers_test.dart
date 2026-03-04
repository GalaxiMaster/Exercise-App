import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStorageService extends Mock implements StorageService {}

// Helpers 

ProviderContainer makeContainer(MockStorageService mockStorage) {
  return ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(mockStorage)],
  );
}

void stubEmpty(MockStorageService mockStorage) {
  when(() => mockStorage.readData(path: any(named: 'path')))
      .thenAnswer((_) async => <String, dynamic>{});
  when(() => mockStorage.getAllSettings())
      .thenAnswer((_) async => <String, dynamic>{});
  when(() => mockStorage.writeData(any(),
          path: any(named: 'path'), append: any(named: 'append')))
      .thenAnswer((_) async {});
  when(() => mockStorage.writeKey(any(), any(), path: any(named: 'path')))
      .thenAnswer((_) async {});
  when(() => mockStorage.deleteKey(any(), path: any(named: 'path')))
      .thenAnswer((_) async {});
}

void main() {
  late MockStorageService mockStorage;
  late ProviderContainer container;

  setUp(() {
    mockStorage = MockStorageService();
    stubEmpty(mockStorage);
    container = makeContainer(mockStorage);
  });

  tearDown(() => container.dispose());

  // SETTINGS PROVIDER
  group('SettingsNotifier', () {
    test('build() loads settings from storage', () async {
      when(() => mockStorage.getAllSettings()).thenAnswer(
        (_) async => {'theme': 'dark', 'units': 'kg'},
      );

      final state = await container.read(settingsProvider.future);

      expect(state['theme'], 'dark');
      expect(state['units'], 'kg');
    });

    test('updateValue() updates state immediately', () async {
      await container.read(settingsProvider.future);
      container.read(settingsProvider.notifier).updateValue('units', 'lbs');

      final state = container.read(settingsProvider).value;
      expect(state?['units'], 'lbs');
    });

    test('updateValue() writes to storage with correct path', () async {
      await container.read(settingsProvider.future);
      container.read(settingsProvider.notifier).updateValue('units', 'lbs');

      verify(() => mockStorage.writeKey('units', 'lbs', path: 'settings'))
          .called(1);
    });

    test('updateMuscleGoal() correctly sets a muscle goal', () async {
      await container.read(settingsProvider.future);
      container
          .read(settingsProvider.notifier)
          .updateMuscleGoal('Chest', 20.0);

      final state = container.read(settingsProvider).value;
      expect((state?['Muscle Goals'] as Map)['Chest'], 20.0);
    });

    test('updateMuscleGoal() preserves existing muscle goals', () async {
      when(() => mockStorage.getAllSettings()).thenAnswer(
        (_) async => {
          'Muscle Goals': {'Back': 15.0}
        },
      );
      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(settingsProvider.future);
      c.read(settingsProvider.notifier).updateMuscleGoal('Chest', 20.0);

      final goals = c.read(settingsProvider).value?['Muscle Goals'] as Map;
      expect(goals['Back'], 15.0);
      expect(goals['Chest'], 20.0);
    });

    test('writeState() with empty data falls back to storage', () async {
      when(() => mockStorage.getAllSettings())
          .thenAnswer((_) async => {'fallback': true});

      await container
          .read(settingsProvider.notifier)
          .writeState({}); // triggers guard

      final state = container.read(settingsProvider).value;
      expect(state?['fallback'], true);
    });
  });

  group('WorkoutDataNotifier', () {
    test('build() loads workout data and calculates stats', () async {
      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => {
                '2024-01-01 session1': {'sets': {}},
                '2024-01-08 session2': {'sets': {}},
              });

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(workoutDataProvider.future);
      final notifier = c.read(workoutDataProvider.notifier);

      expect(notifier.sessions, 2);
    });

    test('updateValue() adds a new key and updates state', () async {
      await container.read(workoutDataProvider.future);
      container
          .read(workoutDataProvider.notifier)
          .updateValue('2024-06-01 A', {'sets': {}});

      final state = container.read(workoutDataProvider).value;
      expect(state?.containsKey('2024-06-01 A'), true);
    });

    test('deleteDay() removes key from state', () async {
      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => {'2024-01-01 A': {}});
      when(() => mockStorage.deleteKey(any(), path: any(named: 'path')))
          .thenAnswer((_) async {});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(workoutDataProvider.future);
      await c.read(workoutDataProvider.notifier).deleteDay('2024-01-01 A');

      final state = c.read(workoutDataProvider).value;
      expect(state?.containsKey('2024-01-01 A'), false);
    });

    test('deleteDay() calls deleteKey on storage', () async {
      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => {'2024-01-01 A': {}});
      when(() => mockStorage.deleteKey(any(), path: any(named: 'path')))
          .thenAnswer((_) async {});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(workoutDataProvider.future);
      await c.read(workoutDataProvider.notifier).deleteDay('2024-01-01 A');

      verify(() => mockStorage.deleteKey('2024-01-01 A')).called(1);
    });

    // streak calculation
    test('setStats() calculates streak correctly for consecutive weeks', () async {
      final now = DateTime.now();
      final thisWeek =
          now.subtract(Duration(days: now.weekday - 1)); // Monday this week
      final lastWeek = thisWeek.subtract(const Duration(days: 7));

      String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => {
                '${fmt(thisWeek)} A': {},
                '${fmt(lastWeek)} B': {},
              });

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(workoutDataProvider.future);
      expect(c.read(workoutDataProvider.notifier).streak, greaterThanOrEqualTo(1));
    });

    test('setStats() streak is 0 for no workouts', () async {
      await container.read(workoutDataProvider.future);
      expect(container.read(workoutDataProvider.notifier).streak, 0);
      expect(container.read(workoutDataProvider.notifier).sessions, 0);
    });
  });

  group('RecordsNotifier', () {
    // Sample workout data with PRs
    final workoutWithPRs = {
      '2024-01-01 A': {
        'sets': {
          'Bench Press': [
            {'weight': '100', 'reps': '5', 'type': 'normal'},
            {'weight': '110', 'reps': '3', 'type': 'normal'},
          ]
        }
      }
    };

    test('_calculateRecords finds best lift per exercise', () async {
      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => workoutWithPRs);

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      final records = await c.read(recordsProvider.future);
      expect(records['Bench Press']?['weight'], 110.0);
    });

    test('_calculateRecords writes results to storage', () async {
      when(() => mockStorage.readData(path: any(named: 'path')))
          .thenAnswer((_) async => workoutWithPRs);

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(recordsProvider.future);

      verify(() => mockStorage.writeData(any(), path: 'records', append: false))
          .called(greaterThanOrEqualTo(1));
    });

    test('bestSetIndex() returns index of heaviest set', () async {
      await container.read(recordsProvider.future);
      final notifier = container.read(recordsProvider.notifier);

      final sets = [
        {'weight': '80', 'reps': '5', 'type': 'normal'},
        {'weight': '100', 'reps': '5', 'type': 'normal'},
        {'weight': '90', 'reps': '3', 'type': 'normal'},
      ];

      expect(notifier.bestSetIndex(sets), 1);
    });

    test('bestSetIndex() returns null for empty sets', () async {
      await container.read(recordsProvider.future);
      final notifier = container.read(recordsProvider.notifier);
      expect(notifier.bestSetIndex([]), null);
    });

    test('writeNewRecords() updates record for new PR', () async {
      await container.read(recordsProvider.future);
      final notifier = container.read(recordsProvider.notifier);

      notifier.writeNewRecords({
        'Squat': [
          {'weight': '150', 'reps': '5', 'PR': 'yes'}
        ]
      });

      final state = container.read(recordsProvider).value;
      expect(state?['Squat']?['weight'], '150');
    });

    test('writeNewRecords() does not downgrade an existing PR', () async {
      await container.read(recordsProvider.future);
      final notifier = container.read(recordsProvider.notifier);

      notifier.updateValue('Squat', {'weight': '200', 'reps': '5'});

      notifier.writeNewRecords({
        'Squat': [
          {'weight': '150', 'reps': '5', 'PR': 'yes'}
        ]
      });

      final state = container.read(recordsProvider).value;
      expect(state?['Squat']?['weight'], '200');
    });
  });

  // CUSTOM EXERCISES PROVIDER
  group('CustomExercisesNotifier', () {
    test('deleteExercise() removes key from state', () async {
      when(() => mockStorage.readData(path: 'customExercises'))
          .thenAnswer((_) async => {'Pull-up': {'muscles': ['Back']}});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(customExercisesProvider.future);
      await c.read(customExercisesProvider.notifier).deleteExercise('Pull-up');

      final state = c.read(customExercisesProvider).value;
      expect(state?.containsKey('Pull-up'), false);
    });

    test('deleteExercise() calls deleteKey on storage', () async {
      when(() => mockStorage.readData(path: 'customExercises'))
          .thenAnswer((_) async => {'Pull-up': {}});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(customExercisesProvider.future);
      await c.read(customExercisesProvider.notifier).deleteExercise('Pull-up');

      verify(() => mockStorage.deleteKey('Pull-up', path: 'customExercises'))
          .called(1);
    });
  });

  // ROUTINE DATA PROVIDER
  group('RoutineDataNotifier', () {
    test('updateValue() persists to routines path', () async {
      await container.read(routineDataProvider.future);
      container
          .read(routineDataProvider.notifier)
          .updateValue('routine_1', {'name': 'Push Day'});

      verify(() => mockStorage.writeData(any(), path: 'routines')).called(1);
    });

    test('deleteRoutine() removes key from state', () async {
      when(() => mockStorage.readData(path: 'routines'))
          .thenAnswer((_) async => {'routine_1': {'name': 'Push Day'}});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(routineDataProvider.future);
      c.read(routineDataProvider.notifier).deleteRoutine('routine_1');

      final state = c.read(routineDataProvider).value;
      expect(state?.containsKey('routine_1'), false);
    });

    test('updateColor() propagates color to matching workout days', () async {
      when(() => mockStorage.readData(path: 'routines'))
          .thenAnswer((_) async => {
                'routine_1': {
                  'data': <String, dynamic>{'color': 'blue'}
                }
              });

      when(() => mockStorage.readData()) // no path = workout data
          .thenAnswer((_) async => {
                '2024-01-01 A': {
                  'stats': <String, dynamic>{
                    'routineId': 'routine_1',
                    'color': 'blue'
                  }
                }
              });

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      // Read both providers so both build() calls complete
      await c.read(routineDataProvider.future);
      await c.read(workoutDataProvider.future);

      await c.read(routineDataProvider.notifier).updateColor('routine_1', 'red');

      final routineState = c.read(routineDataProvider).value;
      expect(routineState?['routine_1']?['data']?['color'], 'red');

      final workoutState = c.read(workoutDataProvider).value;
      expect(workoutState?['2024-01-01 A']?['stats']?['color'], 'red');
    });
  });

  // CURRENT WORKOUT PROVIDER
  group('CurrentWorkoutNotifier', () {
    test('deleteExercise() removes exercise from state', () async {
      when(() => mockStorage.readData(path: 'current'))
          .thenAnswer((_) async => {'Deadlift': [{}]});

      final c = makeContainer(mockStorage);
      addTearDown(c.dispose);

      await c.read(currentWorkoutProvider.future);
      await c
          .read(currentWorkoutProvider.notifier)
          .deleteExercise('Deadlift');

      expect(
          c.read(currentWorkoutProvider).value?.containsKey('Deadlift'), false);
    });

    test('writeState() replaces state entirely', () async {
      await container.read(currentWorkoutProvider.future);
      await container
          .read(currentWorkoutProvider.notifier)
          .writeState({'Squat': []});

      final state = container.read(currentWorkoutProvider).value;
      expect(state?.keys.length, 1);
      expect(state?.containsKey('Squat'), true);
    });
  });
}