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
  // ignore: library_private_types_in_public_api
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
    setState(() {
      exerciseData = data;
      highlightedDays = data.keys.map((x) => DateTime.parse(x.split(' ')[0])).toList();
    });
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
                  Map daysData = {};
                  for (var day in exerciseData.keys){
                    if (day.split(' ')[0] == DateFormat('yyy-MM-dd').format(date)){
                      daysData.addAll({day : exerciseData[day]});
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DayScreen(
                          date: date,
                          dayData: daysData,
                          reload: _loadHighlightedDays,
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
  // ignore: library_private_types_in_public_api
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


class DayScreen extends StatefulWidget {
  final DateTime date;
  final Map dayData;
  final Function reload;
  const DayScreen({super.key, required this.date, required this.dayData, required this.reload});
  @override
  // ignore: library_private_types_in_public_api
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  @override
  build(BuildContext context) {
    Map dayData = widget.dayData;
    DateTime date = widget.date;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout for ${date.day}/${date.month}/${date.year}'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: dayData.keys.length,
              itemBuilder: (context, index){
                return dayBox(dayData[dayData.keys.toList()[index]]);
              }
            ),
          )
        ],
      )
    );
  }
  Widget dayBox(Map day){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(day['stats']['startTime'])),
                    style: const TextStyle(
                      fontSize: 18
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: PopupMenuButton<String>(
                    onSelected: (value) async{
                      switch(value){
                        case 'Edit':
                          debugPrint('edit');
                          // push context of add exercise screen
                        case 'Share':
                          debugPrint('share');
                          // share day
                        case 'Delete':
                          debugPrint('delete');
                          String keyToRemove = '';
                          widget.dayData.forEach((key, value) {
                            if (value == day) {
                              keyToRemove = key;
                            }
                          });                                    
                          await deleteDay(day);
                          widget.dayData.remove(keyToRemove);
                          widget.reload();
                          setState(() {});// TODO maybe include the index somewhere later                       
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
                    icon: const Icon(Icons.more_vert),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '${day['stats']['startTime'].split(' ')[1]}-${day['stats']['endTime'].split(' ')[1]}',
                style: const TextStyle(
                  fontSize: 15
                ),
              ),
            ),
            WorkoutStats(workout: day),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Text('Exercises: '),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 10, top: 5),
                  child: Text('Best set: '),
                ),
              ],
            ),
            for (int i = 0; i < (day['sets']?.length ?? 0); i++)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2.5),
                  child: Text(
                    day['sets'].keys.toList()[i]
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2.5),
                  child: Text(getBestSet(day['sets'][day['sets'].keys.toList()[i]])),
                )
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Future<bool> deleteDay(Map day) async{
    String dayKey = '';
    widget.dayData.forEach((key, value) {
      if (value == day) {
        dayKey = key;
      }
    });
    if (dayKey == ''){return false;}
    Map data = await readData();
    data.remove(dayKey);
    writeData(data, append: false);
    return true;
  }
}

class WorkoutStats extends StatelessWidget {
  final Map workout;
  const WorkoutStats({
    super.key,
    required this.workout,
  });
  List workoutData(){
    double volume = 0;
    Duration difference = DateTime.parse(workout['stats']['endTime']).difference(DateTime.parse(workout['stats']['startTime'])); // Calculate the difference
    String time = '${difference.inHours != 0 ? '${difference.inHours}h' : ''} ${difference.inMinutes.remainder(60)}m';
    int prs = 0;
    for (var exercise in workout['sets'].keys){
      for (var set in workout['sets'][exercise]){
        if (set['PR'] == 'yes'){
          prs++;
        }
        volume += double.parse(set['weight']) * double.parse(set['reps']);
      }
    }
    String sVolume = '';
    debugPrint(volume.toString());
    if (volume % 1 == 0) {
      sVolume = volume.toStringAsFixed(0);
    } else {
      sVolume = volume.toStringAsFixed(2);
    }
    return [sVolume, time, prs];
  }
  @override
  Widget build(BuildContext context) {
    List data = workoutData();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(data[1].toString()),
          ),
          const Icon(Icons.access_time),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${data[0]}kg'),
          ),
          const Icon(Icons.fitness_center),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: data[2] == 1 ? const Text('1 PR') : Text('${data[2]} PRs') ,
          ),
          const Icon(Icons.emoji_events),
        ]
      ),
    );
  }
}

