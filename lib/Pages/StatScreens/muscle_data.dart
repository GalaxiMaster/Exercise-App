import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/exercise_goals.dart';
import 'package:exercise_app/Pages/StatScreens/main_exercises.dart';
import 'package:exercise_app/Pages/StatScreens/muscle_tracking.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Pages/StatScreens/strength_gradient.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:flutter_svg/svg.dart';

class MuscleData extends StatelessWidget {
  const MuscleData({super.key});

  Future<List> getStuff(String target) async {
    Map muscleData = {};
    Map data = await readData();
    for (var day in data.keys){
      for (var exercise in data[day]['sets'].keys){
        if (exerciseMuscles.containsKey(exercise)){
          for (var set in data[day]['sets'][exercise]){
            double selector = 0;
            switch(target){
              case 'Volume': selector = double.parse(set['weight'].toString()).abs()*double.parse(set['reps'].toString()).abs();
              case 'Sets' : selector = 1;
            }
            for (var muscle in exerciseMuscles[exercise]!['Primary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Primary']![muscle]!/100);
              }
            }
            for (var muscle in exerciseMuscles[exercise]!['Secondary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Secondary']![muscle]!/100);
              }
            }
          }
        } else{
          debugPrint('Unknown exercise: $exercise');
        }
      }
    }
    debugPrint(muscleData.toString());
    // Scale results to 100
    double total = muscleData.values.fold(0.0, (p, c) => p + c);
    debugPrint(total.toString());
    Map scaledMuscleData = {};
    for (String muscle in muscleData.keys){
      scaledMuscleData[muscle] = ((muscleData[muscle] / total * 100.0) * 100).roundToDouble() / 100;
    }
    List<MapEntry> entries = muscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    muscleData = Map.fromEntries(entries);
    debugPrint(muscleData.toString());
    entries = scaledMuscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    scaledMuscleData = Map.fromEntries(entries);
    debugPrint(scaledMuscleData.toString());
    return [scaledMuscleData, muscleData].toList();
  }

  @override
  Widget build(BuildContext context) {
    double radius = 125;

    return Scaffold(
      appBar: myAppBar(context, 'Muscle data'),
      body: FutureBuilder<List>(
        future: getStuff('Sets'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final Map<String, double> scaledMuscleData = Map<String, double>.from(snapshot.data![0]);
            final Map<String, double> unscaledMuscleData = Map<String, double>.from(snapshot.data![1]);

            List<PieChartSectionData> sections = scaledMuscleData.entries.map((entry) {
              return PieChartSectionData(
                color: getColor(entry.key),
                value: entry.value,
                title: entry.value > 7.5 ? '${entry.key}\n${entry.value}%' : '',
                radius: radius,
                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList();

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 270,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DataCharts(scaledData: scaledMuscleData, unscaledData: unscaledMuscleData),
                          ),
                        );
                      },
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 10,
                          sectionsSpace: 2,
                          startDegreeOffset: -87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Fancy stats',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  box('radar-chart', 'Radar chart', 'Look at your data in a radar chart', context, RadarChartPage(sets: unscaledMuscleData)),
                  box('dumbbell', 'Main exercises', 'See what exercises you do the most', context, const MainExercisesPage()),
                  box('flexing', 'Muscle tracking', "See how many sets you've done for each muscle group", context, MuscleTracking(setData: unscaledMuscleData,)),
                  box('trophy', 'Exercise goals', "Set goals per exercise per week", context, const ExerciseGoals()),
                  box('chart', 'Strength Gradient', "See your strength over a period", context, const StrengthGradiant()),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget box(String iconPath, String label, String description, var context, var path) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => path)
        );      
      },
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  'assets/$iconPath.svg',
                  height: 30,
                  width: 30,
                  colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                ),     
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        description,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
                            const Divider(
          thickness: 1,
          color: Colors.grey,
          height: 1,
        ),
        ],
      ),
    );
  }
}


