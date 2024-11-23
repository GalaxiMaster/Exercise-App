import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class ConfirmWorkout extends StatefulWidget {
  final Map sets;
  final String startTime; 
  final Map exerciseNotes;
  const ConfirmWorkout({
    super.key,
    required this.sets,
    required this.startTime, required this.exerciseNotes,
  });
  @override
  // ignore: library_private_types_in_public_api
  ConfirmWorkoutState createState() => ConfirmWorkoutState();
}

class ConfirmWorkoutState extends State<ConfirmWorkout> {
  Map getStats(){
    Map stats = {"Volume" : 0, "Sets" : 0, "Exercises" : 0, "WorkoutTime": ''};
    
    for (var exercise in widget.sets.keys){
      stats['Exercises'] += 1;
      for (var set in widget.sets[exercise]){
        stats['Sets'] += 1;
        stats['Volume'] += (double.parse(set['weight'].toString()) * double.parse(set['reps'].toString()));
      }
    }
    Duration difference = endTime.difference(startTime); // Calculate the difference

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    stats['WorkoutTime'] = "${hours}h ${minutes}m";
    return stats;
  }
  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
  @override
  void initState() {
    super.initState();
    notes = widget.exerciseNotes;
    startTime = DateTime.parse(widget.startTime);
  }
  Map notes = {};
  Map stats = {};
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    stats = getStats();
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
                  return GestureDetector(
                    onTap: () async{
                      switch(messages[index]){
                        case 'Workout Time':
                          final result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DateTimePickerDialog(
                                initialFromTime: TimeOfDay(hour: startTime.hour, minute: startTime.minute), initialFromDate: startTime,
                                initialToTime: TimeOfDay(hour: endTime.hour, minute: endTime.minute), initialToDate: endTime,
                              );
                            },
                          );
                          if (result != null) {
                            setState(() {
                              startTime = combineDateAndTime(result['fromDate'], result['fromTime']);
                              endTime = combineDateAndTime(result['toDate'], result['toTime']);
                            });
                          }
                      }
                    },
                    child: Center(
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
                saveExercises(widget.sets, startTime, notes, endTime);
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

  void saveExercises(var exerciseList, DateTime startTime, Map workoutNotes, DateTime endTime) async {
    String day = DateFormat('yyyy-MM-dd').format(startTime);
    String startTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(startTime);
    String endTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(endTime);

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
        'startTime' : startTimeStr,
        'endTime' : endTimeStr,
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
          else if (double.parse(set['weight'].toString()) > double.parse(records[exercise]['weight']) || (double.parse(set['weight'].toString()) == double.parse(records[exercise]['weight']) && double.parse(set['reps'].toString()) > double.parse(records[exercise]['reps']))){
            records[exercise] = set;
          }
        }
      }
    }
    return records;
  }
}


class DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialFromDate;
  final TimeOfDay? initialFromTime;
  final DateTime? initialToDate;
  final TimeOfDay? initialToTime;

  const DateTimePickerDialog({super.key, 
    this.initialFromDate,
    this.initialFromTime,
    this.initialToDate,
    this.initialToTime,
  });

  @override
  _DateTimePickerDialogState createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  DateTime? fromDate;
  TimeOfDay? fromTime;
  DateTime? toDate;
  TimeOfDay? toTime;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate ?? DateTime.now();
    fromTime = widget.initialFromTime ?? TimeOfDay.now();
    toDate = widget.initialToDate ?? DateTime.now();
    toTime = widget.initialToTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date and Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // From Date and Time
          const Text('From'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        fromDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    fromDate != null
                        ? '${fromDate!.year}-${fromDate!.month}-${fromDate!.day}'
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: fromTime ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        fromTime = selectedTime;
                      });
                    }
                  },
                  child: Text(
                    fromTime != null
                        ? fromTime!.format(context)
                        : 'Select Time',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // To Date and Time
          const Text('To'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: toDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        toDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    toDate != null
                        ? '${toDate!.year}-${toDate!.month}-${toDate!.day}'
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: toTime ?? TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        toTime = selectedTime;
                      });
                    }
                  },
                  child: Text(
                    toTime != null
                        ? toTime!.format(context)
                        : 'Select Time',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Perform your desired action with fromDate, fromTime, toDate, and toTime
            Navigator.of(context).pop({
              'fromDate': fromDate,
              'fromTime': fromTime,
              'toDate': toDate,
              'toTime': toTime,
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
