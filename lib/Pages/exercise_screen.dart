import 'dart:math';

import 'package:exercise_app/Pages/day_screen_individual.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'radar_chart.dart';

enum TabItem {
  graph,
  info,
}

// ignore: must_be_immutable
class ExerciseScreen extends StatefulWidget {
  final List exercises;

  const ExerciseScreen({super.key, required this.exercises});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List exerciseData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};
  String selector = 'weight';
  String week = '';
  num graphvalue = 0;
  TabItem _currentTab = TabItem.graph;
  String weekrangeStr = 'All Time';
  int range = -1;
  
  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }
 
  void alterHeadingBar(num value, String weekt){
    setState(() {
      graphvalue = numParsething(value);
      week = weekt;
    });
  }

  Future<void> _loadHighlightedDays({reload = false}) async {
    var data = await getStats(widget.exercises, range);
    final List dates = exerciseData.map((data) => data['date']).toList(); // .split(' ')[0]
    final List values = exerciseData.map((data) => data[selector]).toList();

    debugPrint(data.toString());
    setState(() {
      exerciseData = data[0];
      if (data[0].isNotEmpty){
        heaviestWeight = data[1];
        heaviestVolume = data[2];
      }
      if (reload){
        graphvalue = numParsething(values[values.length - 1]);
        week = dates[dates.length - 1];
        alterHeadingBar(graphvalue, week);
      }
    });
  }
  
  void _selectTab(TabItem tabItem) {
    setState(() {
      _currentTab = tabItem;
    });
  }
  
  Widget _buildPageContent(var spots, var dates, xValues) {
    switch (_currentTab) {
      case TabItem.info:
        return infoBody(widget.exercises);
      case TabItem.graph:
        return graphBody(spots, dates, xValues, context);
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }
  Map scaleMapTo(Map map, num targetSum) {
    num currentSum = map.values.reduce((a, b) => a + b);
    num scaleFactor = targetSum / currentSum;
    return map.map((k, v) => MapEntry(k, double.parse((v * scaleFactor).toStringAsFixed(2))));
  }

  @override
  Widget build(BuildContext context) {
    final List dates = exerciseData.map((data) => data['date']).toList(); // .split(' ')[0]
    final List xValues = exerciseData.map((data) => data['x-value']).toList();
    final List values = exerciseData.map((data) => data[selector]).toList();
    final Set things = exerciseData.map((data) => data['x-value']).toSet();

    String setting = 'notScaled';
    if (dates.isNotEmpty){
      if (week == ''){
        week = dates[dates.length - 1];
      }
      if (graphvalue == 0){
        graphvalue = numParsething(values[values.length - 1]);
      }
    }
    final Map<String, List<FlSpot>> spotsByExercise = {};

    // Iterate through the exercise data
    exerciseData.asMap().entries.forEach((entry) {
      final exerciseName = entry.value['exercise'] as String;
      if (exerciseName == 'Dumbbell Incline Bench Press'){
        debugPrint('yes');
      }
      // Initialize the list for this exercise if it doesn't exist
      spotsByExercise[exerciseName] ??= [];
      
      // Create and add the FlSpot for this entry
      spotsByExercise[exerciseName]!.add(
        FlSpot(
          setting == 'notScaled' ? things.toList().indexOf(entry.value['x-value']).toDouble() : entry.value['x-value'].toDouble(), // Use the index as the X value
          (exerciseMuscles[widget.exercises]?['type'] ?? 'weighted') != 'bodyweight' 
              ? double.parse(entry.value[selector].toString()) 
              : double.parse(entry.value['reps'].toString()),
        ),
      );
    });


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercises.length == 1 ?  widget.exercises[0] : 'Exercises Data'),
      ),
      body: _buildPageContent(spotsByExercise, dates, xValues),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index, // Convert enum to index
        onTap: (index) {
          // Convert index back to enum
          _selectTab(TabItem.values[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
    );
  }
  
  Widget infoBody(List exercise){
    Map primaryMuscles = {};
    Map secondaryMuscles = {};
    for (String exercise in widget.exercises){
      for (String muscle in exerciseMuscles[exercise]['Primary'].keys){
        primaryMuscles[muscle] = (primaryMuscles[muscle] ?? 0) + exerciseMuscles[exercise]['Primary'][muscle];
      }     
      for (String muscle in exerciseMuscles[exercise]['Secondary'].keys){
        secondaryMuscles[muscle] = (secondaryMuscles[muscle] ?? 0) + exerciseMuscles[exercise]['Secondary'][muscle];
      }
    }
    num totalSum = [...primaryMuscles.values, ...secondaryMuscles.values].reduce((a, b) => a + b);
    if (primaryMuscles.isNotEmpty){
      num map1Portion = 100 * primaryMuscles.values.reduce((a, b) => a + b) / totalSum;
      primaryMuscles = scaleMapTo(primaryMuscles, map1Portion);
    }
    if (secondaryMuscles.isNotEmpty){
      num map2Portion = 100 * secondaryMuscles.values.reduce((a, b) => a + b) / totalSum;
      secondaryMuscles = scaleMapTo(secondaryMuscles, map2Portion);
    }
        
    return Column(
       children: [
        BodyHeatMap(assetPath: 'Assets/Muscle_heatmap.svg', exercises: widget.exercises,),
        const Text(
          'Primary muscles:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal, // Set the direction to horizontal
            itemCount: primaryMuscles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optional padding for spacing
                child: Text('${primaryMuscles.values.toList()[index]}% ${primaryMuscles.keys.toList()[index]}'),
              );
            },
          ),
        ),
        const Text(
          'Secondary muscles:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal, // Set the direction to horizontal
            itemCount: secondaryMuscles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optional padding for spacing
                child: Text('${secondaryMuscles.values.toList()[index]}% ${secondaryMuscles.keys.toList()[index]}'),
              );
            },
          ),
        ),
      ]
    );
  }
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
    ]; 
  Widget graphBody(Map<String, List<FlSpot>> spots, List<dynamic> dates, List xValues, BuildContext context) {

    String unit = 'kg';
    if ((exerciseMuscles[widget.exercises]?['type'] ?? 'Weighted') == 'bodyweight' || selector == 'reps'){unit = '';}
    final List<LineChartBarData> allLineBarsData = [];
    int exercisesNum = 0;
    // Add a line for each exercise
    for (var entry in spots.entries) {
      // Add the main line for this exercise
      exercisesNum++;
      allLineBarsData.add(
        LineChartBarData(
          spots: entry.value,
          color: colors[exercisesNum~/2 % colors.length],
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: colors[exercisesNum~/2 % colors.length]
                .withOpacity(0.2),
          ),
        ),
      );

      // Add best fit line if there are enough points
      if (entry.value.length > 1) {
        allLineBarsData.add(
          LineChartBarData(
            isStrokeCapRound: false,
            dotData: const FlDotData(show: false),
            spots: calculateBestFitLine(entry.value),
            color: Colors.primaries[allLineBarsData.length % Colors.primaries.length]
                .withRed(255), // Makes it a reddish version of the main line color
            barWidth: 2,
            dashArray: [5, 5],
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }
    final PageController pageController = PageController(
      initialPage: widget.exercises.length == 1 ? 1 : 1000, // Start in the middle to simulate infinite scrolling
    );
    if (true) {
      return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${graphvalue.toStringAsFixed(2)} $unit',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async{
                                Map data = await readData();
                                Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(builder: (context) => IndividualDayScreen(dayData: data[week], dayKey: week,))
                                ).then((_) {
                                  _loadHighlightedDays(reload: true);  // Call the method after returning from Addworkout
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  spots.isNotEmpty ? DateFormat('MMM dd').format(DateTime.parse(week.split(' ')[0])) : '0',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                        GestureDetector(
                          onTap: () async{
                            var entry = await showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return TimeSelectorPopup(options: Options().timeOptions);
                              },
                            );
                            if(entry != null) {
                              setState(() {
                                range = entry.value;
                                weekrangeStr = entry.key;  
                              });
                              _loadHighlightedDays();
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                weekrangeStr,
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.blue,)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: allLineBarsData,
                        lineTouchData: LineTouchData(  
                          handleBuiltInTouches: true, // Use built-in touch to ensure touch events are handled correctly
                          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                            debugPrint(touchResponse?.lineBarSpots.toString());
                            if (event is FlTapUpEvent) {
                              final touchX = event.localPosition.dx; // The raw X-position of the touch in pixels
                              const double minX = 0;
                              final double maxX = xValues[xValues.length-1].toDouble();
                              const chartWidth = 420.0;
                              final touchedXValue = int.parse((minX + (touchX / chartWidth) * (maxX - minX)+1).toStringAsFixed(0));
                              
                              debugPrint('Touched X-axis value: $touchedXValue');}
                            if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                              // Find the nearest point (spot) the user interacted with
                              final touchedSpot = touchResponse.lineBarSpots!.first;
                
                              // Get the index and value of the touched spot
                              final int index = touchedSpot.spotIndex;
                              final String weekLabel = dates[index]; // Assuming 'dates' is a list of labels for each X point
                              final double value = touchedSpot.y; // Y value at the touched point
                              // Use post-frame callback to ensure state/UI updates occur after the touch event
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                alterHeadingBar(value, weekLabel); // Trigger your heading update function
                              });
                            }
                          },
                          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              // Draw a vertical line from the top to the bottom of the chart at the X-axis of the touched spot
                              return const TouchedSpotIndicatorData(
                                FlLine(
                                  color: Colors.blue,      // Vertical line color
                                  strokeWidth: 2,          // Vertical line thickness
                                ),
                                FlDotData(show: true),     // Optionally show a dot at the touched point
                              );
                            }).toList();
                          },
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              interval: spots.isNotEmpty ? calculateInterval(spots.values.fold(0, (sum, list) => sum + list.length), spots.values.expand((spots) => spots).map((spot) => spot.x).reduce(max)) : 9999,
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return SideTitleWidget(
                                  axisSide: AxisSide.bottom,
                                  child: Text(
                                    spots.isNotEmpty ? DateFormat('MMM dd').format(DateTime.parse(dates[findClosestIndexInSorted(xValues, value)].split(' ')[0])) : '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return Text(value.toInt().toString()); // Display as integer
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        gridData: const FlGridData(show: true),
                      ),
                    ),
                  ),
                  if ((exerciseMuscles[widget.exercises]?['type'] ?? 'Weighted') != 'bodyweight')
                  Row(
                    children: [
                      selectorBox('Weight', selector == 'weight'),
                      selectorBox('Volume', selector == 'volume'),
                      selectorBox('Reps', selector == 'reps'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // if (widget.exercises.length > 1)
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      physics: widget.exercises.length == 1 ? const NeverScrollableScrollPhysics() : null,
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      itemBuilder: (context, index){
                        final itemIndex = index % widget.exercises.length;
                        String exercise = widget.exercises[itemIndex];
                        return exerciseTile(exercise, itemIndex, spots.isNotEmpty ? numParsething(findGradient(spots[exercise] ?? [])) : 0);
                      }
                    ),
                  ),
                  // if (widget.exercises.length == 1)
                  // exerciseTile(widget.exercises[0], 0)

                ],
              ),
          ),
        );
    }
  }
  String getGradientData(List<FlSpot> points){
    FlSpot a = points[0];
    FlSpot b = points[points.length-1];

    double gradient = (a.y-b.y)/(0-points.length);
    return gradient.toStringAsFixed(2);
  }
  Widget exerciseTile(String exercise, index, increase) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors[index % colors.length].withOpacity(.2),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise,
                style: const TextStyle(
                  fontSize: 20
                ),
              ),
              const Divider(
                thickness: .2,
              ),
              if ((exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'bodyweight')
              Text('Most weight : ${heaviestWeight[exercise]?['weight']}kg x ${heaviestWeight[exercise]?['reps']}'),
              if ((exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'bodyweight')
              Text('Most volume : ${heaviestVolume[exercise]?['weight']}kg x ${heaviestVolume[exercise]?['reps']}'),
              if ((exerciseMuscles[exercise]?['type'] ?? 'Weighted') == 'bodyweight')
              Text('Highest reps: ${numParsething(heaviestVolume[exercise]?['reps'])}'),
              Text('Increase: $increase%')
            ],
          ),
        ),
      ),
    );
  }


