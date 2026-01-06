import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class RadarChartPage extends ConsumerStatefulWidget {
  Map sets;
  RadarChartPage({super.key, required this.sets});   
    @override
  // ignore: library_private_types_in_public_api
  _RadarChartPageState createState() => _RadarChartPageState();
}

class _RadarChartPageState extends ConsumerState<RadarChartPage> {
    Map sets = {};
    List<RadarEntry> data = [];
    String timeSelection = 'All time';

    Future<void> reloadData(int range) async {
      sets = (await getPercentageData('Sets', range, ref))[0];
      setState(() {
        data = [];
        for (String group in muscleGroups.keys){
          double total = 0;
          for (int i = 0;i < (muscleGroups[group]?.length ?? 0); i++) {
            double muscleNum = (sets[muscleGroups[group]?[i]] ?? 0);
              total += muscleNum;
          }
          data.add(RadarEntry(value: total));
        }
      });

    }
    @override
      initState(){
      super.initState();
      sets = widget.sets;
      for (String group in muscleGroups.keys){
        double total = 0;
        for (int i = 0;i < (muscleGroups[group]?.length ?? 0); i++) {
          double muscleNum = (sets[muscleGroups[group]?[i]] ?? 0);
            total += muscleNum;
        }
        data.add(RadarEntry(value: total));
      }
    }
    @override
    Widget build(BuildContext context) {
      int dayRange; 
      return Scaffold(
        appBar: myAppBar(context, 'Radar Chart'),
        body: Column(
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
                    // adjust things
                    setState(() {
                      dayRange = entry.value;
                      timeSelection = entry.key;
                      reloadData(dayRange);
                    });
               
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
                          timeSelection,
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
                    RadarDataSet(
                      fillColor: Colors.blue.withValues(alpha: 0.2),
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

  Future<List> getPercentageData(String target, int range, WidgetRef ref) async {
    Map muscleData = {};
    Map data = await readData();
    final Map customExercisesData = await ref.read(customExercisesProvider.future);

    for (var day in data.keys){
      Duration difference = DateTime.now().difference(DateTime.parse(day.split(' ')[0])); // Calculate the difference
      int diff = difference.inDays;
      if (diff <= range || range == -1){
        for (var exercise in data[day]['sets'].keys){
          bool isCustom = customExercisesData.containsKey(exercise);
          Map exerciseData = {};

          if (isCustom && customExercisesData.containsKey(exercise)){
            exerciseData = customExercisesData[exercise];
          } else {
            exercise = exerciseMuscles[exercise] ?? {};
          }

          if (exerciseData.isEmpty) continue;

          for (var set in data[day]['sets'][exercise]){
            double selector = 0;
            switch(target){
              case 'Volume': selector = double.parse(set['weight'].toString())*double.parse(set['reps'].toString());
              case 'Sets' : selector = 1;
            }
            for (var muscle in exerciseData['Primary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseData['Primary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseData['Primary']![muscle]!/100);
              }
            }
            for (var muscle in exerciseData['Secondary']!.keys){
              if (muscleData.containsKey(muscle)){
                muscleData[muscle] += selector*(exerciseData['Secondary']![muscle]!/100);
              } else{
                muscleData[muscle] = selector*(exerciseData['Secondary']![muscle]!/100);
              }
            }
          }
        }
      }else{
        debugPrint("${data[day]}Out of range");
      }
    }
    debugPrint(muscleData.toString());
    // Scale results to 100
    double total = muscleData.values.fold(0.0, (p, c) => p + c);
    debugPrint(total.toString());
    Map scaledMuscleData = {};
    for (String muscle in muscleData.keys){
      scaledMuscleData[muscle] = ((muscleData[muscle] / total * 100.0) * 100).roundToDouble() / 100;
    }
    List<MapEntry> entries = muscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    muscleData = Map.fromEntries(entries);
    debugPrint(muscleData.toString());
    entries = scaledMuscleData.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    scaledMuscleData = Map.fromEntries(entries);
    debugPrint(scaledMuscleData.toString());
    return [scaledMuscleData, muscleData].toList();
  }