import 'dart:math';
import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/day_screen.dart';
import 'package:exercise_app/Pages/day_screen_individual.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'StatScreens/radar_chart.dart';

enum TabItem {
  graph,
  history,
  info,
}

enum ScaleSetting {
  equalIntervals,
  scaled,
}

class ExerciseScreen extends ConsumerStatefulWidget {
  final List<String> exercises;

  const ExerciseScreen({super.key, required this.exercises});

  @override
  ExerciseScreenState createState() => ExerciseScreenState();
}

class ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  List exerciseData = [];
  Map heaviestWeight = {};
  Map heaviestVolume = {};
  String selector = 'weight';
  String week = '';
  num graphvalue = 0;
  TabItem _currentTab = TabItem.graph;
  String weekrangeStr = 'All Time';
  int range = -1;
  ScaleSetting scaleSetting = ScaleSetting.equalIntervals;
  Color activeColor = Colors.blue;
  bool isBodyWeight = false; // default false
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }
 
  void alterHeadingBar(num value, String weekt, Color color){
    setState(() {
      graphvalue = numParsething(value);
      week = weekt;
      activeColor = color;
    });
  }

  Future<void> _loadHighlightedDays({bool reload = false}) async {
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
        week = dates.last.split(' ')[0];
        alterHeadingBar(graphvalue, week, Colors.blue);
      }
    });
  }
  
  void _selectTab(int tabIndex, {bool movePage = true}) {
    if (pageController.hasClients && movePage) {
      pageController.animateToPage(
        tabIndex, 
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _currentTab = TabItem.values[tabIndex];
    });
  }
  
  Widget _buildPageContent(Map<String, List<FlSpot>> spots, List dates, List xValues, List<List> groupedDates) {
    List<Widget> pages  = [
      graphBody(spots, dates, xValues, context, isBodyWeight, groupedDates), 
      ExerciseHistory(targetExercises: widget.exercises),
      InfoBody(exercises: widget.exercises)
    ];

    return PageView.builder(
      controller: pageController,
      itemCount: pages.length,
      itemBuilder: (context, index){
        return pages[index];
      },
      onPageChanged: (index) {
        _selectTab(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List dates = exerciseData.map((data) => data['date']).toList(); // .split(' ')[0]
    final List xValues = exerciseData.map((data) => data['x-value']).toList();
    final List values = exerciseData.map((data) => data[selector]).toList();
    final Set things = exerciseData.map((data) => data['x-value']).toSet(); // todo rename
    final Map<String, List<String>> datesByExercise = {};

    for (final data in exerciseData) {
      final exercise = data['exercise'];
      final date = data['date']; // or .split(' ')[0]

      datesByExercise.putIfAbsent(exercise, () => []);
      datesByExercise[exercise]!.add(date);
    }

    if (dates.isNotEmpty){
      if (week == ''){
        week = dates.last.split(' ')[0];
      }
      if (graphvalue == 0){
        graphvalue = numParsething(values[values.length - 1]);
      }
    }
    final Map<String, List<FlSpot>> spotsByExercise = {};
    final bool isBodyWeight = widget.exercises.every((exercise) {
      return (exerciseMuscles[exercise]?['type'] ?? 'weighted') == 'Bodyweight';
    });
    
    // Iterate through the exercise data
    exerciseData.asMap().entries.forEach((entry) {
      final exerciseName = entry.value['exercise'] as String;

      // Initialize the list for this exercise if it doesn't exist
      spotsByExercise[exerciseName] ??= [];
      
      // Create and add the FlSpot for this entry
      spotsByExercise[exerciseName]!.add(
        FlSpot(
          scaleSetting == ScaleSetting.equalIntervals ? things.toList().indexOf(entry.value['x-value']).toDouble() : entry.value['x-value'].toDouble(), // Use the index as the X value
          (!isBodyWeight ? double.parse(entry.value[selector].toString()) : double.parse(entry.value['reps'].toString())),
        ),
      );
    });


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercises.length == 1 ?  widget.exercises[0] : 'Exercises Data'),
        actions: [
          if (_currentTab == TabItem.graph)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async{
              final result = await showSettingToggleDialog(
                context,
                scaleSetting,
              );

              if (result != null) {
                setState(() {
                  scaleSetting = result;
                });
              }
            },
          ),
        ],
      ),
      body: _buildPageContent(spotsByExercise, dates, xValues, datesByExercise.values.toList()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index, // Convert enum to index
        onTap: (index) {
          // Convert index back to enum
          _selectTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
    );
  }
  
  Widget graphBody(Map<String, List<FlSpot>> spots, List<dynamic> dates, List xValues, BuildContext context, bool isBodyWight, List<List> groupedDates) {
    Widget exerciseTile(String exercise, index, increase, isBodyWeight) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: graphColors[index].withValues(alpha: .2),
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
                if ((exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'Bodyweight')
                Text('Most weight : ${heaviestWeight[exercise]?['weight']}kg x ${heaviestWeight[exercise]?['reps']}'),
                if ((exerciseMuscles[exercise]?['type'] ?? 'Weighted') != 'Bodyweight')
                Text('Most volume : ${heaviestVolume[exercise]?['weight']}kg x ${heaviestVolume[exercise]?['reps']}'),
                if ((exerciseMuscles[exercise]?['type'] ?? 'weighted') == 'Bodyweight')
                Text('Highest reps: ${numParsething(heaviestVolume[exercise]?['reps'])}'),
                Text('Increase: $increase%')
              ],
            ),
          ),
        ),
      );
    }

    double calculateInterval(num itemTotal, num itemCount) {
      // If there is 0 or 1 item, return the total (nothing to divide)
      if (itemCount <= 1) {
        return itemTotal.toDouble();
      }

      // Guard against zero total range
      if (itemTotal == 0) {
        itemTotal = 1;
      }

      // There are (N - 1) gaps between N points — divide by N-1
      return (itemTotal.toDouble()) / (itemCount - 1);
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
            week = dates.isNotEmpty ? dates.last.split(' ')[0] : '';
            alterHeadingBar(graphvalue, week, Colors.blue);
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
    
    String getDateValue(List dates, num value) {
      if (scaleSetting == ScaleSetting.scaled){
        DateTime target = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        return DateFormat('MMM dd').format(target);
      }
      else{
        return DateFormat('MMM dd').format(DateTime.parse(dates[value.round()].split(' ')[0]));
      }
    }
    
    String unit = 'kg';
    if (isBodyWeight || selector == 'reps'){unit = '';}

    final List<LineChartBarData> allLineBarsData = [];
    List exercisesOrder = [];
    // Add a line for each exercise
    int i = 0;
    for (var entry in spots.entries) {
      // Add the main line for this exercise
      allLineBarsData.add(
        LineChartBarData(
          spots: entry.value,
          color: graphColors[exercisesOrder.length],
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: graphColors[exercisesOrder.length]
                .withValues(alpha: 0.2),
          ),
        ),
      );
      i++;
      // Add best fit line if there are enough points
      if (entry.value.length > 1) {
        allLineBarsData.add(
          LineChartBarData(
            isStrokeCapRound: false,
            dotData: const FlDotData(show: false),
            spots: calculateBestFitLine(entry.value),
            color: Colors.primaries[allLineBarsData.length % Colors.primaries.length].withRed(255), // Makes it a reddish version of the main line color
            barWidth: 2,
            dashArray: [5, 5],
            belowBarData: BarAreaData(show: false),
          ),
        );
        groupedDates.insert(i, <String>[]); // Adding filler list so that the barIndex lines up properly when theres multiple lines
        i++;
      }
      exercisesOrder.add(entry.key);
    }
    final PageController pageController = PageController(
      initialPage: widget.exercises.length == 1 ? 1 : 1000, // Start in the middle to simulate infinite scrolling
    );
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 12.5,
                              height: 12.5,
                              decoration: BoxDecoration(
                                color: activeColor,
                                border: Border.all(color: Colors.black)
                              ),
                            ),
                          ),
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
                              Map keys = {};
                              for (String key in data.keys) {
                                if (key.contains(week)){
                                  keys[key] = data[key];
                                }
                              }
                              if (keys.isEmpty || !context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => 
                                  keys.keys.length > 1 
                                    ? DayScreen(date: DateTime.parse(week), dayData: keys)
                                    : IndividualDayScreen(dayData: keys.values.first, dayKey: '${keys[0]} 1'))

                              ).then((_) {
                                _loadHighlightedDays(reload: true);  // Call the method after returning from Addworkout
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                spots.isNotEmpty ? DateFormat('MMM dd yyyy').format(DateTime.parse(week)) : '0',
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
                              return SelectorPopupMap(options: Options().timeOptions);
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
                          // debugPrint(touchResponse?.lineBarSpots.toString());
                          // if (event is FlTapUpEvent) {
                            // final touchX = event.localPosition.dx; // The raw X-position of the touch in pixels
                            // const double minX = 0;
                            // final double maxX = xValues[xValues.length-1].toDouble();
                            // const chartWidth = 420.0;
                            // final touchedXValue = int.parse((minX + (touchX / chartWidth) * (maxX - minX)+1).toStringAsFixed(0));
                            
                            // debugPrint('Touched X-axis value: $touchedXValue');
                          // }
                          if (touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                            // Find the nearest point (spot) the user interacted with
                            final touchedSpot = touchResponse.lineBarSpots!.first;
                            final barIndex = touchedSpot.barIndex;
                            // Get the index and value of the touched spot
                            // final int index = touchedSpot.spotIndex;
                            final String weekLabel; 
                            if (scaleSetting ==  ScaleSetting.equalIntervals){
                              weekLabel =  groupedDates[barIndex][touchedSpot.spotIndex].split(' ')[0]; // Assuming 'dates' is a list of labels for each X point ! DOESNT WORK WITH MULTIPLE GRAPHS
                            }
                            else{
                              weekLabel =  DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt())); // Assuming 'dates' is a list of labels for each X point
                            }
                            final double value = touchedSpot.y; // Y value at the touched point
                            final double xVal = touchedSpot.x;
                            final Color? color = touchedSpot.bar.color;
                            debugPrint('xVal: $xVal, value: $value, weekLabel: $weekLabel');
                            // Use post-frame callback to ensure state/UI updates occur after the touch event
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              alterHeadingBar(value, weekLabel, color ?? Colors.blue); // Trigger your heading update function
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
                            interval: spots.isNotEmpty ? calculateInterval(
                              spots.values.expand((spots) => spots).map(
                                (spot) {
                                    double spotVal = spot.x;
                                    if (scaleSetting ==  ScaleSetting.scaled) {
                                      spotVal -= DateTime.parse(dates.first.split(' ')[0]).millisecondsSinceEpoch.toDouble();
                                    }
                                    return spotVal;
                                }
                              ).reduce(max),
                              5
                            ) : 9999,
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              return SideTitleWidget(
                                axisSide: AxisSide.bottom,
                                child: Text(
                                  spots.isNotEmpty ? getDateValue(dates, value) : '',
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
                if (!isBodyWeight)
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
                      int orderPos = exercisesOrder.indexOf(exercise);
                      return exerciseTile(exercise, orderPos != -1 ? orderPos : 0, spots.isNotEmpty ? numParsething(findGradient(spots[exercise] ?? [])) : 0, isBodyWeight);
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
    // String getGradientData(List<FlSpot> points){
    //   FlSpot a = points[0];
    //   FlSpot b = points[points.length-1];

    //   double gradient = (a.y-b.y)/(0-points.length);
    //   return gradient.toStringAsFixed(2);
    // }

}

class BodyHeatMap extends StatefulWidget {
  final String assetPath;
  final double width;
  final List exercises;
  final Map muscleMap;

  const BodyHeatMap({
    super.key,
    required this.assetPath,
    this.width = 500, 
    required this.exercises, 
    required this.muscleMap,
  });

  @override
  BodyHeatMapState createState() => BodyHeatMapState();
}

class BodyHeatMapState extends State<BodyHeatMap> {
  String? modifiedSvgString;

  @override
  void initState() {
    super.initState();
    _loadAndModifySvg();
  }

  Future<void> _loadAndModifySvg() async {
    try {
      Map<String, List<dynamic>> musclesMap = {};

      for (MapEntry muscle in widget.muscleMap.entries){
        musclesMap[muscle.key] = [muscle.value/100, Colors.red];
      }
      musclesMap['Body'] = [1.0, Colors.grey];
      String modifiedSvg = await modifySvgPaths(widget.assetPath, musclesMap);
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
      _interpolate(startColor.redVal, endColor.redVal, t),
      _interpolate(startColor.greenVal, endColor.greenVal, t),
      _interpolate(startColor.blueVal, endColor.blueVal, t),
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

class InfoBody extends ConsumerStatefulWidget {
  final List<String> exercises;
  const InfoBody({super.key, required this.exercises});
  @override
  // ignore: library_private_types_in_public_api
  _InfoBodyState createState() => _InfoBodyState();
}

class _InfoBodyState extends ConsumerState<InfoBody> {
  late Future<Map> musclePercentages;
  @override
  initState(){
    super.initState();
    musclePercentages = getMusclePercentages();
  }
  Future<Map> getMusclePercentages() async {
    Map primaryMuscles = {};
    Map secondaryMuscles = {};
    final Map customExercisesData = await ref.read(customExercisesProvider.future);

    for (String exercise in widget.exercises){
      bool isCustom = customExercisesData.containsKey(exercise);
      Map exerciseData = {};

      if (isCustom && customExercisesData.containsKey(exercise)){
        exerciseData = customExercisesData[exercise];
      } else {
        exerciseData = exerciseMuscles[exercise] ?? {};
      }

      if (exerciseData.isEmpty) continue;

      for (String muscle in exerciseData['Primary'].keys){
        primaryMuscles[muscle] = (primaryMuscles[muscle] ?? 0) + exerciseData['Primary'][muscle];
      }     
      for (String muscle in exerciseData['Secondary'].keys){
        secondaryMuscles[muscle] = (secondaryMuscles[muscle] ?? 0) + exerciseData['Secondary'][muscle];
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
    return {
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles
    };
  }
  Map scaleMapTo(Map map, num targetSum) {
    num currentSum = map.values.reduce((a, b) => a + b);
    num scaleFactor = targetSum / currentSum;
    return map.map((k, v) => MapEntry(k, double.parse((v * scaleFactor).toStringAsFixed(2))));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
    future: musclePercentages,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error loading data'));
      } else if (snapshot.hasData) {
        Map secondaryMuscles = snapshot.data!['secondaryMuscles'];
        Map primaryMuscles = snapshot.data!['primaryMuscles'];
        return Column(
      children: [
        BodyHeatMap(
          assetPath: 'assets/Muscle_heatmap.svg', 
          exercises: widget.exercises, 
          muscleMap: {
            ...primaryMuscles,
            ...secondaryMuscles
          },
        ),
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
      } else {
        return const Center(child: Text('No data available'));
      }
    },
    );
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

      for (String exercise in data[day]['sets'].keys) { // TODO add validation rq
        if (targets.contains(exercise)) {

          startDate ??= dayDate;
          for (Map set in data[day]['sets'][exercise]) {
            set = {
              'weight': double.parse(set['weight'].toString()),
              'reps': double.parse(set['reps'].toString()),
              'type': set['type'],
              'date': day,
              'volume': double.parse(set['reps'].toString()).abs() * double.parse(set['weight'].toString()).abs(),
              'exercise': exercise,
              'x-value': dayDate.millisecondsSinceEpoch,
            };
            dayHeaviestWeight[exercise] ??= set;
            if (set['weight'] > dayHeaviestWeight[exercise]?['weight'] 
              || (set['weight'] == dayHeaviestWeight[exercise]?['weight'] && set['reps'] > dayHeaviestWeight[exercise]?['reps'])
            ) {
              dayHeaviestWeight[exercise] = set;
            }

            dayHeaviestVolume[exercise] ??= set;
            if (set['volume'] > dayHeaviestVolume[exercise]?['volume']) {
              dayHeaviestVolume[exercise] = set;
            }
          }
          if (dayHeaviestWeight[exercise]?.isNotEmpty ?? false) {
            targetData.add(dayHeaviestWeight[exercise]);
          }
          heaviestWeight[exercise] ??= dayHeaviestWeight[exercise];
          if (dayHeaviestWeight[exercise]?['weight'] > heaviestWeight[exercise]?['weight'] 
            || (dayHeaviestWeight[exercise]?['weight'] == heaviestWeight[exercise]?['weight'] && dayHeaviestWeight[exercise]?['reps'] > heaviestWeight[exercise]?['reps'])
          ) {
            heaviestWeight[exercise] = dayHeaviestWeight[exercise];
          }

          heaviestVolume[exercise] ??= dayHeaviestVolume[exercise];
          if (dayHeaviestVolume[exercise]?['volume'] > heaviestVolume[exercise]?['volume']) {
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

Future<ScaleSetting?> showSettingToggleDialog(
  BuildContext context,
  ScaleSetting currentValue,
) {
  ScaleSetting selectedValue = currentValue;

  return showDialog<ScaleSetting>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Scale Setting'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return IntrinsicHeight(
              child: RadioGroup<ScaleSetting>(
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Time Scaled',
                          textAlign: TextAlign.center,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedValue = ScaleSetting.scaled;
                            });
                          },
                          child: Radio<ScaleSetting>(
                            value: ScaleSetting.scaled,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Linear',
                            textAlign: TextAlign.center,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedValue = ScaleSetting.equalIntervals;
                              });
                            },
                            child: Radio<ScaleSetting>(
                              value: ScaleSetting.equalIntervals,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(selectedValue),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

class ExerciseHistory extends ConsumerStatefulWidget {
  final List<String> targetExercises;
  const ExerciseHistory({super.key, required this.targetExercises});
  @override
  // ignore: library_private_types_in_public_api
  _ExerciseHistoryState createState() => _ExerciseHistoryState();
}

class _ExerciseHistoryState extends ConsumerState<ExerciseHistory> {
  late Future<Map<String, Map>> exerciseHistory;
  Map<String, bool> assetExists = {}; // cache for asset existence
  late Future<Map> futureData;

  @override
  initState(){
    super.initState();
    exerciseHistory = populateExerciseHistory();
    checkAssets();
    futureData = readData();
  }
  void checkAssets() async {  // combine with the other one in choose exercises to make one single more dynamic function
    for (String exercise in widget.targetExercises) {
      String filePath = "assets/Exercises/$exercise.png";
      bool exists = await fileExists(filePath);
      assetExists[exercise] = exists;
      if (mounted){
        precacheImage(AssetImage("assets/Exercises/$exercise.png"), context);    
        setState(() {}); // Trigger rebuild after checking asset TODO optomise?
      }
    }
  }
  Future<Map<String, Map>> populateExerciseHistory() async {
    Map<String, Map> history = {};
    final Map customExercisesData = await ref.read(customExercisesProvider.future);
    Map data = await futureData;
    for (String day in data.keys.toList().reversed) {
      for (String exercise in data[day]['sets'].keys){
        if (widget.targetExercises.contains(exercise)){
          history[day] ??= {};
          history[day]!['stats'] ??= data[day]['stats'];
          history[day]!['data'] ??= [];

          bool isCustom = customExercisesData.containsKey(exercise);
        
          ExerciseHistoryNode model = ExerciseHistoryNode(
            name: exercise, 
            sets: data[day]['sets'][exercise], 
            workoutRef: day, 
            type: isCustom ? customExercisesData[exercise]['type'] : exerciseMuscles[exercise]['type']
          );
          history[day]!['data']!.add(model);
        }
      }
    }

    return history;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: exerciseHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index){
              String day = snapshot.data!.keys.toList()[index];
              DateTime startTime = DateTime.parse(snapshot.data![day]!['stats']['startTime']);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: GestureDetector(
                      onTap: (){
                        futureData.then((data){
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => IndividualDayScreen(dayData: data[day], dayKey: day))
                          );
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        spacing: 8,
                        children: [
                          Text(
                            DateFormat('dd MMM, yyyy').format(startTime),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('h:mma').format(startTime).toLowerCase(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_forward_ios),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: snapshot.data![day]!['data']!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, j) {
                      ExerciseHistoryNode model = snapshot.data![day]!['data'][j];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                assetExists[model.name] == true
                                  ? Image.asset(
                                      "assets/Exercises/${model.name}.png",
                                      height: 50,
                                      width: 50,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: SvgPicture.asset(
                                        "assets/profile.svg",
                                        height: 35,
                                        width: 35,
                                        colorFilter: ColorFilter.mode(Colors.grey.shade900, BlendMode.srcATop),
                                      ),
                                    ),
                                Text(
                                  model.name
                                )
                              ],
                            ),
                          ),
                          Table(
                            border: const TableBorder.symmetric(inside: BorderSide.none),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: Center(
                                      child: Text('Set'),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: Center(
                                      child: Text('Weight (kg)')
                                    ),
                                  ), 
                                  if (model.type != 'Timed')
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: Center(
                                      child: Text('Reps')
                                    ),
                                  ),
                                ],
                              ),
                              for (int i = 0; i < (model.sets.length); i++)
                              TableRow(
                                decoration: BoxDecoration(color: i % 2 == 1 ? ThemeColors.bg : ThemeColors.accent),
                                children: [
                                  SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        model.sets[i]['type'] == 'Warmup'
                                            ? 'W'
                                            : model.sets[i]['type'] == 'Failure'
                                                ? 'F'
                                                : model.sets[i]['type'] == 'Dropset'
                                                  ? 'D'
                                                  : '${getNormalSetNumber(model.name, i, model.sets)}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: model.type == 'Timed' ? 
                                        SizedBox(
                                          height: 50, 
                                          child: TimerScreen() // TODO
                                        ) : model.type == 'weighted' ? 
                                        const Text(
                                          '-',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 33.5,
                                          ),
                                        ) 
                                        : Text(
                                          model.sets[i]['weight'],
                                            style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ) 
                                    ),
                                  ),
                                  if (model.type != 'Timed')
                                  SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        model.sets[i]['reps'],
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      )
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      );
                    }
                  )
                ],
              );
            },
          );

        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

}
class ExerciseHistoryNode {
  final String name;
  final List sets;
  final String workoutRef;
  final String type;
  ExerciseHistoryNode({required this.name, required this.sets, required this.workoutRef, required this.type});
}