int findClosestIndexInSorted(List list, double target) {
  int left = 0, right = list.length - 1;

  while (left < right) {
    int mid = (left + right) ~/ 2;

    if (list[mid] == target) {
      return mid; // Exact match
    } else if (list[mid] < target) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }

  // Compare the two closest candidates
  if (left == 0) return left;
  if (left == list.length) return list.length - 1;
  
  return (target - list[left - 1]).abs() <= (list[left] - target).abs()
      ? left - 1
      : left;
}


  double calculateInterval(int itemCount, num itemTotal) {
    itemTotal == 0 ? itemTotal = 1 : null;
    if (itemCount <= 5) return itemTotal/5 + 1;
    return itemTotal/5 + 1;
  }
  
  Widget selectorBox(String text, bool selected){
    return GestureDetector(
      onTap: () async{

        setState(() {
          switch(text){
            case 'Weight': selector = 'weight';
            case 'Volume': selector = 'volume';
            case 'Reps': selector = 'reps';
          }
          final List dates = exerciseData.map((data) => data['date']).toList(); // .split(' ')[0]
          final List values = exerciseData.map((data) => data[selector]).toList();
          graphvalue = values.isNotEmpty ? numParsething(values[values.length - 1]) : 0;
          week = dates.isNotEmpty ? dates[dates.length - 1] : '';
          alterHeadingBar(graphvalue, week);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : HexColor.fromHexColor('151515'),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(
              text
            ),
          ),
        ),
      ),
    );
  }
}
extension ColorExtension on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

