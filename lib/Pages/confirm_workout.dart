import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmWorkout extends StatelessWidget {
  final Map sets;
  final String startTime; 
  final Map exerciseNotes;
  const ConfirmWorkout({
    super.key,
    required this.sets,
    required this.startTime, required this.exerciseNotes,
  });

  Map getStats(){
    Map stats = {"Volume" : 0, "Sets" : 0, "Exercises" : 0, "WorkoutTime": ''};
    
    for (var exercise in sets.keys){
      stats['Exercises'] += 1;
      for (var set in sets[exercise]){
        stats['Sets'] += 1;
        stats['Volume'] += (double.parse(set['weight']) * double.parse(set['reps']));
      }
    }
    Duration difference = DateTime.now().difference(DateTime.parse(startTime)); // Calculate the difference

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    stats['WorkoutTime'] = "${hours}h ${minutes}m";
    return stats;
  }
  
  @override
  Widget build(BuildContext context) {
    Map stats = getStats();
    Map notes = exerciseNotes;
    List<String> messages = ['Weight lifted:', 'Sets Done:', 'Exercises Done:', 'Workout Time'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Workout'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.0,
                ),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(8.0),
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Keeps the column compact
                        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                        children: [
                          Text(
                            messages[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            stats.keys.elementAt(index) != 'Volume' ? '${stats.values.elementAt(index)}' : '${stats.values.elementAt(index).toStringAsFixed(2)}kg',
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            //stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'notes...',
                  labelText: 'Workout Notes',
                  hintStyle: TextStyle(
                    color: Colors.grey
                  )
                ),
                style: const TextStyle(
                  fontSize: 20,
                ),
                onChanged: (value) {
                  notes['Workout'] = value;
                },
              ),
            ),
            ElevatedButton( //confirm 
              onPressed: (){
                saveExercises(sets, startTime, notes);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Confirm Workout'),
            ),
          ],
        ),
      ),
    );
  }

  void saveExercises(var exerciseList, String startTime, Map workoutNotes) async {
    String endTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()).toString();
    String day = startTime.split(' ')[0];
    Map daata = await readData();
    int num = 1; // find workouts done that day
    for (int i = 0; i < daata.keys.length; i++){
      if (daata.keys.toList()[i]?.split(' ')[0] == day){
        num++;
      }
    }
    Map data = {
      '$day $num' : {
      'stats' : {
        'startTime' : startTime,
        'endTime' : endTime,
        'notes' : workoutNotes,
      },
      'sets' : exerciseList
      }
    };
    writeData(await getRecords(exerciseList), path: 'records', append: false);
    writeData(data, append: true);
    resetData(false, true, false);
  }
  
  Future<Map> getRecords(Map exercises) async{
    Map records = await readData(path: 'records');
    for (var exercise in exercises.keys){
      for (var set in exercises[exercise]){
        if (set['PR'] == 'yes'){       
          if (records[exercise] == null){
            records[exercise] = set;
          }
          else if (double.parse(set['weight']) > double.parse(records[exercise]['weight']) || (double.parse(set['weight']) == double.parse(records[exercise]['weight']) && double.parse(set['reps']) > double.parse(records[exercise]['reps']))){
            records[exercise] = set;
          }
        }
      }
    }
    return records;
  }
}

