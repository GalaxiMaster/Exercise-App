import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/exercise_screen.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
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
  Map<String, bool> assetExists = {}; // cache for asset existence


  String timeSelected = 'All Time';
  int range = -1;
  String muscleSelected = 'All Muscles';

  @override
  void initState() {
    super.initState();
    setExerciseData(); // Load data once
  }

void setExerciseData() async {
  final data = await getExercises(range, muscleSelected);
  // Build a cache of which exercises have local png assets to avoid per-row async checks
  final exercises = data.keys.toList();
  final futures = exercises.map((e) => fileExists("assets/Exercises/$e.png")).toList();
  final results = await Future.wait(futures);
  for (int i = 0; i < exercises.length; i++) {
    assetExists[exercises[i]] = results[i];
    if (results[i] && mounted) {
      precacheImage(AssetImage("assets/Exercises/${exercises[i]}.png"), context);
    }
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selectorBox(
                    muscleSelected, 
                    'muscles', 
                    (entry) {
                      setState(() {
                        muscleSelected = entry.key;
                      });
                      setExerciseData();
                    }, 
                    context
                  ),
                  selectorBox(
                    timeSelected, 
                    'time', 
                    (entry) {
                      setState(() {
                        timeSelected = entry.key;
                        range = entry.value;
                        setExerciseData();
                      });
                    }, 
                  context
                  ),
                ],
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: exerciseData.keys.length,
                  reverse: true,
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
                            // Use cached existence map (populated in setExerciseData) to avoid per-row async work
                            assetExists[exercise] == true
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
  Future<Map> getExercises(int range, String muscleGroup) async {
    Map exerciseMap = {};
    Map data = await readData();
    for (var day in data.keys){
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
      int diff = difference.inDays;
      if (diff <= range || range == -1){
        for (var exercise in data[day]['sets'].keys){
          for (String muscle in (muscleGroups[muscleGroup] ?? ['muscle'])){
            if ((exerciseMuscles[exercise]?['Primary'].containsKey(muscle) ?? false) || muscleGroup == 'All Muscles'){ //  || (exerciseMuscles[exercise]?['Secondary'].containsKey(muscle) ?? false)
              // for (Map set in data[day]['sets'][exercise]){
              List sets = data[day]['sets'][exercise];
              String target = 'weight';
              (exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'Weighted' ? target = 'reps' : null;
              sets.sort((a, b) => double.parse(a[target].toString()).compareTo(double.parse(b[target].toString())));
            // }
              exerciseMap[exercise] = (exerciseMap[exercise] ?? 0) + 1;
              break;
            }
          }
        }
      }
    }
    List<MapEntry> entries = exerciseMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    exerciseMap = Map.fromEntries(entries);
    return exerciseMap;
  }
}
