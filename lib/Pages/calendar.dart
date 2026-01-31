import 'dart:math';

import 'package:exercise_app/Pages/SettingsPages/calendar_settings.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Pages/day_screen.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalenderScreen extends ConsumerStatefulWidget {
  const CalenderScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends ConsumerState<CalenderScreen> {
  MapEntry selection = MapEntry('Month', 'month');

  List<DateTime> highlightedDays = [];
  Map exerciseData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final workoutAsync = ref.watch(workoutDataProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextButton.icon(
          onPressed: () async {
            final MapEntry? newCal = await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SelectorPopupMap(options: {'Month': 'month', 'Year': 'year', 'Multi Year': 'multiYear'});
              },
            );
            if (newCal != null){
              setState(() {
                selection = newCal;
              });
            }
          },
          label: Text(
            selection.key,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white,),
          iconAlignment: IconAlignment.end, 
        ),
        actions: [
          if (selection.value == 'multiYear')
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarSettings())
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: settingsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (settings) {
          return workoutAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (workoutData) {
              final highlightedDays = workoutData.keys
                  .map((x) => DateTime.parse(x.split(' ')[0]))
                  .toList();

              return switch (selection.value) {
                'month' => CalendarWidget(
                    highlightedDays: highlightedDays,
                    exerciseData: workoutData,
                  ),
                'year' => buildMonthCalendar(highlightedDays),
                'multiYear' => MultiYearCalendar(
                    activeDates: highlightedDays,
                    settings: settings['CalendarSettings']['MultiYear'],
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          );
        },
      )
    );
  }
}

class CalendarWidget extends ConsumerStatefulWidget {
  final List<DateTime> highlightedDays;
  final Map exerciseData;

