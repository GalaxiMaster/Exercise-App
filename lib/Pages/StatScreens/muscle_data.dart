import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/exercise_goals.dart';
import 'package:exercise_app/Pages/StatScreens/main_exercises.dart';
import 'package:exercise_app/Pages/StatScreens/muscle_tracking.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Pages/StatScreens/strength_gradient.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
class MuscleData extends ConsumerWidget {
  const MuscleData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final dataProvider = ref.watch(chartDataProvider);
    return Scaffold(
      appBar: myAppBar(context, 'Muscle data'),
      body: dataProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {

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
                          builder: (context) => DataCharts(),
                        ),
                      );
                    },
                    child: PieChart(
                      PieChartData(
                        sections: data.sections,
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
                box('radar-chart', 'Radar chart', 'Look at your data in a radar chart', context, RadarChartPage()),
                box('dumbbell', 'Main exercises', 'See what exercises you do the most', context, const MainExercisesPage()),
                box('flexing', 'Muscle tracking', "See how many sets you've done for each muscle group", context, MuscleTracking()),
                box('trophy', 'Exercise goals', "Set goals per exercise per week", context, const ExerciseGoals()),
                box('chart', 'Strength Gradient', "See your strength over a period", context, const StrengthGradiant()),
              ],
            ),
          );
        }
      )
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


final chartDataProvider = Provider<AsyncValue<ChartDataViewModel>>((ref) {
  final workoutAsyncValue = ref.watch(workoutDataProvider);

  return workoutAsyncValue.whenData((data){
      final Map<String, double> percentageData = getPercentageData(data, 'Sets', 30, ref);
      // final Map<String, double> scaledMuscleData = Map<String, double>.from(percentageData[0]);
      double total = percentageData.values.fold(0.0, (p, c) => p + c);

      Map<String, double> scaledMuscleData = {};
      for (String key in percentageData.keys){
        scaledMuscleData[key] = ((percentageData[key]! / total * 100.0) * 100).roundToDouble() / 100;
      }

      List<PieChartSectionData> sections = scaledMuscleData.entries.map((entry) {
        return PieChartSectionData(
          color: getColor(entry.key),
          value: entry.value,
          title: entry.value > 7.5 ? '${entry.key}\n${entry.value}%' : '',
          radius: 125,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();
      return ChartDataViewModel(
        sections: sections,
        unscaledValues: percentageData.values.toList().reversed.toList(),
      );
    },
  );
});