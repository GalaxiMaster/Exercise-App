import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/exercises.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {

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
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          ExerciseScreen(exercise: filteredExercises[index])
                        )
                      );
                  },
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SvgPicture.asset(
                            "Assets/Exercises/${filteredExercises[index]}.png",
                            height: 50,
                            width: 50,
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
  String muscle = exerciseMuscles[exercise]!['Primary']!.keys.toList()[0];
  return muscle != 'null' ? muscle : 'No muscle';
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