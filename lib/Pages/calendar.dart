import 'package:exercise_app/Pages/day_screen.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Calendar'),
      body: const CalendarWidget(),
    );
  }
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
            bool isToday = date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;
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
                    border: isToday ? Border.all(
                      color: Colors.blue,
                      width: 2,
                    ) : null,
                    color:
                        isHighlighted ? Colors.blue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                          fontSize: 19
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
        volume += double.parse(set['weight'].toString()) * double.parse(set['reps'].toString());
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

String getBestSet(List exercise, String type){
  List bestSet = [];
  for (var set in exercise){
    double weight = double.parse(set['weight'].toString());
    double reps = double.parse(set['reps'].toString());
    if (bestSet.isEmpty){
      bestSet = [weight, reps];
    }else if (weight > bestSet[0] ||  weight > bestSet[0] && reps > bestSet[1]){
      bestSet = [weight, reps];
    }
  }    
  return type == 'bodyweight' ? (int.tryParse(bestSet[1].toString()) ?? bestSet[1]).toStringAsFixed(0) : '${bestSet[0]}kg x ${bestSet[1]}';
}