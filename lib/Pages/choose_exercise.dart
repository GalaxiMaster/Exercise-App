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
  const WorkoutList({super.key, required this.setting, this.problemExercises, this.problemExercisesTitle});

  @override
  // ignore: library_private_types_in_public_api
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  String query = '';
  List exerciseList = exerciseMuscles.keys.toList();

  @override
  Widget build(BuildContext context) {
    exerciseList.sort();
    widget.problemExercises?.sort();
    var filteredExercises = exerciseList
        .where((exercise) => containsAllCharacters(exercise, query))
        .toList();
    var filteredProblemExercises = widget.problemExercises
        ?.where((exercise) => containsAllCharacters(exercise, query))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBar(onQueryChanged: (newQuery) {
              setState(() {
                query = newQuery;
              });
            }),
            if (widget.problemExercises != null)
            Column(
              children: [
                Text(widget.problemExercisesTitle ?? ''),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProblemExercises?.length ?? 0,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, filteredProblemExercises?[index]);
                      },
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                "Assets/profile.svg",
                                height: 35,
                                width: 35,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(filteredProblemExercises?[index]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Text('Normal Exercises')
              ],
            ),
        
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: widget.setting == 'choose' ? () {
                    Navigator.pop(context, filteredExercises[index]);
                  } : (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          ExerciseScreen(exercise: filteredExercises[index])
                        )
                      );
                  }
                  ,
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FutureBuilder<bool>(
                          future: fileExists("Assets/Exercises/${filteredExercises[index]}.png"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Loading state
                            } else if (snapshot.hasError) {
                              return const Icon(Icons.error); // Show error icon if something went wrong
                            } else if (snapshot.hasData && snapshot.data!) {
                              return Image.asset(
                                "Assets/Exercises/${filteredExercises[index]}.png",
                                height: 50,
                                width: 50,
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  "Assets/profile.svg",
                                  height: 35,
                                  width: 35,
                                ),
                              );
                            }
                          },
                        ),
                    
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(filteredExercises[index]),
                            Text(getMuscles(filteredExercises[index]))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
