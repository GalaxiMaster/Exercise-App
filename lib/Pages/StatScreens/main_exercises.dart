import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class MainExercisesPage extends StatefulWidget {
  const MainExercisesPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MainExercisesPageState createState() => _MainExercisesPageState();
}

class _MainExercisesPageState extends State<MainExercisesPage> {
  bool multiSelect = false;
  List selectedItems = [];
  late Map exerciseData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  setExerciseData(); // Load data once
}

void setExerciseData() async {
  final data = await getExercises();
  setState(() {
    exerciseData = data; // Store the fetched data
    isLoading = false;   // Mark loading as complete
  });
}
  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: myAppBar(context, 'Exercisess'),
        body: isLoading
        ? const Center(child: CircularProgressIndicator()) // Show loading spinner
        : Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: exerciseData.keys.length,
                    itemBuilder:  (context, index) {
                      String exercise = exerciseData.keys.toList()[index];
                      return InkWell(
                        onTap: () {
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseScreen(exercises: [exercise])
                                )
                            );
                          }
                        },
                        onLongPress: (){
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
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              if (selectedItems.contains(exercise))
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
                                  Text('${exerciseData[exerciseData.keys.toList()[index]]} times')
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]
            ),
            if (multiSelect)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: GestureDetector(
                  onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseScreen(exercises: selectedItems)
                          )
                      );
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
  Future<Map> getExercises() async{
    Map exerciseMap = {};
    Map data = await readData();
    for (var day in data.keys){
      for (var exercise in data[day]['sets'].keys){
        exerciseMap[exercise] = (exerciseMap[exercise] ?? 0) + 1;
      }
    }
    List<MapEntry> entries = exerciseMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    exerciseMap = Map.fromEntries(entries);
    return exerciseMap;
  }
}
