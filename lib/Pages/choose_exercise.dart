import 'dart:convert';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutList extends StatefulWidget {
  final String setting;
  const WorkoutList({super.key, required this.setting});

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
    var filteredExercises = exerciseList
        .where((exercise) => containsAllCharacters(exercise, query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
      ),
      body: Column(
        children: [
          SearchBar(onQueryChanged: (newQuery) {
            setState(() {
              query = newQuery;
            });
          }),
          Expanded(
            child: ListView.builder(
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
  int queryIndex = 0;
  if (query.isEmpty){
    return true;
  }
  for (int i = 0; i < exercise.length; i++) {
    if (exercise[i].toLowerCase() == query[queryIndex].toLowerCase()) {
      queryIndex++;
    }
    if (queryIndex == query.length) {
      return true;
    }
  }
  return false;
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
