import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

enum TabItem {
  graph,
  info,
}

// ignore: must_be_immutable
class ExerciseScreen extends StatefulWidget {
  final String exercise;

  const ExerciseScreen({super.key, required this.exercise});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List exerciseData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};
  String selector = 'volume';
  String week = '';
  num graphvalue = 0;
  TabItem _currentTab = TabItem.graph;

  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }
  void alterHeadingBar(double value, String weekt){
    setState(() {
      graphvalue = numParsething(value);
      week = weekt;
    });
  }
  Future<void> _loadHighlightedDays() async {
    var data = await getStats(widget.exercise);
    debugPrint(data.toString());
    setState(() {
      exerciseData = data[0];
      if (data[0].isNotEmpty){
        heaviestWeight = data[1];
        heaviestVolume = data[2];
      }
    });
  }
  void _selectTab(TabItem tabItem) {
    setState(() {
      _currentTab = tabItem;
    });
  }
  Widget _buildPageContent(var spots, var dates) {
    switch (_currentTab) {
      case TabItem.info:
        return infoBody(widget.exercise);
      case TabItem.graph:
        return graphBody(spots, dates, context);
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }
  @override
  Widget build(BuildContext context) {
    final List dates = exerciseData.map((data) => data['date']).toList(); // .split(' ')[0]
    final List values = exerciseData.map((data) => data[selector]).toList();
    if (dates.isNotEmpty){
      if (week == ''){
        week = dates[dates.length - 1];
      }
      if (graphvalue == 0){
        graphvalue = numParsething(values[values.length - 1]);
      }
    }
    final List<FlSpot> spots = exerciseData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(), // Use the index as the X value
              exerciseMuscles[widget.exercise]['type'] != 'bodyweight' ? double.parse(entry.value[selector].toString()) : double.parse(entry.value['reps'].toString()), // Parse the weight (Y value)
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise),
      ),
      body: _buildPageContent(spots, dates),
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
  
  Widget infoBody(String exercise){
    return Column(
       children: [
        BodyHeatMap(assetPath: 'Assets/Muscle_heatmap.svg', exercise: widget.exercise,),
        const Text(
          'Primary muscles:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal, // Set the direction to horizontal
            itemCount: exerciseMuscles[widget.exercise]['Primary'].keys.toList().length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optional padding for spacing
                child: Text('${exerciseMuscles[widget.exercise]['Primary'].values.toList()[index]}% ${exerciseMuscles[widget.exercise]['Primary'].keys.toList()[index]}'),
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
            itemCount: exerciseMuscles[widget.exercise]['Secondary'].keys.toList().length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optional padding for spacing
                child: Text('${exerciseMuscles[widget.exercise]['Secondary'].values.toList()[index]}% ${exerciseMuscles[widget.exercise]['Secondary'].keys.toList()[index]}'),
              );
            },
          ),
        ),
      ]
    );
  }
  Widget graphBody(List<FlSpot> spots, List<dynamic> dates, BuildContext context) {
    return spots.isNotEmpty ? SingleChildScrollView(
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
                              '$graphvalue kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => DayScreen(date: date, dayData: dayData, reload: reload))
                                // );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  DateFormat('MMM dd').format(DateTime.parse(week.split(' ')[0])),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                        const Row(
                          children: [
                            Text(
                              'Last 8 weeks',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: Colors.blue,)
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            // isCurved: true, // lets the graph be extrapolated, turned off due to incorrect points
                            color: Colors.blue,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        lineTouchData: LineTouchData(  
                          handleBuiltInTouches: true, // Use built-in touch to ensure touch events are handled correctly
                          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                            debugPrint(touchResponse?.lineBarSpots.toString());
                            if (event is FlTapUpEvent) {
                              final touchX = event.localPosition.dx; // The raw X-position of the touch in pixels
                              const double minX = 0;
                              final double maxX = (dates.length - 1).toDouble(); 
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
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return SideTitleWidget(
                                  axisSide: AxisSide.bottom,
                                  child: Text(
                                    DateFormat('MMM dd').format(DateTime.parse(dates[value.toInt()].split(' ')[0])),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                              interval: 1, // Ensure all dates are shown
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
                  if (exerciseMuscles[widget.exercise]['type'] != 'bodyweight')
                  Row(
                    children: [
                      selectorBox('Weight', selector == 'weight'),
                      selectorBox('Volume', selector == 'volume'),
                      selectorBox('Reps', selector == 'reps'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (exerciseMuscles[widget.exercise]['type'] != 'bodyweight')
                  Text('Most weight : ${heaviestWeight['weight']}kg x ${heaviestWeight['reps']}'),
                  if (exerciseMuscles[widget.exercise]['type'] != 'bodyweight')
                  Text('Most volume : ${heaviestVolume['weight']}kg x ${heaviestVolume['reps']}'),
                  if (exerciseMuscles[widget.exercise]['type'] == 'bodyweight')
                  Text('Highest reps: ${numParsething(heaviestVolume['reps'])}'),
                ],
              ),
          ),
        )
      :
        const Text("No data available");
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
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey,
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
  final String exercise;

  const BodyHeatMap({
    super.key,
    required this.assetPath,
    this.width = 500, 
    required this.exercise,
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
      for (MapEntry muscle in exerciseMuscles[widget.exercise]['Primary'].entries){
        musclesMap[muscle.key] = [muscle.value/100, Colors.red];
      }
      for (MapEntry muscle in exerciseMuscles[widget.exercise]['Secondary'].entries){
        musclesMap[muscle.key] = [muscle.value/100, Colors.red];
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
    
    final paths = document.findAllElements('path')
        .where((element) => element.getAttribute('class')?.contains(className) ?? false);
    
    debugPrint('Class: $className, Paths found: ${paths.length}');
    
    for (var path in paths) {
      String oldFill = path.getAttribute('fill') ?? 'none';
      String oldOpacity = path.getAttribute('fill-opacity') ?? '1';
      
      path.setAttribute('fill', color == Colors.red ? getRedShade(opacity).toHex() : color.toHex());  
      debugPrint('Path updated - Class: $className, Old fill: $oldFill, New fill: ${color.toHex()}, Old opacity: $oldOpacity, New opacity: $opacity');
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


Future<List> getStats(String target) async {
  Map data = await readData();
  List targetData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};

  for (var day in data.keys.toList().reversed) {
    Map dayHeaviestWeight = {};
    Map dayHeaviestVolume = {};

    for (var exercise in data[day]['sets'].keys) {
      if (exercise == target) {
        for (var set in data[day]['sets'][exercise]) {
          set = {
            'weight': double.parse(set['weight']),
            'reps': double.parse(set['reps']),
            'type': set['type'],
            'date': day,
            'volume': double.parse(set['reps']) * double.parse(set['weight'])
          };

          if (dayHeaviestWeight.isEmpty || set['weight'] > dayHeaviestWeight['weight']) {
            dayHeaviestWeight = set;
          }

          if (dayHeaviestVolume.isEmpty || set['volume'] > dayHeaviestVolume['volume']) {
            dayHeaviestVolume = set;
          }
        }

        if (dayHeaviestWeight.isNotEmpty) {
          targetData.add(dayHeaviestWeight);
        }

        if (heaviestWeight.isEmpty || dayHeaviestWeight['weight'] > heaviestWeight['weight']) {
          heaviestWeight = dayHeaviestWeight;
        }

        if (heaviestVolume.isEmpty || dayHeaviestVolume['volume'] > heaviestVolume['volume']) {
          heaviestVolume = dayHeaviestVolume;
        }
      }
    }
  }

  return [targetData, heaviestWeight, heaviestVolume];
}
