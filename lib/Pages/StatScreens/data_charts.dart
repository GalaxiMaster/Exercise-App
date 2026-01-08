import 'package:exercise_app/Pages/StatScreens/stacked_area_chart.dart';
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
  String chartTarget = 'Sets';
  double radius = 125;
  String muscleSelected = 'All Muscles';
  String timeSelected = 'All Time';
  int range = -1;
  String selectedGraph = 'Pie Chart';

  late Future<List<Map>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = getPercentageData(
      chartTarget,
      range,
      ref,
      targetMuscleGroup: muscleSelected,
    );
  }

  void _updateAndReload(VoidCallback fn) {
    setState(() {
      fn();
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Map>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          final scaledData = snapshot.data![0];
          final unscaledData = snapshot.data![1];

          final keys = scaledData.keys.toList().reversed.toList();
          final scaledValues = scaledData.values.toList().reversed.toList();
          final unscaledValues = unscaledData.values.toList().reversed.toList();

          final sections = List.generate(keys.length, (i) {
            return PieChartSectionData(
              color: getColor(keys[i]),
              value: scaledValues[i],
              title: scaledValues[i] > 5 ? '${keys[i]}\n${scaledValues[i]}%' : '',
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          });

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  selectorBox(
                    muscleSelected,
                    'muscles',
                    (entry) => _updateAndReload(() {
                      muscleSelected = entry.key;
                    }),
                    context,
                  ),
                  selectorBox(
                    timeSelected,
                    'time',
                    (entry) => _updateAndReload(() {
                      timeSelected = entry.key;
                      range = entry.value;
                    }),
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
                          sections: sections,
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
                      chartTarget = 'Sets';
                    }),
                  ),
                  _SelectorBox(
                    text: 'Volume',
                    selected: chartTarget == 'Volume',
                    onTap: () => _updateAndReload(() {
                      chartTarget = 'Volume';
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.grey, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: keys.length,
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
                                  color: getColor(keys[index]),
                                  border: Border.all(color: Colors.black),
                                ),
                              ),
                              Text(
                                '${keys[index]} : ',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Spacer(),
                              Text(
                                '${unscaledValues[index].toStringAsFixed(1)} '
                                '${chartTarget == 'Volume' ? 'kg' : chartTarget} '
                                ': ${scaledValues[index]}%',
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
        },
      ),
    );
  }
}

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
