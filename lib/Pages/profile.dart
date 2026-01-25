import 'dart:math';
import 'package:exercise_app/Pages/calendar.dart';
import 'package:exercise_app/Pages/choose_exercise.dart';
import 'package:exercise_app/Pages/StatScreens/muscle_data.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Pages/StatScreens/stats.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/utils.dart';
import 'package:exercise_app/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  String graphSelector = 'sessions';
  String prevSelector = 'sessions';
  num? selectedBarValue; // TODO set to what it actually is
  String selectedBarWeekDistance = 'This week';
  String unit = 'days';
  late User? account;

  @override
  void initState() {
    super.initState();
    account = FirebaseAuth.instance.currentUser;
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
  final allDataProvider = Provider<AsyncValue<Map<String, Map>>>((ref) {
    // 1. Listen to the dependencies. 
    // Using 'watch' ensures this provider recalculates when data changes.
    final workoutAsyncValue = ref.watch(workoutDataProvider);

    // 2. Handle the AsyncValue of the workout provider
    return workoutAsyncValue.whenData((data) {
        Map weeks = {};

        // Preload the last 8 Mondays
        DateTime today = DateTime.now();
        DateTime currentMonday = findMonday(today);

        for (int i = 0; i < 7; i++) {
          DateTime monday = currentMonday.subtract(Duration(days: 7 * i));
          String day = DateFormat('yyyy MMM dd').format(monday);
          weeks[day] = 0;
        }

        Map<String, Map> information = {
          'sessions': getWeekData(data, Map.from(weeks)),
          'duration': getDurationData(data, Map.from(weeks)),
          'volume': getWeightAndStufftData(data, Map.from(weeks), 'volume'),
          'weight':getWeightAndStufftData(data, Map.from(weeks), 'weight'),
          'reps': getWeightAndStufftData(data, Map.from(weeks), 'reps'),
          'sets': getWeightAndStufftData(data, Map.from(weeks), 'sets'),
        };
        return information;
      },
    );
  });
  
  final TextStyle quickStatStyle = TextStyle(
    fontSize: 16
  );
  @override
  Widget build(BuildContext context) {
    List<ButtonDetails> buttonDetails = [
      ButtonDetails(
        title: 'Calendar', icon: Icons.calendar_month, destination: const CalenderScreen()),
      ButtonDetails(
        title: 'Exercises', icon: Icons.sports_gymnastics, destination: const WorkoutList(setting: 'info',)),
      ButtonDetails(
        title: 'Muscles', icon: Icons.fitness_center, destination: MuscleData()),
      ButtonDetails(
        title: 'Stats', icon: Icons.bar_chart, destination: const Stats()),
    ];

    switch (graphSelector){
      case 'sessions': unit = 'days';
      case 'duration': unit = 'h';
      case 'volume': unit = 'kg';
      case 'weight': unit = 'kg';
      case 'reps': unit = 'reps';
      case 'sets': unit = 'sets';

    }
    
    final allDataAsync = ref.watch(allDataProvider);

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
            );
          },
        ),
      ),
      body: Column(
        children: [
          if (account != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CircleAvatar(
                  radius: 35,
                  foregroundImage: account!.photoURL != null 
                    ? NetworkImage(account!.photoURL!) 
                    : null,
                  backgroundColor: Colors.blue[700],
                  child: Text(
                    (account!.email?.substring(0, 1).toUpperCase() ?? 'U'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          account!.displayName ?? '',
                          style: TextStyle(
                            fontSize: 20
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: quickStatStyle,
                              children: [
                                TextSpan(
                                  text: ref.watch(workoutDataProvider.notifier).sessions.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                TextSpan(
                                  text: ' Sessions',
                                  style: TextStyle(
                                    fontSize: 14
                                  )
                                )
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: quickStatStyle,
                              children: [
                                TextSpan(
                                  text: ref.watch(workoutDataProvider.notifier).streak.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                TextSpan(
                                  text: ' Week Streak',
                                  style: TextStyle(
                                    fontSize: 13
                                  )
                                )
                              ]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Column(
            children: [
              allDataAsync.when(
                data: (rData){
                  final Map settings = ref.watch(settingsProvider).value ?? {};
                  final Map? data = rData[graphSelector]; // Extract data
                  final goal = double.tryParse(settings['Day Goal'].toString()) ?? 1.0; // Extract goal
                  selectedBarValue ??= numParsething(data?.values.toList().last ?? 0);
                  if (prevSelector != graphSelector){
                    prevSelector = graphSelector;
                    selectedBarValue = numParsething(data?.values.toList().last ?? 0);
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
                            ),
                          ],
                        ),
                      ),
                      DataBarChart(data: data ?? {}, goal: goal, selector: graphSelector, alterHeadingBar: alterHeadingBar,), // Pass the goal to DataBarChart
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
                    ],
                  );
                }, 
                error: (error, stack) => Text('Error fetching data $error'), 
                loading: () => CircularProgressIndicator()
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.5, // Adjust to fit your needs
                    ),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // Remove padding around the GridView
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      ButtonDetails button = buttonDetails[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => button.destination)
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              // color: Colors.blueAccent.withValues(alpha: 0.8),
                              color: Color.fromARGB(255, 21, 21, 21),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              spacing: 10,
                              children: [
                                SizedBox(width: 15),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(button.icon),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      button.title,
                                      style: const TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.5),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      )
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

num numParsething(num? number){
  return number == null ? 0 : (number % 1 == 0 ? number.truncate() : double.parse(number.toStringAsFixed(2)));
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