class BodyHeatMap extends StatefulWidget {
  final String assetPath;
  final double width;
  final List exercises;

  const BodyHeatMap({
    super.key,
    required this.assetPath,
    this.width = 500, 
    required this.exercises,
  });

  @override
  _BodyHeatMapState createState() => _BodyHeatMapState();
}

class _BodyHeatMapState extends State<BodyHeatMap> {
  String? modifiedSvgString;

  @override
  void initState() {
    super.initState();
    _loadAndModifySvg();
  }

  Future<void> _loadAndModifySvg() async {
    try {
      Map<String, List<dynamic>> musclesMap = {};
      for (String exercise in widget.exercises){
        for (MapEntry muscle in exerciseMuscles[exercise]['Primary'].entries){
          musclesMap[muscle.key] = [muscle.value/100, Colors.red];
        }
        for (MapEntry muscle in exerciseMuscles[exercise]['Secondary'].entries){
          musclesMap[muscle.key] = [muscle.value/100, Colors.red];
        }
      }
      musclesMap['Body'] = [1.0, Colors.grey];
      String modifiedSvg = await modifySvgPaths(widget.assetPath, musclesMap);
      debugPrint(modifiedSvg);
      setState(() {
        modifiedSvgString = modifiedSvg;
      });
    } catch (e) {
      debugPrint('Error loading or modifying SVG: $e');
      // Handle error (e.g., show error message to user)
    }
  }

Future<String> modifySvgPaths(String assetPath, Map<String, List<dynamic>> heatMap) async {
  String svgString = await rootBundle.loadString(assetPath);
  final document = xml.XmlDocument.parse(svgString);
  
  heatMap.forEach((className, values) {
    if (values.length != 2 || values[0] is! double || values[1] is! Color) {
      throw ArgumentError('Invalid heat map data for $className');
    }
    
    double opacity = values[0] as double;
    Color color = values[1] as Color;
    debugPrint("${className == 'Upper Chest'}ballsac $className" );
    final paths = document.findAllElements('path')
        .where((element) => element.getAttribute('class')?.contains(className) ?? false);
    
    // debugPrint('Class: $className, Paths found: ${paths.length}');
    
    for (var path in paths) {
      // String oldFill = path.getAttribute('fill') ?? 'none';
      // String oldOpacity = path.getAttribute('fill-opacity') ?? '1';
      
      path.setAttribute('fill', color == Colors.red ? getRedShade(opacity).toHex() : color.toHex());  
      // debugPrint('Path updated - Class: $className, Old fill: $oldFill, New fill: ${color.toHex()}, Old opacity: $oldOpacity, New opacity: $opacity');
    }
  });
    
    // Convert the modified document back to a string
    return document.toXmlString(pretty: true);
  }
  Color interpolateColor(Color startColor, Color endColor, double t) {
    return Color.fromARGB(
      255,
      _interpolate(startColor.red, endColor.red, t),
      _interpolate(startColor.green, endColor.green, t),
      _interpolate(startColor.blue, endColor.blue, t),
    );
  }

