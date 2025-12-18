import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/calendar.dart';
import 'package:exercise_app/Pages/day_screen_individual.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayScreen extends StatefulWidget {
  final DateTime date;
  final Map dayData;
  final Function? reload;
  const DayScreen({super.key, required this.date, required this.dayData, this.reload});
  @override
  // ignore: library_private_types_in_public_api
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  Map dayData = {};
  void reload(String date) async{
    Map data = await readData();
    setState(() { // who knows if this works // ! WHAT DO YOU MEAN WHO KNOWS IF IT WORKS??
      dayData = data[date];
    }); 
  }
  @override
  build(BuildContext context) {
    dayData = widget.dayData;
    DateTime date = widget.date;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts for ${date.day}/${date.month}/${date.year}'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: dayData.keys.length,
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IndividualDayScreen(dayData: dayData[dayData.keys.toList()[index]], dayKey: dayData.keys.toList()[index]))
                    ).then((_) {
                      reload(dayData.keys.toList()[index]);
                    });
                  },
                  child: dayBox(dayData[dayData.keys.toList()[index]])
                );
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
          color: const Color.fromARGB(255, 173, 173, 173).withValues(alpha: 0.1),
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
                          final result = await Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => Addworkout(sets: day, confirm: true),
                            ),
                          );
                          if (result != null){
                            day['sets'] = result;
                            editDay(day);
                            setState(() {});
                          }
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
                          if (widget.reload != null){
                            widget.reload!();
                          }
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
            if (day['stats']?['notes']?['Workout'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('Notes :${day['stats']?['notes']?['Workout']}'),
              ),
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
                  child: Text(getBestSet(day['sets'][day['sets'].keys.toList()[i]], exerciseMuscles[day['sets'].keys.toList()[i]]?['type'] ?? 'Weighted')),
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
    Map<String, dynamic> data = await readData();
    data.remove(dayKey);
    writeData(data, append: false);
    return true;
  }
    Future<bool> editDay(Map day) async{
    String dayKey = '';
    widget.dayData.forEach((key, value) {
      if (value == day) {
        dayKey = key;
      }
    });
    if (dayKey == ''){return false;}
    Map<String, dynamic> data = await readData();
    data[dayKey]['sets'] = day['sets'];
    writeData(data, append: false);
    return true;
  }
}