String getBestSet(List exercise){
  List bestSet = [];
  for (var set in exercise){
    double weight = double.parse(set['weight']);
    double reps = double.parse(set['reps']);
    if (bestSet.isEmpty){
      bestSet = [weight, reps];
    }else if (weight > bestSet[0] ||  weight > bestSet[0] && reps > bestSet[1]){
      bestSet = [weight, reps];
    }
  }    
  return '${bestSet[0]}kg x ${bestSet[1]}';
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

//SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 16),
      //         child: ListView.builder(
      //           shrinkWrap: true,
      //           physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
      //           itemCount: day.keys.length,
      //           itemBuilder: (context, index) {
      //             String exercise = day.keys.toList()[index];
      //             return Column(
      //               crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start
      //               children: [
      //                 Text(exercise),
      //                 Table(
      //                   border: TableBorder.all(),
      //                   columnWidths: const {
      //                     0: FlexColumnWidth(1),
      //                     1: FlexColumnWidth(2),
      //                     2: FlexColumnWidth(2),
      //                   },
      //                   children: [
      //                     const TableRow(
      //                       children: [
      //                         Padding(
      //                           padding: EdgeInsets.all(8.0),
      //                           child: Text('Set'),
      //                         ),
      //                         Padding(
      //                           padding: EdgeInsets.all(8.0),
      //                           child: Text('Weight'),
      //                         ),
      //                         Padding(
      //                           padding: EdgeInsets.all(8.0),
      //                           child: Text('Reps'),
      //                         ),
      //                       ],
      //                     ),
      //                     for (int i = 0; i < (day[exercise]?.length ?? 0); i++)
      //                     TableRow(
      //                       children: [
      //                         Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: GestureDetector(
      //                             onTap: () {
      //                               // _showSetTypeMenu(exercise, i);
      //                             },
      //                             child: Container(
      //                               alignment: Alignment.center,
      //                               padding: const EdgeInsets.symmetric(vertical: 16), // Adjust vertical padding to increase hitbox
      //                               child: Text(
      //                                 day[exercise]![i]['type'] == 'Warmup'
      //                                     ? 'W'
      //                                     : day[exercise]![i]['type'] == 'Failure'
      //                                         ? 'F'
      //                                         : '${_getNormalSetNumber(day, exercise, i)}', // Display correct set number
      //                                 textAlign: TextAlign.center,
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: TextFormField(
      //                             initialValue: day[exercise]![i]['weight'].toString(),
      //                             keyboardType: TextInputType.number,
      //                             textAlign: TextAlign.center,
      //                             style: const TextStyle( // Add this property
      //                               fontSize: 20,
      //                             ),
      //                             decoration: const InputDecoration(
      //                               hintText: '',//getPrevious(exercise, i+1, 'Weight'),
      //                               border: InputBorder.none,
      //                               hintStyle: TextStyle(
      //                                 color: Colors.grey,
      //                                 fontSize: 20,
      //                               )
                                    
      //                             ),
      //                             onChanged: (value) {
      //                               // sets[exercise]![i]['weight'] = int.tryParse(value) ?? '';
      //                               // updateExercises();
      //                             },
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.all(8.0),
      //                           child: TextFormField(
      //                             initialValue: day[exercise]![i]['reps'].toString(),
      //                             keyboardType: TextInputType.number,
      //                             textAlign: TextAlign.center,
      //                             style: const TextStyle( // Add this property
      //                               fontSize: 20,
      //                             ),
      //                             decoration: const InputDecoration(
      //                               hintText: '',//getPrevious(exercise, i+1, 'Reps')
      //                               border: InputBorder.none,
      //                               hintStyle: TextStyle(
      //                                 color: Colors.grey,
      //                                 fontSize: 20,
      //                               )
      //                             ),
      //                             onChanged: (value) {
      //                               // sets[exercise]![i]['reps'] = int.tryParse(value) ?? '';  // Safely convert String to int;
      //                               // updateExercises();
      //                             },
      //                           ),
      //                         ),
      //                       ],
      //                     )

      //                   ],
      //                 ),
      //                 // Center(
      //                 //   child: ElevatedButton(
      //                 //     onPressed: () {
      //                 //       setState(() {
      //                 //         sets[exercise]!.add(
      //                 //           {'type': 'Normal', 'weight': 0, 'reps': 0},
      //                 //         );
      //                 //       });
      //                 //     },
      //                 //     child: const Text('Add Set'),
      //                 //   ),
      //                 // )
      //               ],
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),