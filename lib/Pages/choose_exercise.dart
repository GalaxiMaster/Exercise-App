import 'dart:convert';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutList extends StatefulWidget {
  final String setting;
  final List? problemExercises;
  final String? problemExercisesTitle;
  const WorkoutList({
    super.key, 
    required this.setting, 
    this.problemExercises, 
    this.problemExercisesTitle
  });

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  String query = '';
  late final List exerciseList;
  final Map<String, bool> _imageExistsCache = {};

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
      onTap: widget.setting == 'choose' 
        ? () => Navigator.pop(context, exercise)
        : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseScreen(exercise: exercise)
            )
          ),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isProblemExercise 
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      "Assets/profile.svg",
                      height: 35,
                      width: 35,
                    ),
                  )
                : FutureBuilder<bool>(
                    future: _checkFileExists("Assets/Exercises/$exercise.png"),
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
                            "Assets/Exercises/$exercise.png",
                            height: 50,
                            width: 50,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              "Assets/profile.svg",
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

    final filteredProblemExercises = widget.problemExercises
        ?.where((exercise) => containsAllCharacters(exercise, query))
        .toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
      ),
      body: CustomScrollView(
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
                filteredExercises[index], 
                false
              ),
              childCount: filteredExercises.length,
            ),
          ),
        ],
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
  // Load the asset manifest file, which lists all available assets
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final manifestMap = json.decode(manifestContent);

  // Check if the asset is in the manifest (i.e., it exists in the assets)
  if (manifestMap.containsKey(filePath)) {
    try {
      await rootBundle.load(filePath);
      debugPrint('yeah');
      return true;
    } catch (e) {
      debugPrint('Error while loading asset: $e');
      return false;
    }
  } else {
    debugPrint('Asset does not exist: $filePath');
    return false;
  }
}