  const CalendarWidget({super.key, required this.highlightedDays, required this.exerciseData});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends ConsumerState<CalendarWidget> {

  @override
  Widget build(BuildContext context) {
    DateTime firstTime = DateTime.now().subtract(Duration(days: 365));
    if (widget.exerciseData.keys.isNotEmpty){
      firstTime = DateTime.parse(widget.exerciseData.keys.toList()[0].split(' ')[0]).subtract(const Duration(days: 31));
    }
    return Column(
      children: [
        if (widget.exerciseData.isNotEmpty) 
        StreakRestRow(exerciseData: widget.exerciseData),
        Expanded(
          child: PagedVerticalCalendar(
            key: ValueKey(widget.exerciseData.length),
            minDate: firstTime,
            maxDate: DateTime.now().add(const Duration(days: 31)),
            dayBuilder: (context, date) {
              bool isHighlighted = widget.highlightedDays.any((highlightedDay) =>
                  date.year == highlightedDay.year &&
                  date.month == highlightedDay.month &&
                  date.day == highlightedDay.day);
              bool isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              List<Color> highlightedColors = [];

              for (int i = 1; i < 10; i++) {
                String dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} $i';

                if (!widget.exerciseData.containsKey(dayKey)) break;

                String? hex = widget.exerciseData[dayKey]?['stats']?['color'];

                if (hex != null) {
                  highlightedColors.add(HexColor.fromHex(hex));
                } else {
                  highlightedColors.add(Colors.blue);
                }
              }

              final sweepData = generateHardSweep(highlightedColors);
              return GestureDetector(
                onTap: () {
                  if (widget.highlightedDays.any((highlightedDay) =>
                      date.year == highlightedDay.year &&
                      date.month == highlightedDay.month &&
                      date.day == highlightedDay.day)) 
                    {
                    Map<String, dynamic> daysData = {};
                    for (var day in widget.exerciseData.keys){
                      if (day.split(' ')[0] == DateFormat('yyy-MM-dd').format(date)){
                        daysData.addAll({day : widget.exerciseData[day]});
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayScreen(
                          date: date,
                          dayKeys: daysData.keys.toList(),
                        ),
                      )
                    );
                  }
                },
                child: Transform.scale(
                  scale: 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      border: isToday && !isHighlighted? Border.all(
                        color: Colors.blue,
                        width: 2,
                      ) : null,
                      gradient: SweepGradient(
                        center: Alignment.center,
                        // Rotates the start point from 3 o'clock to 12 o'clock
                        transform: const GradientRotation(-pi / 2),
                        colors: sweepData['colors'],
                        stops: sweepData['stops'],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 19,
                          color: ((highlightedColors.isNotEmpty ? highlightedColors.first : null)?.computeLuminance() ?? 0) > 0.5
                            ? Colors.black
                            : Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Map<String, dynamic> generateHardSweep(List<Color> inputColors) {
    if (inputColors.isEmpty) return {'colors': [Colors.transparent, Colors.transparent], 'stops': [0.0, 1.0]};
    if (inputColors.length == 1) return {'colors': [inputColors[0], inputColors[0]], 'stops': [0.0, 1.0]};

    List<Color> colors = [];
    List<double> stops = [];
    int count = inputColors.length;

    for (int i = 0; i < count; i++) {
      // Add the color twice to create the start and end of a segment
      colors.add(inputColors[i]);
      colors.add(inputColors[i]);

      // Calculate the stop points
      // i / count is the start of this segment, (i + 1) / count is the end
      stops.add(i / count);
      stops.add((i + 1) / count);
    }

    return {
      'colors': colors.reversed.toList(),
      'stops': stops,
    };
  }
}

class StreakRestRow extends StatefulWidget {
  final Map exerciseData;

  const StreakRestRow({super.key, required this.exerciseData});

  @override
  StreakRestRowState createState() => StreakRestRowState();
}

class StreakRestRowState extends State<StreakRestRow> {
  late List stats;

  @override
  void initState() {
    super.initState();
    stats = getStats();
  }

  @override
  void didUpdateWidget(covariant StreakRestRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseData != widget.exerciseData) {
      stats = getStats();
    }
  }

  List getStats() {
    if (widget.exerciseData.keys.isEmpty) {
      return [0, 0];
    }
    var rest = DateTime.now().difference(DateTime.parse(widget.exerciseData.keys.toList().last.split(' ')[0])).inDays;
    int streaks = 0;
    int week = weekNumber(DateTime.now());
    List<int> counted = [];
    for (final day in widget.exerciseData.keys.toList().reversed) { // todo move streaks to the provider
      final weekNum = weekNumber(DateTime.parse(day.split(' ')[0]));
      if (counted.contains(weekNum)) continue;
      counted.add(weekNum);

      if (week - weekNum <= 1) {
        streaks++;
        week = weekNum;
      } else {
        break;
      }
    }
    return [streaks, rest];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakRestBox(
            icon: Icons.local_fire_department,
            label: '${stats[0]} weeks',
            subLabel: 'Streak',
            color: Colors.orange,
          ),
          _buildStreakRestBox(
            icon: Icons.nights_stay,
            label: '${stats[1]} days',
            subLabel: 'Rest',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakRestBox({
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 150,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Text(subLabel, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildDaySquare(bool isActive, double size, {double margin = 0.75, double borderRadius = 1, Color activeColor = Colors.blue}) {
  return Container(
    width: size,
    height: size,
    margin: EdgeInsets.all(margin),
    decoration: BoxDecoration(
      color: isActive 
          ? activeColor
          : Colors.grey[900],
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

Widget buildMonthCalendar(List activeDates){
  int startYear = activeDates.isNotEmpty ? activeDates.map((d) => d.year).reduce((a, b) => a < b ? a : b) : DateTime.now().year;
  int endYear = DateTime.now().year;
  ScrollController controller = ScrollController(initialScrollOffset: (endYear - startYear) * 527.5);
  return SingleChildScrollView(
    controller: controller,
    child: ListView.builder(
      itemCount: endYear - startYear + 1,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        int year = startYear + index;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 500,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 months per row
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemCount: 12,
                itemBuilder: (context, monthIndex) {
                  List months = [
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                  ];
                  DateTime firstDay = DateTime(2025, monthIndex + 1, 1);
                  int emptyDaysBefore = firstDay.weekday - 1; // Gap before the 1st
                  int daysInMonth = DateUtils.getDaysInMonth(2025, monthIndex + 1);
                      
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        months[monthIndex], 
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Wrap(
                          children: [
                            // Spacer for the start of the month
                            for (int i = 0; i < emptyDaysBefore; i++)
                              Opacity(opacity: 0, child: buildDaySquare(false, 15)),
                            // Actual days
                            for (int i = 1; i <= daysInMonth; i++)
                              buildDaySquare(activeDates.contains(DateTime(year, monthIndex + 1, i)), 15, borderRadius: 2), // Dummy intensity logic
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }
    ),
  );
}

class MultiYearCalendar extends StatelessWidget {
  final List<DateTime> activeDates;
  final Map settings;

  const MultiYearCalendar({
    super.key,
    required this.activeDates,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Prepare data for O(1) lookup
    final Set<String> activeDateStrings = activeDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toSet();

    // 2. Accurate day/week calculation including leap years
    // By going to Jan 1st of the next year, we handle 365 vs 366 days automatically.
    int startYear = activeDates.isNotEmpty ? activeDates.map((d) => d.year).reduce((a, b) => a < b ? a : b) : DateTime.now().year;
    int endYear = activeDates.isNotEmpty ? activeDates.map((d) => d.year).reduce((a, b) => a > b ? a : b) : DateTime.now().year;
    DateTime firstDayOfYear = DateTime.utc(startYear, 1, 1);
    final firstDayOfNextYear = DateTime.utc(startYear + 1, 1, 1);
    final totalDays = firstDayOfNextYear.difference(firstDayOfYear).inDays;
    final totalWeeks = (totalDays / 7).ceil();

    const double squareSize = 6.3;
    const double spacing = .52;
    const double columnWidth = squareSize + spacing;
    const double labelHeight = 16.0; 

    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: endYear - startYear + 1,
              itemBuilder: (context, index) {
                final year = startYear + index;
                firstDayOfYear = DateTime.utc(year, 1, 1);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$year',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MONTH LABELS ROW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(totalWeeks, (weekIndex) {
                              final date = firstDayOfYear.add(Duration(days: weekIndex * 7));
                              
                              // Show label if it's the first week of the year OR the month changes
                              bool isFirstWeekOfMonth = weekIndex == 0 || 
                                  date.month != firstDayOfYear.add(Duration(days: (weekIndex - 1) * 7)).month;
                
                              return SizedBox(
                                width: columnWidth + 0.25,
                                height: labelHeight, // Giving the parent a height
                                child: isFirstWeekOfMonth
                                  ? OverflowBox(
                                      alignment: Alignment.centerLeft,
                                      maxWidth: 40,
                                      minWidth: 0,
                                      maxHeight: labelHeight, 
                                      minHeight: 0,
                                      child: Text(
                                        DateFormat('MMM').format(date),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          
                          // THE GRID
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(7, (dayIndex) {
                            // dayIndex 0 = Monday, 1 = Tuesday, etc.
                            return Row(
                              children: List.generate(53, (weekIndex) {
                                // Calculate the date for this specific weekday in this week
                                final date = firstDayOfYear.add(
                                  Duration(days: (weekIndex * 7) + dayIndex - (firstDayOfYear.weekday - 1 )),
                                );
        
                                // Skip if date is outside the current year
                                if (date.year != year && !(settings['bufferEnds'] ?? false)) {
                                  return SizedBox(width: columnWidth + spacing, height: squareSize);
                                }
        
                                bool isActive = activeDateStrings.contains(
                                  DateFormat('yyyy-MM-dd').format(date),
                                );
                                
                                final Map<String, Color> dayColorMap = {
                                  'Monday': Colors.blue,
                                  'Tuesday': Colors.green,
                                  'Wednesday': Colors.orange,
                                  'Thursday': Colors.purple,
                                  'Friday': Colors.red,
                                  'Saturday': Colors.teal,
                                  'Sunday': Colors.limeAccent,
                                };
                                
                                return Container(
                                  width: columnWidth,
                                  margin: const EdgeInsets.only(right: spacing),
                                  child: buildDaySquare(
                                    isActive, 
                                    squareSize, 
                                    activeColor: settings['MultiColor'] ?? false ? 
                                      dayColorMap[DateFormat('EEEE').format(date.toUtc())]!
                                      : Colors.blue
                                  )
                                );
                              }),
                            );
                          }),
                        ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: List.generate(totalWeeks, (weekIndex) {
//                             return SizedBox(
//                               width: columnWidth,
//                               child: Column(
//                                 children: List.generate(7, (dayIndex) {
//                                   final date = firstDayOfYear.add(
//                                     Duration(days: (weekIndex * 7) + dayIndex),
//                                   );
              
//                                   if (date.year > year) {
//                                     return const SizedBox(height: squareSize + spacing);
//                                   }
              
//                                   bool isActive = activeDateStrings.contains(
//                                     DateFormat('yyyy-MM-dd').format(date),
//                                   );
//                                   if (isActive && date.month == 4) {
//                                     debugPrint('placehokder');
//                                   }
//                                   final Map<String, Color> dayColorMap = {
//                                     'Monday': Colors.blue,
//                                     'Tuesday': Colors.green,
//                                     'Wednesday': Colors.orange,
//                                     'Thursday': Colors.purple,
//                                     'Friday': Colors.red,
//                                     'Saturday': Colors.teal,
//                                     'Sunday': Colors.brown,
//                                   };                                  
//                                   return Container(
//                                     margin: const EdgeInsets.only(bottom: spacing),
//                                     child: buildDaySquare(isActive, squareSize, activeColor: dayColorMap[DateFormat('EEEE').format(date)]!)
//                                   );
//                                 }),
//                               ),
//                             );
//                           }),
//                         ),