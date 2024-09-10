import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: const CalendarWidget(),
    );
  }
}

AppBar appBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Text(
      'Profile',
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
  );
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  List<DateTime> highlightedDays = [];
  Map exerciseData = {};
  @override
  void initState() {
    super.initState();
    _loadHighlightedDays();
  }
  Future<void> _loadHighlightedDays() async {
    var data = await readData();
    
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        exerciseData = data;
        highlightedDays = data.keys.map((x) => DateTime.parse(x.split(' ')[0])).toList();
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      if (exerciseData.isNotEmpty) 
        StreakRestRow(exerciseData: exerciseData), // Render only when exerciseData is not empty
      Expanded(
        child: PagedVerticalCalendar(
          minDate: DateTime(2024, 1, 1), // start date
          maxDate: DateTime(2024, 12, 31), // year from now
          dayBuilder: (context, date) {
            bool isHighlighted = highlightedDays.any((highlightedDay) =>
                date.year == highlightedDay.year &&
                date.month == highlightedDay.month &&
                date.day == highlightedDay.day);

            return GestureDetector(
              onTap: () {
                if (highlightedDays.any((highlightedDay) =>
                    date.year == highlightedDay.year &&
                    date.month == highlightedDay.month &&
                    date.day == highlightedDay.day)) 
                  {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayScreen(
                          date: date,
                          day: combineDays(exerciseData)[DateFormat('yyyy-MM-dd').format(date)]['sets'],
                    ),
                  )
                  );
                }
              },
              child: Transform.scale(
                scale: 0.8,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isHighlighted ? Colors.blue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                          color: isHighlighted ? Colors.white : Colors.black,
                          fontSize: 19),
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

}

class StreakRestRow extends StatefulWidget {
  final Map exerciseData;

  const StreakRestRow({super.key, required this.exerciseData});

  @override
  _StreakRestRowState createState() => _StreakRestRowState();
}

class _StreakRestRowState extends State<StreakRestRow> {
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
    var rest = DateTime.now().difference(DateTime.parse(widget.exerciseData.keys.toList()[0].split(' ')[0])).inDays;
    int streaks = 0;
    int week = weekNumber(DateTime.now());
    for (var day in widget.exerciseData.keys) {
      debugPrint(day);
      int weekNum = weekNumber(DateTime.parse(day.split(' ')[0]));
      debugPrint('${week - weekNum}  $week  $weekNum');
      if (week - weekNum == 1) {
        streaks++;
        week = weekNum;
      } else if (week - weekNum == 0){
        continue;
      }else {
        break;
      }
    }
    return [streaks, rest];
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
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
            color: color.withOpacity(0.1),
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


class DayScreen extends StatelessWidget {
  final DateTime date;
  final Map day;
  const DayScreen({super.key, required this.date, required this.day});

  @override
build(BuildContext context) {
  debugPrint(day.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout for ${date.day}/${date.month}/${date.year}'),
              actions: [
        Center(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              switch(value){
                case 'Edit':
                  debugPrint('edit');
                case 'Share':
                case 'Delete':
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                const PopupMenuItem(value: 'Share', child: Text('Share')),                        
                const PopupMenuItem(value: 'Delete', child: Text('Delete')),
              ];
            },
            elevation: 2, // Adjust the shadow depth here (default is 8.0)
            icon: Icon(Icons.more_vert),
          ),
        )
      ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                itemCount: day.keys.length,
                itemBuilder: (context, index) {
                  String exercise = day.keys.toList()[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
                    children: [
                      Text(exercise),
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Set'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Weight'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Reps'),
                              ),
                            ],
                          ),
                          for (int i = 0; i < (day[exercise]?.length ?? 0); i++)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // _showSetTypeMenu(exercise, i);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 16), // Adjust vertical padding to increase hitbox
                                    child: Text(
                                      day[exercise]![i]['type'] == 'Warmup'
                                          ? 'W'
                                          : day[exercise]![i]['type'] == 'Failure'
                                              ? 'F'
                                              : '${_getNormalSetNumber(day, exercise, i)}', // Display correct set number
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: day[exercise]![i]['weight'].toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle( // Add this property
                                    fontSize: 20,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '',//getPrevious(exercise, i+1, 'Weight'),
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    )
                                    
                                  ),
                                  onChanged: (value) {
                                    // sets[exercise]![i]['weight'] = int.tryParse(value) ?? '';
                                    // updateExercises();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: day[exercise]![i]['reps'].toString(),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle( // Add this property
                                    fontSize: 20,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '',//getPrevious(exercise, i+1, 'Reps')
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    )
                                  ),
                                  onChanged: (value) {
                                    // sets[exercise]![i]['reps'] = int.tryParse(value) ?? '';  // Safely convert String to int;
                                    // updateExercises();
                                  },
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         sets[exercise]!.add(
                      //           {'type': 'Normal', 'weight': 0, 'reps': 0},
                      //         );
                      //       });
                      //     },
                      //     child: const Text('Add Set'),
                      //   ),
                      // )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _getNormalSetNumber(var day, String exercise, int currentIndex) {
    int normalSetCount = 0;
    
    for (int j = 0; j <= currentIndex; j++) {
      if (day[exercise]![j]['type'] != 'Warmup') {
        normalSetCount++;
      }
    }     

    return normalSetCount;
  }

Map combineDays(Map data) {
  Map combinedData = {};

  data.forEach((key, value) {
    // Extract the date part by splitting and taking the first part (ignoring the number)
    String date = key.split(' ')[0];

    // If this date already exists in combinedData, merge the 'sets'
    if (combinedData.containsKey(date)) {
      value['sets'].forEach((exercise, sets) {
        // Check if the exercise already exists
        if (combinedData[date]['sets'].containsKey(exercise)) {
          // Create a copy of the existing list to avoid concurrent modification
          List updatedSets = List.from(combinedData[date]['sets'][exercise]);
          updatedSets.addAll(sets);
          combinedData[date]['sets'][exercise] = updatedSets;
        } else {
          // If the exercise doesn't exist, just add the new sets
          combinedData[date]['sets'][exercise] = List.from(sets);
        }
      });
    } else {
      // If the date doesn't exist, just add the entry
      combinedData[date] = {
        'stats': value['stats'],
        'sets': Map.from(value['sets'])  // Copy the sets to avoid reference issues
      };
    }
  });

  return combinedData;
}

