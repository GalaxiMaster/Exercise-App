import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutList extends StatefulWidget {
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
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  String query = '';
  late final List exerciseList;
  final Map<String, bool> _imageExistsCache = {};
  final List selectedItems = [];
  bool multiSelect = false;

  @override
  void initState() {
    super.initState();
    exerciseList = exerciseMuscles.keys.toList()..sort();
  }

  // Cache the file existence check
  Future<bool> _checkFileExists(String filePath) async {
    if (_imageExistsCache.containsKey(filePath)) {
      return _imageExistsCache[filePath]!;
    }
    
    final exists = await fileExists(filePath);
    _imageExistsCache[filePath] = exists;
    return exists;
  }

  Widget _buildExerciseItem(String exercise, bool isProblemExercise) {
    return InkWell(
      onTap: (){
        if (multiSelect){
          setState(() {
            if (selectedItems.contains(exercise)){
              selectedItems.remove(exercise);
              if (selectedItems.isEmpty){
                multiSelect = false;
              }
            }else{
              if (!multiSelect){
                multiSelect = true;
              }
              selectedItems.add(exercise);
            }  
          });
        }else{
          if(widget.setting == 'choose' ){
            Navigator.pop(context, [exercise]);
          }
          else{
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseScreen(exercises: [exercise])
                )
            );
          }
        }
      },
      onLongPress: (){
        if (widget.multiSelect){
          setState(() {
            if (selectedItems.contains(exercise)){
              selectedItems.remove(exercise);
              if (selectedItems.isEmpty){
                multiSelect == false;
              }
            }else{
              if (!multiSelect){
                multiSelect = true;
              }
              selectedItems.add(exercise);
            }  
          });
        }
      },
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            if (selectedItems.contains(exercise))
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
                    ),
                  )
                : FutureBuilder<bool>(
                    future: _checkFileExists("assets/Exercises/$exercise.png"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return snapshot.hasData && snapshot.data! 
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
                          );
                    },
                  ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise),
                if (!isProblemExercise) Text(getMuscles(exercise))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
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
                    filteredExercisesMap.keys.toList()[index], 
                    false
                  ),
                  childCount: filteredExercises.length,
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
      ),
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

String getMuscles(String exercise){
  var muscle = exerciseMuscles[exercise]?['Primary']?.keys.toList()[0];
  return muscle ?? 'No muscle';
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