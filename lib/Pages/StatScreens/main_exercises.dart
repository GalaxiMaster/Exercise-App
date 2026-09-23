import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';


class MainExerciseData {
  final Map individual;
  final Map grouped;

  MainExerciseData({required this.individual, required this.grouped});
}


class MainExercisesPage extends ConsumerStatefulWidget {
  const MainExercisesPage({super.key});
  
  @override
  ConsumerState<MainExercisesPage> createState() => _MainExercisesPageState();
}

class _MainExercisesPageState extends ConsumerState<MainExercisesPage> {
  bool multiSelect = false;
  List<String> selectedItems = [];
  final listTypeProvider = NotifierProvider<ListTypeNotifier, ExerciseListType>(ListTypeNotifier.new);

  @override
  Widget build(BuildContext context) {
    final exerciseListProvider = ref.watch(mainExercisesProvider);

    return Scaffold(
      appBar: 
      myAppBar(
        context, 
        'Exercises', 
        button: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GroupedToggleSwitch(
            isGrouped: ref.read(listTypeProvider) == ExerciseListType.grouped,
            onChanged: (value) => setState(() => ref.read(listTypeProvider.notifier).set(value ? ExerciseListType.grouped : ExerciseListType.individual)),
          ),
        ),
      ),
      body: exerciseListProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (exerciseData) {
          return _buildExerciseList(exerciseData);
        },
      ),
    );
  }

  Widget _buildExerciseList(MainExerciseData exerciseData) {
    final Map usedData = ref.read(listTypeProvider) == ExerciseListType.grouped ? exerciseData.grouped : exerciseData.individual;
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
                itemCount: usedData.keys.length,
                itemBuilder: (context, index) {
                  String exercise = usedData.keys.toList()[index];
                  return _buildExerciseItem(exercise, usedData);
                },
              ),
            )
          ],
        ),
        if (multiSelect) _buildMultiSelectButton(),
      ],
    );
  }

  Widget _buildExerciseItem(String exercise, Map exerciseData) {
    final isSelected = selectedItems.contains(exercise);
    final Map<String, Exercise> exercises = ref.watch(exercisesProvider);
    String exerciseId = exercise;
    if (ref.read(listTypeProvider.notifier).isGrouped) {
      exerciseId = ref.read(exerciseGroupingProvider)[exercise]?.values.first ?? exercise;
    }

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
              builder: (context) => ExerciseScreen(
                exercises: ref.read(listTypeProvider.notifier).isGrouped
                    ? (ref.read(exerciseGroupingProvider)[exercise]?.values
                            .cast<String>()
                            .toList() ??
                        [exercise])
                    : [exercise],
              ),
            ),
          );
        }
      },
      onLongPress: () {
        setState(() {
          if (selectedItems.contains(exercise)) {
            selectedItems.remove(exercise);
            if (selectedItems.isEmpty) {
              multiSelect = false;
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
            Image.asset(
              "assets/Exercises/$exerciseId.png",
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    "assets/profile.svg",
                    height: 35,
                    width: 35,
                    colorFilter: ColorFilter.mode(Colors.grey.shade900, BlendMode.srcATop),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercises[exercise]?.name ?? exercise),
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

final mainExercisesProvider = Provider.autoDispose<AsyncValue<MainExerciseData>>((ref) {
  final rawDataAsync = ref.watch(workoutDataProvider);
  final filters = ref.watch(chartFilterProvider);

  return rawDataAsync.whenData((data) {
    Map<String, Exercise> exercises = ref.watch(exercisesProvider);

    Map exerciseMap = {};
    Map groupedExerciseMap = {};
    for (var day in data.keys) {
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0]));
      int diff = difference.inDays;
      if (diff <= filters.range || filters.range == -1) {
        for (var exercise in data[day]['sets'].keys) {
          for (String muscle in (muscleGroups[filters.muscleSelected] ?? ['muscle'])) {
            if ((exercises[exercise]?.primary.containsKey(muscle) ?? false) ||
                filters.muscleSelected == 'All Muscles') {
              List sets = data[day]['sets'][exercise];
              String target = 'weight';
              (exercises[exercise]?.type ?? 'Weighted') != 'Weighted' ? target = 'reps' : null;
              sets.sort((a, b) => double.parse(a[target].toString()).compareTo(double.parse(b[target].toString())));
              exerciseMap[exercise] = (exerciseMap[exercise] ?? 0) + 1;
              final String? group = exercises[exercise]?.group;
              if (group != null && group.isNotEmpty) {
                groupedExerciseMap[group] = (groupedExerciseMap[group] ?? 0) + 1;
              }
              break;
            }
          }
        }
      }
    }
    List<MapEntry> entries = exerciseMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    exerciseMap = Map.fromEntries(entries);

    entries = groupedExerciseMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    groupedExerciseMap = Map.fromEntries(entries);

    return MainExerciseData(
      individual: exerciseMap,
      grouped: groupedExerciseMap,
    );
  });
});

final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});