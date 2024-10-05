import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmWorkout extends StatelessWidget {
  final Map sets;
  final String startTime; 
  const ConfirmWorkout({
    super.key,
    required this.sets,
    required this.startTime,
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
                  childAspectRatio: 2.0, // Adjust to fit your needs
                ),
                shrinkWrap: true,
                padding: EdgeInsets.zero, // Remove padding around the GridView
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(8.0),
                      margin: EdgeInsets.zero, // Remove margin
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent, // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
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
            ElevatedButton( //confirm 
              onPressed: (){
                saveExercises(sets, startTime);
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

  void saveExercises(var exerciseList, String startTime) async {
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

