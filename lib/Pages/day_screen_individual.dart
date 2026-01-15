import 'dart:convert';

import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class IndividualDayScreen extends ConsumerStatefulWidget {
  final Map dayData;
  final String dayKey;
  const IndividualDayScreen({super.key, required this.dayData, required this.dayKey});
  @override
  // ignore: library_private_types_in_public_api
  _IndividualDayScreenState createState() => _IndividualDayScreenState();
}

class _IndividualDayScreenState extends ConsumerState<IndividualDayScreen> {
  final Map<String, bool> _imageExistsCache = {};
  Map dayData = {};

    // Cache the file existence check
  Future<bool> _checkFileExists(String filePath) async {
    if (_imageExistsCache.containsKey(filePath)) {
      return _imageExistsCache[filePath]!;
    }
    
    final exists = await fileExists(filePath);
    _imageExistsCache[filePath] = exists;
    return exists;
  }
  @override
  build(BuildContext context) {
    dayData = widget.dayData;
    String dateStr = dayData['stats']['startTime'];
    String endTimeStr = dayData['stats']['endTime'];
    Duration length = DateTime.parse(endTimeStr).difference(DateTime.parse(dateStr));
    double volume = 0;
    int sets = 0;
    int prs = 0;
    int exercises = 0;
    for (String exercise in dayData['sets'].keys){
      exercises++;
      for (Map set in dayData['sets'][exercise]){
        sets++;
        volume += double.parse(set['weight'].toString()).abs() * double.parse(set['reps'].toString()).abs();
        if (set['PR'] == 'yes') prs++;
      }
    }
    return Scaffold(
      appBar: myAppBar(context, 'Workout Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                DateFormat('EEEE dd MMM yyyy').format(DateTime.parse(dateStr)),
                style: const TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              child: Row(
                children: [
                  Text(
                    DateFormat('h:mm a').format(DateTime.parse(dateStr)),
                    style: const TextStyle(fontSize: 17),
                  ),
                  const Text('  -  '),
                  Text(
                    DateFormat('h:mm a').format(DateTime.parse(endTimeStr)),
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  infoBox('Time', '${length.inHours}h ${length.inMinutes % 60}m'),
                  infoBox('Volume', '${volume.toStringAsFixed(2)}kg'),
                  infoBox("PR's", '$prs'),
                  infoBox('Sets', '$sets'),
                  infoBox('Exercises', '$exercises'),
                ],
              ),
            ),
            const Divider(height: .1, thickness: 0.5, color: Colors.grey,),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Muslce split',
                    style: TextStyle(fontSize: 20,),
                  ),
                  Row(
                    children: [
                      Text(
                        'Pie chart',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  )
                ],
              ),
            ),
            FutureBuilder(
              future: getPercentages(dayData),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                } else if (snapshot.hasData) {
                  return muscleSplit_stackedBars(snapshot.data!, context);
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
            const Divider(height: .1, thickness: 0.5, color: Colors.grey,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workout',
                    style: TextStyle(fontSize: 20,),
                  ),
                  GestureDetector(
                    onTap: () async{
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => Addworkout(sets: jsonDecode(jsonEncode(dayData)), editing: true),
                        ),
                      );
                      if (result != null){
                        dayData['sets'] = result;

                        ref.read(workoutDataProvider.notifier).updateValue(widget.dayKey, dayData);
                        // setState(() {});
                      }
                    },
                    child: const Text(
                      'Edit workout',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: dayData['sets'].keys.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                String exerciseName = dayData['sets'].keys.toList()[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            FutureBuilder<bool>(
                              future: _checkFileExists("assets/Exercises/$exerciseName.png"),
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
                                      "assets/Exercises/$exerciseName.png",
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(exerciseName, style: const TextStyle(fontSize: 18),),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: dayData['sets'][exerciseName].length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          Map set = dayData['sets'][exerciseName][index];
                          return Container(
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? ThemeColors.bg : ThemeColors.accent
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Text(set['type'].toLowerCase() == 'normal' ? (index + 1).toString() : set['type'][0], style: const TextStyle(fontSize: 24),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25),
                                    child: Text((exerciseMuscles[exerciseName]?['type'] ?? 'Weighted') != 'Bodyweight' ? '${set['weight']} x ${set['reps']}' : 'x${set['reps']}', style: const TextStyle(fontSize: 20),),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      )
                    ],
                  ),
                );
              }
            )
          ],
        ),
      )
    );
  }
  // ignore: non_constant_identifier_names
  Padding muscleSplit_stackedBars(List dayData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dayData.map((data) {
          debugPrint(data.toString());
          data =  data.entries.first;
          return data.value != 0 ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Muscle Label (placed above the bar)
                Text(
                  data.key,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4), // Space between label and bar
                // Full-width container to allow text positioning
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: FractionallySizedBox(
                          widthFactor: data.value / 100,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Percentage Text positioned just outside the bar
                      Positioned(
                        left: (data.value / 100) * MediaQuery.of(context).size.width - 0.7*data.value, // Add small offset
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "${data.value}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ) : Container();
        }).toList(),
      ),
    );
  }

  Column infoBox(String header, String content) {
    return Column(
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          content,
          style: const TextStyle(fontSize: 22),
        )
      ],
    );
  }
  
  Future<List<dynamic>> getPercentages(Map dayData) async{
    Map percentages = {};
    Map musclegroups = {};
    final Map customExercisesData = await ref.read(customExercisesProvider.future);
    for (String exercise in dayData['sets'].keys){
      bool isCustom = customExercisesData.containsKey(exercise);
      Map exerciseData = {};

      if (isCustom && customExercisesData.containsKey(exercise)){
        exerciseData = customExercisesData[exercise];
      } else {
        exerciseData = exerciseMuscles[exercise] ?? {};
      }

      if (exerciseData.isEmpty) continue;

      for (var muscle in (exerciseData['Primary']?.keys ?? [])){
        musclegroups[muscle] = ((musclegroups[muscle] ?? 0) + exerciseData['Primary']![muscle]!/100*dayData['sets'][exercise].length);
      }
      for (var muscle in (exerciseData['Secondary']?.keys ?? [])){
        musclegroups[muscle] = ((musclegroups[muscle] ?? 0) + exerciseData['Secondary']![muscle]!/100*dayData['sets'][exercise].length);
      }
    }
    for (String group in muscleGroups.keys){
      for (int i = 0;i < (muscleGroups[group]?.length ?? 0); i++) {
        double muscleNum = (musclegroups[muscleGroups[group]?[i]] ?? 0).toDouble();
          if (percentages[group] == null) {
            percentages[group] = 0;
          }
          percentages[group] += muscleNum;
      }
    }
    double currentSum = percentages.values.reduce((a, b) => a + b);
    double scalingFactor = 100 / currentSum;
    percentages.updateAll((key, value) => value * scalingFactor);
    percentages = sortMapByValue(percentages, descending: true);
    return percentages.entries
      .map((entry) => {entry.key: double.parse(entry.value.toStringAsFixed(2))})
      .toList();
  }

}
Map sortMapByValue<K, V extends Comparable>(Map map, {bool descending = false}) {
  var entries = map.entries.toList()
    ..sort((a, b) => descending 
      ? b.value.compareTo(a.value) 
      : a.value.compareTo(b.value));
  
  return Map.fromEntries(entries);
}