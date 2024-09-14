import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class MainExercisesPage extends StatelessWidget {
  MainExercisesPage({super.key});   
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: myAppBar(context, 'Exercisess'),
        body: FutureBuilder<Map>(
          future: getExercises(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      itemCount: snapshot.data!.keys.length,
                      itemBuilder:  (context, index) {
                        String exercise = snapshot.data!.keys.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              FutureBuilder<bool>(
                                future: fileExists("Assets/Exercises/$exercise.png"),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); // Loading state
                                  } else if (snapshot.hasError) {
                                    return const Icon(Icons.error); // Show error icon if something went wrong
                                  } else if (snapshot.hasData && snapshot.data!) {
                                    return Image.asset(
                                      "Assets/Exercises/$exercise.png",
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(exercise),
                                  Text('${snapshot.data![snapshot.data!.keys.toList()[index]]} times')
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ]
              );
            }
            else{
              return const Center(child: Text('No data'));
            }
          }
        )
      );
    }

  Future<Map> getExercises() async{
    Map exerciseMap = {};
    Map data = await readData();
    for (var day in data.keys){
      for (var exercise in data[day]['sets'].keys){
        exerciseMap[exercise] = (exerciseMap[exercise] ?? 0) + 1;
      }
    }
    debugPrint(exerciseMap.toString());
    return exerciseMap;
  }
}
