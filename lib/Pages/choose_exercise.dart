import 'package:exercise_app/Pages/Exercise_screen/exercise_screen.dart';
import 'package:exercise_app/Pages/add_custom_exercise.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChooseExerciseResponse {
  final List<String> selectedExercises;
  final ExerciseListType listType;
  ChooseExerciseResponse(this.selectedExercises, this.listType);
}


enum ExerciseListType {
  grouped,
  individual,
}

class ListTypeNotifier extends Notifier<ExerciseListType> {
  @override
  ExerciseListType build() => ExerciseListType.grouped;

  void set(ExerciseListType value) => state = value;

  bool get isGrouped => state == ExerciseListType.grouped;
}

class WorkoutList extends ConsumerStatefulWidget {
  final String setting;
  final List? problemExercises;
  final String? problemExercisesTitle;
  final Map? preData;
  final bool multiSelect;

  const WorkoutList({
    super.key, 
    required this.setting, 
    this.problemExercises, 
    this.problemExercisesTitle,
    this.preData, 
    this.multiSelect = true,
  });

  @override
  ConsumerState<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends ConsumerState<WorkoutList> {
  String query = '';
  final List<String> selectedItems = [];
  bool multiSelect = false;

  // Effective list type for the current query. This can differ from the user's
  // stored preference (e.g. auto-switches to individual when no groups match),
  // and is what the toggle displays and what gets returned on pop.
  ExerciseListType _effectiveListType = ExerciseListType.grouped;

  final listTypeProvider = NotifierProvider<ListTypeNotifier, ExerciseListType>(ListTypeNotifier.new);

  @override
  void initState() {
    super.initState();
  }

  Widget _buildExerciseItem(Exercise exerciseData, bool isProblemExercise, {Exercise? customData}) {
    return InkWell(
      onTap: (){
        if (multiSelect){
          setState(() {
            if (selectedItems.contains(exerciseData.id)){
              selectedItems.remove(exerciseData.id);
              if (selectedItems.isEmpty){
                multiSelect = false;
              }
            }else{
              if (!multiSelect){
                multiSelect = true;
              }
              selectedItems.add(exerciseData.id);
            }  
          });
        }else{
          if(widget.setting == 'choose' ){
            Navigator.pop(context, ChooseExerciseResponse([exerciseData.id], _effectiveListType));
          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseScreen(exercises: [exerciseData.id])
              )
            );
          }
        }
      },
      onLongPress: (){
        if (widget.multiSelect){
          setState(() {
            if (selectedItems.contains(exerciseData.id)){
              selectedItems.remove(exerciseData.id);
              if (selectedItems.isEmpty){
                multiSelect == false;
              }
            }else{
              if (!multiSelect){
                multiSelect = true;
              }
              selectedItems.add(exerciseData.name);
            }  
          });
        }
      },
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            if (selectedItems.contains(exerciseData.name))
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 2,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                "assets/Exercises/${exerciseData.id}.png",
                height: 50,
                width: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/profile.svg",
                      height: 35,
                      width: 35,
                      colorFilter: ColorFilter.mode(isProblemExercise ? Colors.redAccent : Colors.grey.shade900, BlendMode.srcATop),
                    ),
                  );
                },
              )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseData.name),
                  if (!isProblemExercise && customData == null)
                    Text(exerciseData.primary.keys.toList().join(', '))
                  else if (customData != null)
                    Text(customData.primary.keys.toList().join(', ')) // todo move custom exercises to Exercise class and consider merging the providers
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    final customExercises = ref.watch(customExercisesProvider);
    final groupedExercises = ref.watch(exerciseGroupingProvider);
    final prefersGrouped = ref.watch(listTypeProvider) == ExerciseListType.grouped;

    final hasGroupMatches = groupedExercises.keys.any((e) => containsAllCharacters(e, query));

    final isGrouped = prefersGrouped && hasGroupMatches;

    // Keep the effective type in sync with what's actually being shown.
    // The stored preference (listTypeProvider) is never modified here, so the
    // UI switches back automatically once the query matches groups again.
    _effectiveListType = isGrouped ? ExerciseListType.grouped : ExerciseListType.individual;

    final filteredExercisesMap = search(groupedExercises, exercises, customExercises, isGrouped);

    final filteredProblemExercises = widget.problemExercises
        ?.where((exercise) => containsAllCharacters(exercise, query))
        .toList() ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
        actions: [
          GroupedToggleSwitch(
            isGrouped: isGrouped,
            onChanged: (value) => ref
                .read(listTypeProvider.notifier)
                .set(value ? ExerciseListType.grouped : ExerciseListType.individual),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCustomExercise(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SearchBar(onQueryChanged: (newQuery) {
                  setState(() => query = newQuery);
                }),
              ),
              if (widget.problemExercises != null) ...[
                SliverToBoxAdapter(
                  child: Text(widget.problemExercisesTitle ?? ''),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildExerciseItem(
                      filteredProblemExercises[index], 
                      true
                    ),
                    childCount: filteredProblemExercises.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Text('Normal Exercises'),
                ),
              ],
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildExerciseItem(
                    getExerciseById(filteredExercisesMap.keys.toList()[index], exercises, customExercises, groupedExercises, isGrouped),
                    false,
                    customData: customExercises[filteredExercisesMap.keys.toList()[index]]
                  ),
                  childCount: filteredExercisesMap.length,
                ),
              ),
            ],
          ),
          if (multiSelect)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: GestureDetector(
                onTap: (){
                  if(widget.setting == 'choose' ){
                    Navigator.pop(context, ChooseExerciseResponse(selectedItems, _effectiveListType));
                  }
                  else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseScreen(exercises: selectedItems)
                      )
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50)
                  ),
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Choose ${selectedItems.length} exercise(s)',
                      style: const TextStyle(
                        fontSize: 20
                      ),
                    )
                  ),
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  Map<dynamic, dynamic> search(
    Map<String, Map<dynamic, dynamic>> groupedExercises,
    Map<String, Exercise> exercises,
    Map<String, Exercise> customExercises,
    bool grouped,
  ) {
    List filteredExercises = grouped
        ? groupedExercises.keys
            .where((e) => containsAllCharacters(e, query))
            .toList()
        : [
            ...exercises.keys,
            ...customExercises.keys,
          ].where((e) => containsAllCharacters(e, query)).toList();

    filteredExercises.sort();

    Map filteredExercisesMap = Map.fromEntries(
      filteredExercises.map((value) => MapEntry(value, 0)),
    );

    if (widget.preData != null && query != '') {
      // exercise id -> group name (only needed in grouped mode)
      final Map<String, String> exerciseToGroup = {};
      if (grouped) {
        groupedExercises.forEach((groupName, variants) {
          for (final exerciseId in variants.values) {
            exerciseToGroup[exerciseId.toString()] = groupName;
          }
        });
      }

      for (final day in widget.preData!.keys) {
        for (final String exercise in widget.preData![day]['sets'].keys) {
          // In grouped mode, count usage towards the exercise's group
          final key = grouped ? exerciseToGroup[exercise] : exercise;
          if (key != null && filteredExercisesMap.containsKey(key)) {
            filteredExercisesMap[key] += 1;
          }
        }
      }

      final sortedEntries = filteredExercisesMap.entries.toList();
      sortedEntries.sort((a, b) {
        if (a.value > 0 && b.value > 0) {
          // Sort numerically where int > 0
          return b.value.compareTo(a.value);
        } else if (a.value == 0 && b.value == 0) {
          // Sort alphabetically where int == 0
          return a.key.compareTo(b.key);
        } else {
          // Keep sections separate: int > 0 before int == 0
          return b.value.compareTo(a.value);
        }
      });
      filteredExercisesMap = Map.fromEntries(sortedEntries);
    }
    return filteredExercisesMap;
  }

  Exercise getExerciseById(String id, Map<String, Exercise> exercises,
      Map<String, dynamic> customExercises,
      Map<String, Map<dynamic, dynamic>> groupedExercises, bool grouped) {
    final exercise = grouped
        ? exercises[groupedExercises[id]?.values.first]?.copyWith(name: id)
        : exercises[id];

    return exercise ?? Exercise(id: id, name: id, primary: {}, secondary: {}, type: '', group: '');
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onQueryChanged;

  const SearchBar({super.key, required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onQueryChanged,
        decoration: const InputDecoration(
          labelText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

bool containsAllCharacters(String exercise, String query) {
  if (query.isEmpty) {
    return true;
  }

  // Split the query into words
  List<String> queryWords = query.toLowerCase().split(' ');

  // Check if each word in queryWords exists as a consecutive substring in exercise
  for (String word in queryWords) {
    if (!exercise.toLowerCase().contains(word)) {
      return false;
    }
  }

  return true;
}