import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/widgets.dart';
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
    final filters = ref.watch(compareChartFilterProvider);
    final mine = ref.watch(radarModelProvider(
    RadarParams(userId: '', filters: filters)));
    final theirs = ref.watch(radarModelProvider(
        RadarParams(userId: widget.friendId, filters: filters)));

    // final comparisonData = ref.watch(comparisonProvider(widget.friendId));

    return Scaffold(
      appBar: AppBar(title: const Text('Compare')),
      body: Column(
        children: [
           selectorBox(
            ref.watch(compareChartFilterProvider).timeFilter.label, 
            TimeFilter.values,
            (entry) => ref.read(compareChartFilterProvider.notifier).setTime(entry), 
            context
          ),
          Center(
            child: switch ((mine, theirs)) { // a very interesting way to do it
              (AsyncData(value: final a), AsyncData(value: final b)) =>
                  radarChartWidget([a.first, b.first]),
              (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
                  Text(error.toString()),
              _ => const CircularProgressIndicator(),
            }
          ),
        ],
      ), // Placeholder data
    );
  }

}


final compareChartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});