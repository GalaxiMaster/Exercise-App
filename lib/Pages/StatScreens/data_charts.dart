import 'package:exercise_app/Pages/StatScreens/stacked_area_chart.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'radar_chart.dart';

class DataCharts extends ConsumerStatefulWidget {
  const DataCharts({super.key});

  @override
  ConsumerState<DataCharts> createState() => _DataChartsState();
}

class _DataChartsState extends ConsumerState<DataCharts> {
  String selectedGraph = 'Pie Chart';

  @override
  void initState() {
    super.initState();
  }

  void _updateAndReload(VoidCallback fn) => fn();

  @override
  Widget build(BuildContext context) {
    final dataProvider = ref.watch(chartViewModelProvider);
    final timeLabel = ref.watch(chartFilterProvider).timeLabel;
    final range = ref.watch(chartFilterProvider).range;
    final muscleSelected = ref.watch(chartFilterProvider).muscleSelected;
    final chartTarget = ref.watch(chartFilterProvider).chartTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => const SelectorPopupList(
                  options: [
                    'Pie Chart',
                    '100p Area Chart',
                    'Spline Area',
                    'Spline Line',
                    'Stacked Column',
                    'Stacked Line',
                    'Step Area',
                  ],
                ),
              );
              if (result != null) {
                setState(() => selectedGraph = result);
              }
            },
            label: Text(
              selectedGraph,
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
                    muscleSelected,
                    'muscles',
                    (entry) => _updateAndReload(() => ref.read(chartFilterProvider.notifier).setMuscle(entry.key)),
                    context,
                  ),
                  selectorBox(
                    timeLabel,
                    'time',
                    (entry) => _updateAndReload(() => ref.read(chartFilterProvider.notifier).setRange(entry.value, entry.key)),
                    context,
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 270,
                child: selectedGraph == 'Pie Chart'
                  ? PieChart(
                      PieChartData(
                        sections: data.sections,
                        centerSpaceRadius: 10,
                        sectionsSpace: 2,
                        startDegreeOffset: -87,
                      ),
                    )
                  : TimeCharts(
                      range: range,
                      musclesSelected: muscleSelected,
                      target: chartTarget,
                      selectedGraph: selectedGraph,
                    ),
              ),
              Row(
                children: [
                  _SelectorBox(
                    text: 'Sets',
                    selected: chartTarget == 'Sets',
                    onTap: () => _updateAndReload(() {
                      ref.read(chartFilterProvider.notifier).setTarget('Sets');
                    }),
                  ),
                  _SelectorBox(
                    text: 'Volume',
                    selected: chartTarget == 'Volume',
                    onTap: () => _updateAndReload(() {
                      ref.read(chartFilterProvider.notifier).setTarget('Volume');
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
                              Text(
                                '${data.unscaledValues[index].toStringAsFixed(1)} '
                                '${chartTarget == 'Volume' ? 'kg' : chartTarget} '
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
      filters.range, 
      ref, // Try to remove this dependency if possible
      targetMuscleGroup: filters.muscleSelected
    );

    // final Map<String, double> scaledData = percentageData[0];
    final Map<String, double> unscaledData = percentageData.current;
    
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
    );
  });
});
class ChartDataViewModel {
  final List<PieChartSectionData> sections;
  final List<String>? keys;
  final List<double>? scaledValues;
  final List<double> unscaledValues;

  ChartDataViewModel({
    required this.sections,
    this.keys,
    this.scaledValues,
    required this.unscaledValues,
  });
}

class ChartFilters {
  final String chartTarget;
  final int range;
  final String muscleSelected;
  final String timeLabel;

  ChartFilters({
    this.chartTarget = 'Sets',
    this.range = -1,
    this.muscleSelected = 'All Muscles', 
    this.timeLabel = 'All Time',
  });
  ChartFilters.weight({
    this.range = -1,
    this.timeLabel = 'All Time',
  }) : chartTarget = 'weight',
       muscleSelected = '';

  ChartFilters copyWith({
    String? chartTarget,
    int? range,
    String? muscleSelected,
    String? timeLabel,
  }) {
    return ChartFilters(
      chartTarget: chartTarget ?? this.chartTarget,
      range: range ?? this.range,
      muscleSelected: muscleSelected ?? this.muscleSelected,
      timeLabel: timeLabel ?? this.timeLabel,
    );
  }
}

class ChartFiltersNotifier extends Notifier<ChartFilters> {
  final ChartFilters? initialFilters;
  
  ChartFiltersNotifier({this.initialFilters});
  
  @override
  ChartFilters build() {
    return initialFilters ?? ChartFilters();
  }

  void setTarget(String target) {
    state = state.copyWith(chartTarget: target);
  }

  void setRange(int range, String timeLabel) {
    state = state.copyWith(range: range, timeLabel: timeLabel);
  }

  void setMuscle(String muscle) {
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
            color: selected ? Colors.blue : HexColor.fromHexColor('151515'),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(text),
        ),
      ),
    );
  }
}