  int _interpolate(int start, int end, double t) {
    return (start + (end - start) * t).round().clamp(0, 255);
  }

  Color getRedShade(double intensity, {Color lightShade = const Color.fromARGB(255, 240, 111, 109), Color darkShade = const Color(0xFF8B0000)}) {
    // Ensure intensity is between 0 and 1
    intensity = intensity.clamp(0.0, 1.0);
    return interpolateColor(lightShade, darkShade, intensity);
  }
  @override
  Widget build(BuildContext context) {
    return modifiedSvgString != null
        ? SvgPicture.string(
            modifiedSvgString!,
            width: widget.width,
          )
        : const CircularProgressIndicator();
  }
}

Future<List> getStats(List targets, range) async {
  Map data = await readData();
  List targetData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};
  var sortedKeys = data.keys.toList()..sort();
  DateTime? startDate;
  // Create a sorted map by iterating over sorted keys
  Map<String, dynamic> sortedMap = {
    for (var key in sortedKeys) key: data[key]!,
  };
  data = sortedMap;
  for (var day in data.keys.toList()) {
    DateTime dayDate = DateTime.parse(day.split(' ')[0]);
    Duration difference = DateTime.now().difference(dayDate); // Calculate the difference
    int diff = difference.inDays;
    if (diff <= range || range == -1){
      Map dayHeaviestWeight = {};
      Map dayHeaviestVolume = {};

      for (var exercise in data[day]['sets'].keys) {
        if (targets.contains(exercise)) {

          startDate ??= dayDate;
          for (var set in data[day]['sets'][exercise]) {
            set = {
              'weight': double.parse(set['weight'].toString()),
              'reps': double.parse(set['reps'].toString()),
              'type': set['type'],
              'date': day,
              'volume': double.parse(set['reps'].toString()) * double.parse(set['weight'].toString()),
              'exercise': exercise,
              'x-value': dayDate.difference(startDate).inDays,
            };

            if ((dayHeaviestWeight[exercise]?.isEmpty ?? false) || set['weight'] > (dayHeaviestWeight[exercise]?['weight'] ?? -9999)) { // TODO find better wqay of doing htis
              dayHeaviestWeight[exercise] = set;
            }

            if ((dayHeaviestVolume[exercise]?.isEmpty ?? false) || set['volume'] > (dayHeaviestWeight[exercise]?['volume'] ?? -9999)) {
              dayHeaviestVolume[exercise] = set;
            }
          }
          if (dayHeaviestWeight[exercise]?.isNotEmpty ?? false) {
            targetData.add(dayHeaviestWeight[exercise]);
          }

          if ((heaviestWeight[exercise]?.isEmpty ?? false) || (dayHeaviestWeight[exercise]?['weight'] ?? -9999) > (heaviestWeight[exercise]?['weight'] ?? -9999)) {
            heaviestWeight[exercise] = dayHeaviestWeight[exercise];
          }

          if ((heaviestVolume[exercise]?.isEmpty ?? false) || (dayHeaviestVolume[exercise]?['volume'] ?? -9999) > (heaviestVolume[exercise]?['volume'] ?? -9999)) {
            heaviestVolume[exercise] = dayHeaviestVolume[exercise];
          }
        }
      } 
    }
  }
  for (Map set in targetData){
    if (set['exercise'] == 'Dumbbell Incline Bench Press'){
      debugPrint('yes');
    }
  }
  return [targetData, heaviestWeight, heaviestVolume];
}

List<FlSpot> calculateBestFitLine(List<FlSpot> dataPoints) {
  int n = dataPoints.length;
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (var point in dataPoints) {
    sumX += point.x;
    sumY += point.y;
    sumXY += point.x * point.y;
    sumX2 += point.x * point.x;
  }

  // Calculate slope (m) and y-intercept (b)
  double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  double b = (sumY - m * sumX) / n;

  // Generate the best-fit line points based on the slope and intercept
  double minX = dataPoints.map((point) => point.x).reduce((a, b) => a < b ? a : b);
  double maxX = dataPoints.map((point) => point.x).reduce((a, b) => a > b ? a : b);

  // Return two points that represent the start and end of the line of best fit
  return [FlSpot(minX, m * minX + b), FlSpot(maxX, m * maxX + b)];
}

double findGradient(List<FlSpot> dataPoints){
  FlSpot a = dataPoints[0];
  FlSpot b = dataPoints[dataPoints.length-1];
  if (a.y < 0 && b.y < 0){
    return ((b.y-a.y).abs()/(min(a.y.abs(), b.y.abs())))*100;
  }
  return ((b.y-a.y)/a.y.abs())*100;
}