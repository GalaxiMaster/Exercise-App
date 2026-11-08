import 'package:equatable/equatable.dart';
import 'package:exercise_app/Functions/chart_calculations.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/exercise.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadarParams extends Equatable {
  const RadarParams({required this.userId, required this.filters, this.depth});
  final String userId;
  final ChartFilters filters;
  final int? depth;

  @override
  List<Object?> get props => [userId, filters, depth];
}

class RadarChartPage extends ConsumerWidget {
  const RadarChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(radarChartFilterProvider);
    final radarSectionsProvider = ref.watch(radarModelProvider(RadarParams(userId: '', filters: filters)));
    final statBoxDataProvider = ref.watch(statBoxModelProvider);

    return Scaffold(
      appBar: myAppBar(context, 'Radar Chart'),
      body: radarSectionsProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: GestureDetector(
                    onTap: () async{
                      var entry = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SelectorPopupMap(options: TimeFilter.values);
                        },
                      );
                      if (entry != null) {
                        ref.read(radarChartFilterProvider.notifier).setTime(entry);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor.fromHex('151515'),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      height: 50,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              filters.timeFilter.label,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white,)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                radarChartWidget(data),
                statBoxDataProvider.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading data $err')),
                  data: (statTiles) => Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: statTiles.map<Widget>((element){
                      return SizedBox(
                        width: 200,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                    children: [
                                      TextSpan(
                                        text: element.value.toStringAsFixed(0),
                                      ),
                                      TextSpan(
                                        text: element.unit,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ]
                                  )
                                ),
                              
                                if (filters.timeFilter.label != 'All Time')
                                Builder(
                                  builder: (context) {
                                    Color color = element.change > 0
                                      ? Colors.green
                                      : element.change < 0
                                        ? Colors.red
                                        : Colors.grey;
                                    return Row(
                                      children: [
                                        Icon(
                                          element.change > 0
                                            ? Icons.arrow_upward
                                            : element.change < 0
                                              ? Icons.arrow_downward
                                              : Icons.remove,
                                          color: color,
                                          size: 18,
                                        ),
                                        if (element.change != 0)
                                        Text(
                                          '${element.change.toStringAsFixed(0)} ${element.unit}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }
}

Map<int, Map<String, double>> getPercentageData(Map<String, dynamic> data, TargetFilter target, TimeFilter timeFilter, Ref ref, {MuscleFilter? targetMuscleGroup, int depth = 1}) {
  Map exercises = ref.watch(exercisesProvider);

  Map<int, Map<String, double>> muscleData = {
    for (int i = 0; i < depth; i++) i: {},
  };

  for (var day in data.keys){
    Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
    int diff = difference.inDays;

    int? inRange;
    if (diff <= timeFilter.range * (depth) || timeFilter.range == -1){
      inRange = (diff/timeFilter.range).floor();
    }

    if (inRange != null){
      for (var exercise in data[day]['sets'].keys){
        Exercise? exerciseData = exercises[exercise];
        
        if (exerciseData == null) continue;
        final Map<String, dynamic> musclesInExercise = {
          ...exerciseData.primary,
          ...exerciseData.secondary,
        };
        if (targetMuscleGroup != null && targetMuscleGroup != MuscleFilter.allMuscles){ // todo DO I WANT TO DO IT SO It picks up any exercise with chest muscle groups in them or only diplays muscles in the chest group
          List muscleGroupMembers = muscleGroups[targetMuscleGroup.label] ?? [];
          bool muscleExists = muscleGroupMembers.any((muscle){
            return musclesInExercise.containsKey(muscle);
          });
          if (!muscleExists) continue;
        }

        for (var set in data[day]['sets'][exercise]){
          double selector = 0;
          switch(target){
            case TargetFilter.volume: selector = double.parse(set['weight'].toString())*double.parse(set['reps'].toString());
            default : selector = 1; // only covers volume and sets targets
          }
          for (var muscle in musclesInExercise.keys){
            muscleData[inRange]?[muscle] = (muscleData[inRange]?[muscle] ?? 0) + selector*(musclesInExercise[muscle]/100);
          }
        }
      }
    }else{
      debugPrint("$day Out of range");
    }
  }
  for (int rangeKey in muscleData.keys){
    List<MapEntry<String, double>> entries = muscleData[rangeKey]!.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    muscleData[rangeKey] = Map.fromEntries(entries);
  }


  return muscleData;
}

// Calculations
List<ComparisonStatTile> getStatBoxData(Map data, int range) {
  Map stats = {
    'Workouts': {0: 0, 1: 0},
    'Total Volume': {0: 0.0, 1: 0.0},
    'Sets': {0: 0, 1: 0},
    'Duration': {0: 0, 1: 0},
  };
  for (var day in data.keys){
    Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
    int diff = difference.inDays;

    int? rangeKey;
    if (diff <= range || range == -1){
      rangeKey = 0;
    } else if (diff <= range*2) {
      rangeKey = 1;
    }

    if (rangeKey != null){
      DateTime startTime = DateTime.parse(data[day]['stats']['startTime']);
      DateTime endTime = DateTime.parse(data[day]['stats']['endTime']);
      Duration length = endTime.difference(startTime);
      stats['Duration'][rangeKey] = (stats['Duration'][rangeKey] ?? 0) + length.inMinutes;
      stats['Workouts'][rangeKey] = (stats['Workouts'][rangeKey] ?? 0) + 1;
      for (String exercise in data[day]['sets'].keys){
        for (var set in data[day]['sets'][exercise]){
          double volume = double.parse(set['weight'].toString())*double.parse(set['reps'].toString());
          stats['Total Volume'][rangeKey] = (stats['Total Volume'][rangeKey] ?? 0) + volume;
          stats['Sets'][rangeKey] = (stats['Sets'][rangeKey] ?? 0) + 1;
        }
      }
    }
  }
  List<ComparisonStatTile> statTileList = [];
  for (MapEntry entry in stats.entries){
    statTileList.add(
      ComparisonStatTile(
        title: entry.key,
        value: entry.value[0].toDouble(),
        change: calculateDifference(entry.value[0].toDouble(), entry.value[1]?.toDouble() ?? 0),
        unit: entry.key == 'Duration' ? 'min' : (entry.key == 'Total Volume' ? 'kg' : '')
      )
    );
  }
  return statTileList;
}

// Providers
final statBoxModelProvider = Provider.autoDispose<AsyncValue<List<ComparisonStatTile>>>((ref) {
  final filters = ref.watch(radarChartFilterProvider);
  final rawDataAsync = ref.watch(workoutDataProvider);

  return rawDataAsync.whenData((data) {
    final List<ComparisonStatTile> boxData = getStatBoxData(data, filters.timeFilter.range);

    return boxData;
  });
});


final radarChartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});

final radarModelProvider = Provider.autoDispose.family<AsyncValue<List<List<RadarEntry>>>, RadarParams>((ref, params) {
  final dataAsync = params.userId.isEmpty ? ref.watch(workoutDataProvider) : ref.watch(friendWorkoutHistoryProvider(params.userId));
  return dataAsync.whenData((data) => buildRadarSections(data, params.filters, ref, depth: params.depth));
});



// Widgets
Widget radarChartWidget(List<List<RadarEntry>> data, {double size = 350}) { // name under subjection
  const axisCount = 6;
  RadarDataSet scaleSet(double v) => RadarDataSet(
    fillColor: Colors.transparent,
    borderColor: Colors.transparent,
    borderWidth: 0,
    entryRadius: 0,
    dataEntries: List.generate(axisCount, (_) => RadarEntry(value: v)),
  );
  return SizedBox(
    height: size,
    child: RadarChart(
      RadarChartData(
        dataSets: [
          scaleSet(0),
          scaleSet(100),
          if (data.length > 1)
          RadarDataSet(
            fillColor: Colors.grey.withValues(alpha: 0.2),
            borderColor: Colors.grey.withValues(alpha: 0.5),
            borderWidth: 2,
            entryRadius: 0,
            dataEntries: data[1],
          ),
          if (data.isNotEmpty)
          RadarDataSet(
            fillColor: Colors.blue.withValues(alpha: 0.2),
            borderColor: Colors.blue,
            borderWidth: 2,
            entryRadius: 0,
            dataEntries: data[0],
          ),
        ],

        tickCount: 6,
        tickBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.25), width: 1),
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        radarBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.35), width: 1),
        gridBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.25), width: 1),

        titlePositionPercentageOffset: 0.1,

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
  );
}


class SelectorPopupMap extends StatefulWidget {
  final List options;
  const SelectorPopupMap({super.key, required this.options});

  @override
  // ignore: library_private_types_in_public_api
  _SelectorPopupMapState createState() => _SelectorPopupMapState();
}

class _SelectorPopupMapState extends State<SelectorPopupMap> {

  void selectTime(dynamic filter) {
    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: widget.options.map((entry) {
            return boxThing(entry);
          }).toList(),
        ),
      ),
    );
  }

  Widget boxThing(dynamic entry) { // TimeFilter or MuscleFilter?
    return GestureDetector(
      onTap: () {
        selectTime(entry); // Trigger selectTime with the corresponding days
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('262626'),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(entry.label),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectorPopupList extends StatefulWidget {
  final List options;
  const SelectorPopupList({super.key, required this.options});

  @override
  // ignore: library_private_types_in_public_api
  _SelectorPopupListState createState() => _SelectorPopupListState();
}

class _SelectorPopupListState extends State<SelectorPopupList> {

  void selectEntry(dynamic entry) {
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: ListView.builder(
          itemCount: widget.options.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return boxThing(widget.options[index]);
          },
        )
      ),
    );
  }

  Widget boxThing(dynamic entry) {
    return GestureDetector(
      onTap: () {
        selectEntry(entry);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('262626'),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(entry.label ?? entry),
            ),
          ),
        ),
      ),
    );
  }
}

