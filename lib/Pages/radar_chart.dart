import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RadarChartPage extends StatelessWidget {
  Map sets;
  RadarChartPage({super.key, required this.sets});   
    @override
    Widget build(BuildContext context) {
      // gather data dynamically
      List<RadarEntry> data = [];
      for (String group in muscleGroups.keys){
        double total = 0;
        for (int i = 0;i < (muscleGroups[group]?.length ?? 0); i++) {
          double muscleNum = (sets[muscleGroups[group]?[i]] ?? 0);
            total += muscleNum;
        }
        data.add(RadarEntry(value: total));
      }
      return Scaffold(
        appBar: myAppBar(context, 'Radar Chart'),
        body: Column(
          children: [
            SizedBox(
              height: 352,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderWidth: 2,
                      entryRadius: 3,
                      dataEntries: data
                    ),
                  ],
                  // radarBackgroundColor: Colors.transparent,
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.1,
                  gridBorderData: const BorderSide(color: Colors.grey),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  tickCount: 200,

                  radarShape: RadarShape.polygon,
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0:
                        return const RadarChartTitle(text: 'Back');
                      case 1:
                        return const RadarChartTitle(text: 'Chest');
                      case 2:
                        return const RadarChartTitle(text: 'Shoulders');
                      case 3:
                        return const RadarChartTitle(text: 'Arms');
                      case 4:
                        return const RadarChartTitle(text: 'Legs');
                      case 5:
                        return const RadarChartTitle(text: 'Core');
                      default:
                        return const RadarChartTitle(text: '');
                    }
                  },
                ),
              ),
            )
          ],
        ),
      );
    }
}