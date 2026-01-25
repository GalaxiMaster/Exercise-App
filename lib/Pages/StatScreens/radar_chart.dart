import 'package:exercise_app/Pages/StatScreens/data_charts.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadarChartPage extends ConsumerWidget {
  const RadarChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radarSectionsProvider = ref.watch(radarModelProvider);
    return Scaffold(
      appBar: myAppBar(context, 'Radar Chart'),
      body: radarSectionsProvider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading data $err')),
        data: (data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: GestureDetector(
                  onTap: () async{
                    var entry = await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SelectorPopupMap(options: Options().timeOptions);
                      },
                    );
                    if (entry != null) {
                      ref.read(chartFilterProvider.notifier).setRange(entry.value, entry.key);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor.fromHexColor('151515'),
                      borderRadius: BorderRadius.circular(50)
                    ),
                    height: 50,
                    width: double.infinity,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ref.watch(chartFilterProvider).timeLabel,
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
              SizedBox(
                height: 352,
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      if (data.length > 1)
                      RadarDataSet(
                        fillColor: Colors.grey.withValues(alpha: 0.2),
                        borderColor: Colors.grey.withValues(alpha: 0.5),
                        borderWidth: 2,
                        entryRadius: 3,
                        dataEntries: data[1]
                      ),
                      RadarDataSet(
                        fillColor: Colors.blue.withValues(alpha: 0.2),
                        borderColor: Colors.blue,
                        borderWidth: 2,
                        entryRadius: 3,
                        dataEntries: data[0],
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
              ),

            ],
          );
        }
      )
    );
  }
}
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHexColor({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class SelectorPopupMap extends StatefulWidget {
  final Map options;
  const SelectorPopupMap({super.key, required this.options});

  @override
  // ignore: library_private_types_in_public_api
  _SelectorPopupMapState createState() => _SelectorPopupMapState();
}

class _SelectorPopupMapState extends State<SelectorPopupMap> {

  void selectTime(MapEntry days) {
    Navigator.pop(context, days);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: widget.options.entries.map((entry) {
            return boxThing(entry);
          }).toList(),
        ),
      ),
    );
  }

  Widget boxThing(MapEntry entry) {
    return GestureDetector(
      onTap: () {
        selectTime(entry); // Trigger selectTime with the corresponding days
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHexColor('262626'),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(entry.key),
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

  void selectTime(dynamic days) {
    Navigator.pop(context, days);
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
        selectTime(entry);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHexColor('262626'),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(entry),
            ),
          ),
        ),
      ),
    );
  }
}
class PercentageDataRecords {
  final Map<String, double> current;
  final Map<String, double>? previous;
  PercentageDataRecords({required this.current, this.previous});
}

PercentageDataRecords getPercentageData(Map<String, dynamic> data, String target, int range, dynamic ref, {String? targetMuscleGroup}) {
  Map<int, Map<String, double>> muscleData = {0: {}, 1: {}};
  final Map customExercisesData = ref.read(customExercisesProvider).value ?? {};

  for (var day in data.keys){
    Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
    int diff = difference.inDays;

    int? inRange;
    if (diff <= range || range == -1){
      inRange = 0;
    } else if (diff <= range*2) {
      inRange = 1;
    }

    if (inRange != null){
      for (var exercise in data[day]['sets'].keys){
        bool isCustom = customExercisesData.containsKey(exercise);
        Map exerciseData = {};

        if (isCustom && customExercisesData.containsKey(exercise)){
          exerciseData = customExercisesData[exercise];
        } else {
          exerciseData = exerciseMuscles[exercise] ?? {};
        }
        
        if (exerciseData.isEmpty) continue;
        final Map<String, dynamic> musclesInExercise = {
          ...?exerciseData['Primary'],
          ...?exerciseData['Secondary'],
        };
        if (targetMuscleGroup != null && targetMuscleGroup != 'All Muscles'){ // DO I WANT TO DO IT SO It picks up any exercise with chest muscle groups in them or only diplays muscles in the chest group
          List muscleGroupMembers = muscleGroups[targetMuscleGroup] ?? [];
          bool muscleExists = muscleGroupMembers.any((muscle){
            return musclesInExercise.containsKey(muscle);
          });
          if (!muscleExists) continue;
        }

        for (var set in data[day]['sets'][exercise]){
          double selector = 0;
          switch(target){
            case 'Volume': selector = double.parse(set['weight'].toString())*double.parse(set['reps'].toString());
            case 'Sets' : selector = 1;
          }
          for (var muscle in musclesInExercise.keys){
            muscleData[inRange]?[muscle] = (muscleData[inRange]?[muscle] ?? 0) + selector*(musclesInExercise[muscle]/100);
          }
        }
      }
    }else{
      debugPrint("${data[day]}Out of range");
    }
  }
  for (int rangeKey in muscleData.keys){
    List<MapEntry<String, double>> entries = muscleData[rangeKey]!.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    muscleData[rangeKey] = Map.fromEntries(entries);
  }


  return PercentageDataRecords(current: muscleData[0]!, previous: muscleData[1]);
}


final chartFilterProvider = NotifierProvider.autoDispose<ChartFiltersNotifier, ChartFilters>(() {
  return ChartFiltersNotifier();
});

final radarModelProvider = Provider.autoDispose<AsyncValue<List<List<RadarEntry>>>>((ref) {
  final filters = ref.watch(chartFilterProvider);
  final rawDataAsync = ref.watch(workoutDataProvider);

  return rawDataAsync.whenData((data) {
    final PercentageDataRecords percentageData = getPercentageData(
      data, 
      filters.chartTarget, 
      filters.range, 
      ref, // Try to remove this dependency if possible
      targetMuscleGroup: filters.muscleSelected
    );

    List<List<RadarEntry>> radarSections = [];
    final List sectionSources = [percentageData.current, percentageData.previous ?? {}];
    for (int i = 0; i < sectionSources.length; i++) {
      if (sectionSources[i].isEmpty) continue;
      radarSections.add([]);
      for (String group in muscleGroups.keys){
        double total = 0;
        for (String muscle in muscleGroups[group]!) {
          double muscleNum = (sectionSources[i]?[muscle] ?? 0);
            total += muscleNum;
        }
        radarSections[i].add(RadarEntry(value: total));
      }
    }
    return radarSections;
  });
});