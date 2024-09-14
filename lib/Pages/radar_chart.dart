import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RadarChartPage extends StatelessWidget {
  Map sets;
  RadarChartPage({super.key, required this.sets});   
    @override
    Widget build(BuildContext context) {
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
                            dataEntries: [
                              RadarEntry(value: (sets['Lats'] ?? 0) + (sets['Erector Spinae'] ?? 0) + (sets['Rhomboids'] ?? 0) + (sets['Lower Back'] ?? 0).roundToDouble()), // Back
                              RadarEntry(value: (sets['Pectorals'] ?? 0) + (sets['Pectorals (Upper)'] ?? 0) + (sets['Pectorals (Lower)'] ?? 0).roundToDouble()), // Chest
                              RadarEntry(value: (sets['Front Delts'] ?? 0) + (sets['Side Delts'] ?? 0) + (sets['Posterior Delts'] ?? 0) + (sets['Trapezius'] ?? 0).roundToDouble()), // Shoulders
                              RadarEntry(value: (sets['Biceps'] ?? 0) + (sets['Triceps'] ?? 0) + (sets['Forearms'] ?? 0) + (sets['Brachialis'] ?? 0).roundToDouble()), // Arms
                              RadarEntry(value: (sets['Quadriceps'] ?? 0) + (sets['Hamstrings'] ?? 0) + (sets['Glutes'] ?? 0) + (sets['Calves'] ?? 0).roundToDouble()), // Legs
                              RadarEntry(value: (sets['Rectus Abdominis'] ?? 0) + (sets['Obliques'] ?? 0) + (sets['Core'] ?? 0) + (sets['Hip Flexors'] ?? 0).roundToDouble()), // Core
                            ]
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