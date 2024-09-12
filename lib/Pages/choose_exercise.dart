import 'dart:convert';
import 'package:exercise_app/exercises.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  @override
  void initState() {
    super.initState();
    getExercisesese();
  }
  getExercisesese() async{
    var data = await getExercises();
    debugPrint(data.toString());
  }



  String query = '';

  @override
  Widget build(BuildContext context) {

    var filteredExercises = exercises
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
                  onTap: () {
                    Navigator.pop(context, filteredExercises[index]);
                  },
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FutureBuilder(
  future: fileExists("Assets/Exercises/${filteredExercises[index]}.png"),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data ?? false) { // Add null check here
        return Image.asset(
          "Assets/Exercises/${filteredExercises[index]}.png",
          height: 50,
          width: 50,
        );
      } else {
        return SvgPicture.asset(
          "Assets/profile.svg",
          height: 50,
          width: 50,
        );
      }
    } else {
      return CircularProgressIndicator(); // or some other loading indicator
    }
  },
)
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

Future<List<String>> getExercises() async {
  final exercises = <String>[];

  // Assuming your images are in the Assets/images directory
  final manifestContent = await rootBundle.loadString('AssetManifest.json');

  final manifestMap = json.decode(manifestContent);

  for (var key in manifestMap.keys) {
    if (key.startsWith('Assets/images/')) {
      exercises.add(key.split('/').last);
    }
  }

  return exercises;
}
Future<bool> fileExists(String filePath) async {
  debugPrint(filePath);
  try {
    await rootBundle.load(filePath);
    debugPrint('yeah');
    return true;
  } catch (e) {
    debugPrint('nuhhuh');
    return false;
  }
}