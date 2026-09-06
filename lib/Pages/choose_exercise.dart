import 'package:exercise_app/Pages/add_custom_exercise.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  late final List exerciseList;
  final List<String> selectedItems = [];
  bool multiSelect = false;
  bool loading = true;

  final cacheProvider = NotifierProvider<CacheNotifier, Map<String, int>>(CacheNotifier.new);

  @override
  void initState() {
    super.initState();
  }

  void fetchInitialData() async{
    if (!loading) return;
    Map exercises = ref.watch(exercisesProvider);
    exerciseList = exercises.keys.toList()..sort();
    checkAssets();
    setState(()=>loading = false);
  }

  Future<void> checkAssets() async {
    List exerciseCachedList = List.from(exerciseList);
    for (String exercise in exerciseCachedList) {
      String filePath = "assets/Exercises/$exercise.png";
      bool exists = await fileExists(filePath);
      ref.read(cacheProvider.notifier).put(exercise, exists ? 1 : 0);
      if (mounted){
        precacheImage(AssetImage("assets/Exercises/$exercise.png"), context);    
      }
    }
  }

  Widget _buildExerciseItem(Exercise exerciseData, bool isProblemExercise, {Map? customData}) {
    return InkWell(
      onTap: (){
        if (multiSelect){
          setState(() {
            if (selectedItems.contains(exerciseData.name)){
              selectedItems.remove(exerciseData.name);
              if (selectedItems.isEmpty){
                multiSelect = false;
              }
            }else{
              if (!multiSelect){
                multiSelect = true;
              }
              selectedItems.add(exerciseData.name);
            }  
          });
        }else{
          if(widget.setting == 'choose' ){
            Navigator.pop(context, [exerciseData.name]);
          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseScreen(exercises: [exerciseData.name])
              )
            );
          }
        }
      },
      onLongPress: (){
        if (widget.multiSelect){
          setState(() {
            if (selectedItems.contains(exerciseData.name)){
              selectedItems.remove(exerciseData.name);
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
              child: isProblemExercise 
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "assets/profile.svg",
                      height: 35,
                      width: 35,
                      colorFilter: ColorFilter.mode(Colors.red.shade400, BlendMode.srcATop),
                    ),
                  )
                  : ref.watch(cacheProvider.select((map) => map[exerciseData.id])) == 1
                    ? Image.asset(
                        "assets/Exercises/${exerciseData.id}.png",
                        height: 50,
                        width: 50,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          "assets/profile.svg",
                          height: 35,
                          width: 35,
                          colorFilter: ColorFilter.mode(Colors.grey.shade900, BlendMode.srcATop),
                        ),
                      ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseData.name),
                  if (!isProblemExercise && customData == null)
                    Text(exerciseData.primary.keys.toList().join(', '))
                  else if (customData != null)
                    Text('${customData['primary'].keys.toList().join(', ')}')
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
    final customExercisesAsync = ref.read(customExercisesProvider);

    fetchInitialData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
        actions: [
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
      body: loading ? CircularProgressIndicator() : customExercisesAsync.when(
        data: (data) {
          exerciseList.addAll(data.keys.toList());
          exerciseList.sort();
          final filteredExercises = exerciseList
              .where((exercise) => containsAllCharacters(exercise, query))
              .toList();

          Map filteredExercisesMap = Map.fromEntries(
            filteredExercises.map((value) => MapEntry(value, 0)),
          );
          if (widget.preData != null && query != ''){
            for (String day in widget.preData!.keys){
              for (String exercise in widget.preData![day]['sets'].keys){
                if (filteredExercises.contains(exercise)){
                  filteredExercisesMap[exercise] += 1;
                }
              }
            }
            var sortedEntries = filteredExercisesMap.entries.toList();

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

          final filteredProblemExercises = widget.problemExercises
              ?.where((exercise) => containsAllCharacters(exercise, query))
              .toList() ?? [];
          return Stack(
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
                        ref.watch(exercisesProvider)[filteredExercisesMap.keys.toList()[index]]!,
                        false,
                        customData: data[filteredExercisesMap.keys.toList()[index]]
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
                        Navigator.pop(context, selectedItems);
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
          );
        },
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      )
    );
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

Future<bool> fileExists(String filePath) async {
  try {
    await rootBundle.load(filePath);
    return true;
  } catch (e) {
    debugPrint('Asset does not exist: $filePath');
    return false;
  }
}