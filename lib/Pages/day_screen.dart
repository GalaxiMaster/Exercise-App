import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/calendar.dart';
import 'package:exercise_app/Pages/day_screen_individual.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DayScreen extends ConsumerStatefulWidget {
  final DateTime date;
  final List<String> dayKeys;
  final Function? reload;
  const DayScreen({super.key, required this.date, required this.dayKeys, this.reload});
  @override
  // ignore: library_private_types_in_public_api
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  late DateTime date;
  @override
  void initState() {
    super.initState();
    date = widget.date;
  }
  Map<dynamic, dynamic> parseDayKeys(Map workoutData, List dayKeys) {
    Map data = {};
    for (String key in dayKeys){
      if (!workoutData.containsKey(key)) continue;

      data[key] = workoutData[key];
    }

    return data;
  }

  @override
  build(BuildContext context) {
    final workoutProvider = ref.watch(workoutDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts for ${date.day}/${date.month}/${date.year}'),
      ),
      body: workoutProvider.when(
        data: (data){
          Map dayData = parseDayKeys(data, widget.dayKeys);
          return Column(
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
                        );
                      },
                      child: dayBox(dayData.entries.toList()[index])
                    );
                  }
                ),
              )
            ],
          );
        }, 
        error: (error, stack) => Text('An error occured fetching the data: $error'), 
        loading: () => CircularProgressIndicator()
      )
    );
  }
  Widget dayBox(MapEntry day){
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
                    DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(day.value['stats']['startTime'])),
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
                              builder: (context) => Addworkout(sets: day, editing: true),
                            ),
                          );
                          ref.read(workoutDataProvider.notifier).updateValue(day.key, result);
                        case 'Share':
                          debugPrint('share');
                          // share day
                        case 'Delete':
                          debugPrint('delete');
                          ref.read(workoutDataProvider.notifier).deleteDay(day.key);
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
                '${day.value['stats']['startTime'].split(' ')[1]}-${day.value['stats']['endTime'].split(' ')[1]}',
                style: const TextStyle(
                  fontSize: 15
                ),
              ),
            ),
            WorkoutStats(workout: day.value),
            if (day.value['stats']?['notes']?['Workout'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('Notes :${day.value['stats']?['notes']?['Workout']}'),
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
            for (int i = 0; i < (day.value['sets']?.length ?? 0); i++)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2.5),
                  child: Text(
                    day.value['sets'].keys.toList()[i]
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2.5),
                  child: Text(getBestSet(day.value['sets'][day.value['sets'].keys.toList()[i]], exerciseMuscles[day.value['sets'].keys.toList()[i]]?['type'] ?? 'Weighted')),
                )
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String getBestSet(List exercise, String type){
    List bestSet = [];
    for (var set in exercise){
      double weight = double.parse(set['weight'].toString());
      double reps = double.parse(set['reps'].toString());
      if (bestSet.isEmpty){
        bestSet = [weight, reps];
      }else if (weight > bestSet[0] ||  weight >= bestSet[0] && reps > bestSet[1]){
        bestSet = [weight, reps];
      }
    }    
    return type == 'Bodyweight' ? (int.tryParse(bestSet[1].toString()) ?? bestSet[1]).toStringAsFixed(0) : '${bestSet[0]}kg x ${bestSet[1]}';
  }
}
