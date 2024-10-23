import 'dart:math';
import 'package:exercise_app/Pages/calendar.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/muscle_data.dart';
import 'package:exercise_app/Pages/radar_chart.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Pages/stats.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<List<dynamic>> _futureData;
  String graphSelector = 'sessions';
  num? selectedBarValue = 1; // set to 
  String selectedBarWeekDistance = 'This week';
  String unit = 'days';
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = Future.wait([getData(), getAllSettings()]);
  }
  void alterHeadingBar(double value, String week){
    DateTime te = DateFormat('yyyy MMM dd').parse('2024 $week');
    var test = DateTime.now().difference(te).inDays;
    int distanceInWeeks = (test / 7).ceil();
    setState(() {
      selectedBarValue = numParsething(value);
      selectedBarWeekDistance = distanceInWeeks == 0 ? 'This week' : '$distanceInWeeks weeks ago';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = ['Calender', 'Exercises', 'Muscles', 'Stats'];
    switch (graphSelector){
      case 'sessions': unit = 'days';
      case 'duration': unit = 'h';
      case 'volume': unit = 'kg';
      case 'weight': unit = 'kg';
      case 'reps': unit = 'reps';
    }
    return Scaffold(
      appBar: myAppBar(context, 'Profile', 
        button: MyIconButton(
          icon: Icons.settings,
          width: 37,
          height: 37,
          borderRadius: 10,
          iconHeight: 20,
          iconWidth: 20,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            ).then((value) {
              setState(() { //TODO could possibly make it only reload if the settings is different
                _loadData();
              });
            });
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.hasData) {
            final data = snapshot.data![0][graphSelector]; // Extract data
            final goal = double.tryParse(snapshot.data![1]['Day Goal'].toString()) ?? 1.0; // Extract goal
            selectedBarValue ??= numParsething(data.values.toList()[data.values.toList().length-1]);
            return Column(
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
                            '${selectedBarValue} $unit',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              selectedBarWeekDistance,
                              style: const TextStyle(
                                color: Colors.grey,
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
                DataBarChart(data: data, goal: goal, selector: graphSelector, alterHeadingBar: alterHeadingBar,), // Pass the goal to DataBarChart
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      selectorBox('Sessions', graphSelector == 'sessions'),
                      selectorBox('Duration', graphSelector == 'duration'),
                      selectorBox('Volume', graphSelector == 'volume'),
                      selectorBox('Weight', graphSelector == 'weight'),
                      selectorBox('Reps', graphSelector == 'reps'),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2, // Adjust to fit your needs
                    ),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // Remove padding around the GridView
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Widget destination;
                          if (index == 0) {
                            destination = const CalenderScreen();
                          } else if (index == 1) {
                            destination = const WorkoutList(setting: 'info',);
                          } else if (index == 2) {
                            destination = const MuscleData();
                          } else {
                            destination = const Stats();
                          }
                  
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => destination)
                          ).then((value) {
                            // Reload the data when coming back from another page
                            setState(() {
                              _loadData();
                            });
                          });
                        },
                        child: Center(
                          child: Container(
                            width: 190,
                            padding: const EdgeInsets.all(8.0),
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.9),
                              border: Border.all(
                                // color: Colors.blueAccent.withOpacity(0.6),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  messages[index],
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
  Widget selectorBox(String text, bool selected){
    return GestureDetector(
      onTap: () async{
        setState(() {
          switch(text){
            case 'Sessions': graphSelector = 'sessions';
            case 'Duration': graphSelector = 'duration';
            case 'Weight': graphSelector = 'weight';
            case 'Volume': graphSelector = 'volume';
            case 'Reps': graphSelector = 'reps';
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : HexColor.fromHex('151515'),
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

num numParsething(var number){
  return number % 1 == 0 ? number.truncate() : number;
}

class DataBarChart extends StatelessWidget {
  final Map data;
  final double goal; // Add this to set the goal
  final String selector;
  final Function alterHeadingBar;
  
  const DataBarChart({
    super.key,
    required this.data,
    required this.goal, 
    required this.selector, 
    required this.alterHeadingBar,
  });
  
  @override
  Widget build(BuildContext context) {
    String unit = 'days';
    debugPrint(data.toString());
    switch (selector){
      case 'sessions': unit = 'days';
      case 'duration': unit = 'h';
      case 'volume': unit = 'kg';
      case 'weight': unit = 'kg';
      case 'reps': unit = 'reps';
    }

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: data.values.cast<num>().toList().reduce(max).toDouble() < 7 ? 7 : autoRoundUp(data.values.cast<num>().toList().reduce(max).toDouble()), // Ensure maxY is above your goal
            barTouchData: BarTouchData(
              touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
                if (event is FlTapUpEvent && touchResponse != null && touchResponse.spot != null) {
                  final int index = touchResponse.spot!.touchedBarGroupIndex;
                  final String weekLabel = data.keys.toList()[index];
                  final double value = touchResponse.spot!.touchedRodData.toY;
                  
                  // Use a post-frame callback to update the state
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    alterHeadingBar(value, weekLabel);
                  });
                }
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Remove top numbers
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Remove right numbers
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 50000,
                  reservedSize: 50,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${value.toInt()} $unit',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.keys.length) {
                      return Text(
                        data.keys.toList()[index], // Correctly show each week's label
                        style: const TextStyle(fontSize: 12),
                      );
                    }
                    return const Text('', style: TextStyle(fontSize: 12));
                  },
                  reservedSize: 38,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
              ),
            ),
            gridData: FlGridData(
              show: false,
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                if (value == goal) {
                  return const FlLine(
                    color: Colors.red, // Goal line color
                    strokeWidth: 2,
                    dashArray: [5, 5], // Optional: dashed line
                  );
                }
                return const FlLine(
                  color: Colors.grey, // Other grid lines color
                  strokeWidth: 0.5,
                );
              },
              // No need for `showVerticalLine`
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (selector == 'sessions')
                HorizontalLine(
                  y: goal,
                  color: Colors.red, // Color of the goal line
                  strokeWidth: 2,
                  dashArray: [5, 5], // Optional: dashed line
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (line) => 'Goal (${goal.toStringAsFixed(0)})', // Label for the goal line
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 5),
                  ),
                ),
              ],
            ),
            barGroups: List.generate(
              data.length,
              (index) {
                String key = data.keys.toList()[index];
                return BarChartGroupData(
                  x: index, // Assign a unique x value for each bar
                  barRods: [
                    BarChartRodData(
                      toY: double.parse(data[key].toString()), // Set bar height based on value
                      color: Colors.blue,
                      width: 20,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

  Future<Map> getData() async {
    Map data = await readData();
    Map weeks = {};

    // Preload the last 8 Mondays
    DateTime today = DateTime.now();
    DateTime currentMonday = findMonday(today);

    for (int i = 0; i < 7; i++) {
      DateTime monday = currentMonday.subtract(Duration(days: 7 * i));
      String day = DateFormat('MMM dd').format(monday);
      weeks[day] = 0;
    }


    Map information = {
      'sessions': getWeekData(data, Map.from(weeks)),
      'duration': getDurationData(data, Map.from(weeks)),
      'volume': getWeigtAndStufftData(data, Map.from(weeks), 'volume'),
      'weight':getWeigtAndStufftData(data, Map.from(weeks), 'weight'),
      'reps':getWeigtAndStufftData(data, Map.from(weeks), 'reps')
    };
    return information;
  }

  Map getWeekData(Map data, Map weeks){
    // Process data
    for (var day in data.keys) {
      DateTime monday = findMonday(DateTime.parse(day.split(' ')[0])); // Get the Monday of that week
      String formattedDate = DateFormat('MMM dd').format(monday);

      // Only process if the Monday is within the last 8 weeks
      if (weeks.keys.contains(formattedDate)) {
        weeks[formattedDate] = (weeks[formattedDate] ?? 0) + 1;
      }
    }

    return Map.fromEntries(weeks.entries.toList().reversed);
  }

  DateTime findMonday(DateTime date) {
    int daysToSubtract = (date.weekday - DateTime.monday) % 7;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Map getWeigtAndStufftData(Map data, Map weeks, String selector){

    for (var day in data.keys) {
      DateTime monday = findMonday(DateTime.parse(day.split(' ')[0])); // Get the Monday of that week
      String formattedDate = DateFormat('MMM dd').format(monday);
      // Only process if the Monday is within the last 8 weeks
      if (weeks.keys.contains(formattedDate)) {
        double dayWeight = 0;
        for (String exercise in data[day]['sets'].keys){
          for (Map set in data[day]['sets'][exercise]){
            if (selector == 'volume'){
              dayWeight += (double.parse(set['weight']) * double.parse(set['reps']));
            }else{
              dayWeight += double.parse(set[selector]);
            }
          }
        }
        weeks[formattedDate] = (weeks[formattedDate] ?? 0) + double.parse(dayWeight.toStringAsFixed(2));
      }

    }
    return Map.fromEntries(weeks.entries.toList().reversed);
  }

    Map getDurationData(Map data, Map weeks){
    // Process data
    for (var day in data.keys) {
      DateTime monday = findMonday(DateTime.parse(day.split(' ')[0])); // Get the Monday of that week
      String formattedDate = DateFormat('MMM dd').format(monday);

      // Only process if the Monday is within the last 8 weeks
      if (weeks.keys.contains(formattedDate)) {
        Duration difference = DateTime.parse(data[day]['stats']['endTime']).difference(DateTime.parse(data[day]['stats']['startTime'])); // Calculate the difference
        double hours = difference.inMinutes.toDouble() / 60;
        weeks[formattedDate] = (weeks[formattedDate] ?? 0) + hours;
      }
    }

    return Map.fromEntries(weeks.entries.toList().reversed);
  }