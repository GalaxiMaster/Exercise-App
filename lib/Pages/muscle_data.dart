import 'package:exercise_app/Pages/data_charts.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/file_handling.dart';

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
              case 'Volume': selector = double.parse(set['weight'])*double.parse(set['reps']);
              case 'Sets' : selector = 1;
            }
            for (var muscle in exerciseMuscles[exercise]!['Primary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Primary']![muscle]/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Primary']![muscle]/100);
              }
            }
            for (var muscle in exerciseMuscles[exercise]!['Secondary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseMuscles[exercise]!['Secondary']![muscle]/100);
              } else{
                muscleData[muscle] = selector*(exerciseMuscles[exercise]!['Secondary']![muscle]/100);
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
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: FutureBuilder<List>(
        future: getStuff('Sets'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            final Map<String, double> scaledMuscleData = Map<String, double>.from(snapshot.data![0]);
            final Map<String, double> unscaledMuscleData = Map<String, double>.from(snapshot.data![1]);

            List<PieChartSectionData> sections = scaledMuscleData.entries.map((entry) {
              return PieChartSectionData(
                color: getColor(entry.key),
                value: entry.value,
                title: entry.value > 5 ? '${entry.key}\n${entry.value}%' : '',
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
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Advanced stats',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  box('', 'Label', 'This could be a description of the unscaled data'),
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

  Color getColor(String key) {
    var colors = {
      'Pectorals': Colors.red,
      'Triceps': Colors.orange,
      'Biceps': Colors.pink,
      'Deltoids': Colors.blue,
      'Front Delts': Colors.lightBlue,
      'Side Delts': Colors.cyan,
      'Rear Delts': Colors.teal,
      'Forearms': Colors.purple,
      'Lats': Colors.indigo,
      'Rhomboids': Colors.green,
      'Lower Back': Colors.brown,
      'Glutes': Colors.deepOrange,
      'Quads': Colors.yellow,
      'Hamstrings': Colors.amber,
      'Calves': Colors.lightGreen,
      'Abs': Colors.lightBlueAccent,
      'Obliques': Colors.blueGrey,
    };

    return colors[key] ?? Colors.grey;
  }

  Widget box(String icon, String label, String description) {
    return Container(
      width: double.infinity,
      height: 75,
      decoration: const BoxDecoration(color: Colors.grey),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.pie_chart),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}







 // SizedBox(
                  //   height: 352,
                  //   child: RadarChart(
                  //     RadarChartData(
                  //       dataSets: [
                  //         RadarDataSet(
                  //           fillColor: Colors.blue.withOpacity(0.5),
                  //           borderColor: Colors.blue,
                  //           entryRadius: 3,
                  //           dataEntries: [
                  //             RadarEntry(value: (snapshot.data?['Lats'] ?? 0) + (snapshot.data?['Erector Spinae'] ?? 0) + (snapshot.data?['Rhomboids'] ?? 0) + (snapshot.data?['Lower Back'] ?? 0).roundToDouble()), // Back
                  //             RadarEntry(value: (snapshot.data?['Pectorals'] ?? 0) + (snapshot.data?['Pectorals (Upper)'] ?? 0) + (snapshot.data?['Pectorals (Lower)'] ?? 0).roundToDouble()), // Chest
                  //             RadarEntry(value: (snapshot.data?['Front Delts'] ?? 0) + (snapshot.data?['Side Delts'] ?? 0) + (snapshot.data?['Posterior Delts'] ?? 0) + (snapshot.data?['Trapezius'] ?? 0).roundToDouble()), // Shoulders
                  //             RadarEntry(value: (snapshot.data?['Biceps'] ?? 0) + (snapshot.data?['Triceps'] ?? 0) + (snapshot.data?['Forearms'] ?? 0) + (snapshot.data?['Brachialis'] ?? 0).roundToDouble()), // Arms
                  //             RadarEntry(value: (snapshot.data?['Quadriceps'] ?? 0) + (snapshot.data?['Hamstrings'] ?? 0) + (snapshot.data?['Glutes'] ?? 0) + (snapshot.data?['Calves'] ?? 0).roundToDouble()), // Legs
                  //             RadarEntry(value: (snapshot.data?['Rectus Abdominis'] ?? 0) + (snapshot.data?['Obliques'] ?? 0) + (snapshot.data?['Core'] ?? 0) + (snapshot.data?['Hip Flexors'] ?? 0).roundToDouble()), // Core
                  //           ]
                  //         ),
                  //       ],
                  //       radarBackgroundColor: Colors.transparent,
                  //       radarBorderData: const BorderSide(color: Colors.transparent),
                  //       titlePositionPercentageOffset: 0,
                  //       titleTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  //       gridBorderData: const BorderSide(color: Colors.grey),
                  //       tickBorderData: const BorderSide(color: Colors.transparent),
                  //       ticksTextStyle: const TextStyle(color: Colors.transparent),
                  //       tickCount: 200,
              
                  //       radarShape: RadarShape.polygon,
                  //       getTitle: (index, angle) {
                  //         switch (index) {
                  //           case 0:
                  //             return const RadarChartTitle(text: 'Back');
                  //           case 1:
                  //             return const RadarChartTitle(text: 'Chest');
                  //           case 2:
                  //             return const RadarChartTitle(text: 'Shoulders');
                  //           case 3:
                  //             return const RadarChartTitle(text: 'Arms');
                  //           case 4:
                  //             return const RadarChartTitle(text: 'Legs');
                  //           case 5:
                  //             return const RadarChartTitle(text: 'Core');
                  //           default:
                  //             return const RadarChartTitle(text: '');
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // )