import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparePage extends ConsumerStatefulWidget {
  final String friendId;
  const ComparePage({super.key, required this.friendId});
  @override
  ComparePageState createState() => ComparePageState();
}

class ComparePageState extends ConsumerState<ComparePage> {
  @override
  Widget build(BuildContext context) {
    final comparisonData = ref.watch(comparisonProvider(widget.friendId));
    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: Column(
        children: [
           selectorBox(
            ref.watch(radarChartFilterProvider).timeFilter.label, 
            TimeFilter.values, 
            (entry) => ref.read(radarChartFilterProvider.notifier).setTime(entry), 
            context
          ),
          Center(
            child: radarChartWidget(
              [[RadarEntry(value: 0.5), RadarEntry(value: 0.8), RadarEntry(value: 0.3), RadarEntry(value: 0.3), RadarEntry(value: 0.3), RadarEntry(value: 0.3)]],
              size: 250
            ),
          ),
        ],
      ), // Placeholder data
    );
  }

}