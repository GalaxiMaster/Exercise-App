import 'dart:math';
import 'package:exercise_app/Pages/calendar.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/StatScreens/muscle_data.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Pages/StatScreens/stats.dart';
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
  String prevSelector = 'sessions';
  num? selectedBarValue; // TODO set to what it actually is
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
    DateTime te = DateFormat('yyyy MMM dd').parse(week);
    var test = DateTime.now().difference(te).inDays;
    int distanceInWeeks = (test / 7).ceil()-1;
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
      case 'sets': unit = 'sets';

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
            return Center(child: Text('Error loading data ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data![0][graphSelector]; // Extract data
            final goal = double.tryParse(snapshot.data![1]['Day Goal'].toString()) ?? 1.0; // Extract goal
            selectedBarValue ??= numParsething(data.values.toList()[data.values.toList().length-1]);
            if (prevSelector != graphSelector){
              prevSelector = graphSelector;
              selectedBarValue = numParsething(data.values.toList()[data.values.toList().length-1]);
              selectedBarWeekDistance = 'This week';
            }
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
                            '$selectedBarValue $unit',
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
                      selectorBox('Sets', graphSelector == 'sets'),
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
                            destination = CalenderScreen();
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
                              color: Colors.blueAccent.withValues(alpha: 0.9),
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
            case 'Sets': graphSelector = 'sets';
          }

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

num numParsething(num number){
  return number % 1 == 0 ? number.truncate() : double.parse(number.toStringAsFixed(2));
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
    switch (selector){
      case 'sessions': unit = 'days';
      case 'duration': unit = 'h';
      case 'volume': unit = 'kg';
      case 'weight': unit = 'kg';
      case 'reps': unit = 'reps';
      case 'sets': unit = 'sets';
    }
    final double maxValue = data.values.cast<num>().reduce(max).toDouble();

    final double chartMaxY = max(maxValue, goal) <= 7 ? 7 : autoRoundUp(max(maxValue, goal));

    double interval = selector == 'sessions' ? 1 : chartMaxY / 7;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: chartMaxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} $unit',
                    const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
              touchCallback: (event, response) {
                if (event is FlTapUpEvent && response?.spot != null) {
                  final index = response!.spot!.touchedBarGroupIndex;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    alterHeadingBar(
                      response.spot!.touchedRodData.toY,
                      data.keys.toList()[index],
                    );
                  });
                }
              },
            ),

            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: interval * (selector == 'sessions' ? 1 : 2.5),
                  reservedSize: 50,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // if (value % 1 != 0) return const SizedBox.shrink();
                    if (![0, 3, 7].contains(value) && selector == 'sessions') {
                      return const SizedBox.shrink();
                    }
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
                  reservedSize: 38,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.keys.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        angle: -0.3,
                        child: Text( 
                          data.keys.toList()[index].split(' ').sublist(1, 3).join(' '),
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),

            gridData: FlGridData(
              show: true,
              horizontalInterval: interval,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),

            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (selector == 'sessions')
                  HorizontalLine(
                    y: goal,
                    color: Colors.redAccent,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 5),
                      labelResolver: (_) => 'Goal (${goal.toStringAsFixed(0)})',
                    ),
                  ),
              ],
            ),

            barGroups: List.generate(
              data.length,
              (index) {
                final key = data.keys.toList()[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data[key].toDouble(),
                      width: 20,
                      color: Colors.blue,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
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
      String day = DateFormat('yyyy MMM dd').format(monday);
      weeks[day] = 0;
    }


    Map information = {
      'sessions': getWeekData(data, Map.from(weeks)),
      'duration': getDurationData(data, Map.from(weeks)),
      'volume': getWeightAndStufftData(data, Map.from(weeks), 'volume'),
      'weight':getWeightAndStufftData(data, Map.from(weeks), 'weight'),
      'reps': getWeightAndStufftData(data, Map.from(weeks), 'reps'),
      'sets': getWeightAndStufftData(data, Map.from(weeks), 'sets'),
    };
    return information;
  }

  Map getWeekData(Map data, Map weeks){
    // Process data
    for (var day in data.keys) {
      DateTime monday = findMonday(DateTime.parse(day.split(' ')[0])); // Get the Monday of that week
      String formattedDate = DateFormat('yyyy MMM dd').format(monday);

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

  Map getWeightAndStufftData(Map data, Map weeks, String selector){
    for (var day in data.keys) {
      DateTime monday = findMonday(DateTime.parse(day.split(' ')[0])); // Get the Monday of that week
      String formattedDate = DateFormat('yyyy MMM dd').format(monday);
      // Only process if the Monday is within the last 8 weeks
      if (weeks.keys.contains(formattedDate)) {
        double dayWeight = 0;
        for (String exercise in data[day]['sets'].keys){
          for (Map set in data[day]['sets'][exercise]){
            if (selector == 'volume'){
              dayWeight += (double.parse(set['weight'].toString()) * double.parse(set['reps'].toString()));
            }else if (selector == 'sets'){
              dayWeight++;
            } else{
              dayWeight += double.parse(set[selector].toString());
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
      String formattedDate = DateFormat('yyyy MMM dd').format(monday);

      // Only process if the Monday is within the last 8 weeks
      if (weeks.keys.contains(formattedDate)) {
        Duration difference = DateTime.parse(data[day]['stats']['endTime']).difference(DateTime.parse(data[day]['stats']['startTime'])); // Calculate the difference
        double hours = difference.inMinutes.toDouble() / 60;
        weeks[formattedDate] = (weeks[formattedDate] ?? 0) + hours;
      }
    }

    return Map.fromEntries(weeks.entries.toList().reversed);
  }