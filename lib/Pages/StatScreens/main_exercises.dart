import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class MainExercisesPage extends ConsumerStatefulWidget {
  const MainExercisesPage({super.key});
  
  @override
  ConsumerState<MainExercisesPage> createState() => _MainExercisesPageState();
}

class _MainExercisesPageState extends ConsumerState<MainExercisesPage> {
  bool multiSelect = false;
  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    final exerciseListProvider = ref.watch(mainExercisesProvider);
    final assetExistsAsync = ref.watch(exercisesWithAssetsProvider);

    ref.listen(exercisesWithAssetsProvider, (previous, next) {
      next.whenData((assetMap) {
        for (final entry in assetMap.entries) {
          if (entry.value && context.mounted) {
            precacheImage(
              AssetImage("assets/Exercises/${entry.key}.png"),
              context,
            );
          }
        }
      });
    });

    return Scaffold(
      appBar: myAppBar(context, 'Exercises'),
      body: exerciseListProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (exerciseData) {
          return assetExistsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildExerciseList(exerciseData, {}),
            data: (assetExists) => _buildExerciseList(exerciseData, assetExists),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(Map exerciseData, Map<String, bool> assetExists) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                selectorBox(
                  ref.watch(chartFilterProvider).muscleSelected,
                  'muscles',
                  (entry) => ref.read(chartFilterProvider.notifier).setMuscle(entry.key),
                  context,
                ),
                selectorBox(
                  ref.watch(chartFilterProvider).timeLabel,
                  'time',
                  (entry) => ref.read(chartFilterProvider.notifier).setRange(entry.value, entry.key),
                  context,
                ),
              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: exerciseData.keys.length,
                itemBuilder: (context, index) {
                  String exercise = exerciseData.keys.toList()[index];
                  return _buildExerciseItem(exercise, exerciseData, assetExists);
                },
              ),
            )
          ],
        ),
        if (multiSelect) _buildMultiSelectButton(),
      ],
    );
  }

  Widget _buildExerciseItem(String exercise, Map exerciseData, Map<String, bool> assetExists) {
    final isSelected = selectedItems.contains(exercise);
    
    return InkWell(
      onTap: () {
        if (multiSelect) {
          setState(() {
            if (selectedItems.contains(exercise)) {
              selectedItems.remove(exercise);
              if (selectedItems.isEmpty) {
                multiSelect = false;
              }
            } else {
              selectedItems.add(exercise);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseScreen(exercises: [exercise]),
            ),
          );
        }
      },
      onLongPress: () {
        setState(() {
          if (selectedItems.contains(exercise)) {
            selectedItems.remove(exercise);
            if (selectedItems.isEmpty) {
              multiSelect = false; // Fixed: was == instead of =
            }
          } else {
            if (!multiSelect) {
              multiSelect = true;
            }
            selectedItems.add(exercise);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 2,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
            assetExists[exercise] == true
                ? Image.asset(
                    "assets/Exercises/$exercise.png",
                    height: 50,
                    width: 50,
                  )
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/profile.svg",
                      height: 35,
                      width: 35,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise),
                  Text('${exerciseData[exercise]} times'),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseScreen(exercises: selectedItems),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                'Choose ${selectedItems.length} exercise(s)',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final exercisesWithAssetsProvider = FutureProvider<Map<String, bool>>((ref) async {
  final exerciseDataAsync = ref.watch(mainExercisesProvider);
  
  return exerciseDataAsync.when(
    loading: () => <String, bool>{},
    error: (_, __) => <String, bool>{},
    data: (exerciseData) async {
      final exercises = exerciseData.keys.toList();
      final futures = exercises.map((e) => fileExists("assets/Exercises/$e.png")).toList();
      final results = await Future.wait(futures);
      
      final assetMap = <String, bool>{};
      for (int i = 0; i < exercises.length; i++) {
        assetMap[exercises[i]] = results[i];
      }
      return assetMap;
    },
  );
});

final mainExercisesProvider = Provider<AsyncValue<Map>>((ref) {
  final rawDataAsync = ref.watch(workoutDataProvider);
  final filters = ref.watch(chartFilterProvider);

  return rawDataAsync.whenData((data) {
    Map exerciseMap = {};
    for (var day in data.keys) {
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0]));
      int diff = difference.inDays;
      if (diff <= filters.range || filters.range == -1) {
        for (var exercise in data[day]['sets'].keys) {
          for (String muscle in (muscleGroups[filters.muscleSelected] ?? ['muscle'])) {
            if ((exerciseMuscles[exercise]?['Primary'].containsKey(muscle) ?? false) ||
                filters.muscleSelected == 'All Muscles') {
              List sets = data[day]['sets'][exercise];
              String target = 'weight';
              (exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'Weighted' ? target = 'reps' : null;
              sets.sort((a, b) => double.parse(a[target].toString()).compareTo(double.parse(b[target].toString())));
              exerciseMap[exercise] = (exerciseMap[exercise] ?? 0) + 1;
              break;
            }
          }
        }
      }
    }
    List<MapEntry> entries = exerciseMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    exerciseMap = Map.fromEntries(entries);
    return exerciseMap;
  });
});

final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});