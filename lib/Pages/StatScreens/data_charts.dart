import 'package:equatable/equatable.dart';
import 'package:exercise_app/Pages/StatScreens/stacked_area_chart.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'radar_chart.dart';

enum SelectedGraph {
  pieChart('Pie chart'), 
  areaChart('100p area chart'), 
  splineArea('Spline area'),
  splineLine('Spline line'),
  stackedColumn('Stacked column'),
  stackedLine('Stacked line'),
  stepArea('Step area');
  const SelectedGraph(this.label); 

  final String label;
}

class DataCharts extends ConsumerStatefulWidget {
  const DataCharts({super.key});

  @override
  ConsumerState<DataCharts> createState() => _DataChartsState();
}

class _DataChartsState extends ConsumerState<DataCharts> {
  SelectedGraph selectedGraph = SelectedGraph.pieChart;

  void _updateAndReload(VoidCallback fn) => fn();

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(chartViewModelProvider);
    final timeFilter = ref.watch(chartFilterProvider).timeFilter;
    final muscleSelected = ref.watch(chartFilterProvider).muscleSelected;
    final chartTarget = ref.watch(chartFilterProvider).chartTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final SelectedGraph? result = await showModalBottomSheet<SelectedGraph>(
                context: context,
                builder: (_) => const SelectorPopupList(
                  options: SelectedGraph.values,
                ),
              );
              if (result != null) {
                setState(() => selectedGraph = result);
              }
            },
            label: Text(
              selectedGraph.label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            icon: const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white),
            iconAlignment: IconAlignment.end,
          )
        ],
      ),
      body: dataProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selectorBox(
                    muscleSelected.label,
                    MuscleFilter.values,
                    (entry) => _updateAndReload(() => ref.read(chartFilterProvider.notifier).setMuscle(entry)),
                    context,
                  ),
                  selectorBox(
                    timeFilter.label,
                    TimeFilter.values,
                    (entry) => _updateAndReload(() => ref.read(chartFilterProvider.notifier).setTime(entry)),
                    context,
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 270,
                child: selectedGraph == SelectedGraph.pieChart
                  ? PieChart(
                      PieChartData(
                        sections: data.sections,
                        centerSpaceRadius: 10,
                        sectionsSpace: 2,
                        startDegreeOffset: -87,
                      ),
                    )
                  : TimeCharts(
                      selectedGraph: selectedGraph,
                    ),
              ),
              Row(
                children: [
                  _SelectorBox(
                    text: 'Sets',
                    selected: chartTarget == TargetFilter.sets,
                    onTap: () => _updateAndReload(() {
                      ref.read(chartFilterProvider.notifier).setTarget(TargetFilter.sets);
                    }),
                  ),
                  _SelectorBox(
                    text: 'Volume',
                    selected: chartTarget == TargetFilter.volume,
                    onTap: () => _updateAndReload(() {
                      ref.read(chartFilterProvider.notifier).setTarget(TargetFilter.volume);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.grey, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: data.keys!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Container(
                                width: 12.5,
                                height: 12.5,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: getColor(data.keys![index]),
                                  border: Border.all(color: Colors.black),
                                ),
                              ),
                              Text(
                                '${data.keys![index]} : ',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Spacer(),
                              if (data.previousValues != null)
                              Builder(
                                builder: (context) {
                                  final previousValue = data.previousValues?.elementAtOrNull(index);
                                  final difference = calculateDifference(data.unscaledValues[index], previousValue);
                                  Color color =  difference > 0
                                    ? Colors.green
                                    : difference < 0
                                      ? Colors.red
                                      : Colors.grey;
                                  return Row(
                                    children: [
                                      Icon(
                                        difference > 0
                                          ? Icons.arrow_upward
                                          : difference < 0
                                            ? Icons.arrow_downward
                                            : Icons.remove,
                                        color: color
                                      ),
                                      if (difference != 0)
                                      Text(
                                        '${difference.toStringAsFixed(1)}  ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              ),
                              Text(
                                '${data.unscaledValues[index].toStringAsFixed(1)} '
                                '${chartTarget.metric} '
                                ': ${data.scaledValues?[index]}%',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: .25,
                          height: .2,
                          color: Colors.grey.withValues(alpha: .5),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      )
    );
  }
}
final chartViewModelProvider = Provider.autoDispose<AsyncValue<ChartDataViewModel>>((ref) {
  final filters = ref.watch(chartFilterProvider);
  final rawDataAsync = ref.watch(workoutDataProvider);

  return rawDataAsync.whenData((data) {
    final percentageData = getPercentageData(
      data, 
      filters.chartTarget, 
      filters.timeFilter, 
      ref, // Try to remove this dependency if possible
      targetMuscleGroup: filters.muscleSelected
    );

    // final Map<String, double> scaledData = percentageData[0];
    final Map<String, double> unscaledData = percentageData.values.first;
    
    final List<String> keys = unscaledData.keys.toList().reversed.toList();
    // final List<double> scaledValues = scaledData.values.toList().reversed.toList();

    double total = unscaledData.values.fold(0.0, (p, c) => p + c);

    Map<String, double> scaledMuscleData = {};
    for (String key in unscaledData.keys){
      scaledMuscleData[key] = ((unscaledData[key]! / total * 100.0) * 100).roundToDouble() / 100;
    }

    List<PieChartSectionData> sections = scaledMuscleData.entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value,
        title: entry.value > 5 ? '${entry.key}\n${entry.value}%' : '',
        radius: 125,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return ChartDataViewModel(
      sections: sections,
      keys: keys,
      scaledValues: scaledMuscleData.values.toList().reversed.toList(),
      unscaledValues: unscaledData.values.toList().reversed.toList(),
      previousValues: (percentageData.values.elementAtOrNull(1)?.length ?? 0) > 0 ? percentageData.values.elementAtOrNull(1)?.values.toList().reversed.toList() : null
    );
  });
});

class ChartDataViewModel {
  final List<PieChartSectionData> sections;
  final List<String>? keys;
  final List<double>? scaledValues;
  final List<double> unscaledValues;
  final List<double>? previousValues;

  ChartDataViewModel({
    required this.sections,
    required this.unscaledValues, 
    this.keys,
    this.scaledValues,
    this.previousValues,
  });
}

class ChartFilters extends Equatable{
  final TargetFilter chartTarget;
  final TimeFilter timeFilter;
  final MuscleFilter muscleSelected;

  const ChartFilters({
    this.chartTarget = TargetFilter.sets,
    this.timeFilter = TimeFilter.pastYear,
    this.muscleSelected = MuscleFilter.allMuscles, 
  });
  const ChartFilters.weight({
    this.timeFilter = TimeFilter.pastYear,
  }) : chartTarget = TargetFilter.weight,
       muscleSelected = MuscleFilter.allMuscles;

  ChartFilters copyWith({
    TargetFilter? chartTarget,
    MuscleFilter? muscleSelected,
    TimeFilter? timeFilter,
  }) {
    return ChartFilters(
      chartTarget: chartTarget ?? this.chartTarget,
      muscleSelected: muscleSelected ?? this.muscleSelected,
      timeFilter: timeFilter ?? this.timeFilter,
    );
  }

  @override
  List<Object?> get props => [chartTarget, timeFilter, muscleSelected];
}

enum TargetFilter {
  sets('Sets', ''), weight('Weight', 'kg'), volume('Volume', 'kg'), oneRm('1rm', 'kg'), reps('Reps', '');

  const TargetFilter(this.label, this.metric);
  final String label;
  final String metric;
}

enum TimeFilter {
  pastWeek(range: 7, label: 'Past week'),
  pastMonth(range: 30, label: 'Past month'),
  past8Weeks(range: 56, label: 'Past 8 weeks'),
  past3Months(range: 90, label: 'Past 3 months'),
  past6Months(range: 180, label: 'Past 6 months'),
  pastYear(range: 365, label: 'Past year'),
  allTime(range: -1, label: 'All time');

  const TimeFilter({required this.range, required this.label});
  final int range;
  final String label;
}

enum MuscleFilter {
  chest(label: 'Chest'),
  back(label: 'Back'),
  legs(label: 'Legs'),
  core(label: 'Core'),
  shoulders(label: 'Shoulders'),
  allMuscles(label: 'All muscles');

  const MuscleFilter({required this.label});
  final String label;
}

class ChartFiltersNotifier extends Notifier<ChartFilters> {
  final ChartFilters? initialFilters;
  
  ChartFiltersNotifier({this.initialFilters});
  
  @override
  ChartFilters build() {
    return initialFilters ?? ChartFilters();
  }

  void setTarget(TargetFilter target) {
    state = state.copyWith(chartTarget: target);
  }

  void setTime(TimeFilter timeFilter) {
    state = state.copyWith(timeFilter: timeFilter);
  }

  void setMuscle(MuscleFilter muscle) {
    state = state.copyWith(muscleSelected: muscle);
  }
}


final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});

class _SelectorBox extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SelectorBox({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.blue : HexColor.fromHex('151515'),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(text),
        ),
      ),
    );
  }
}
