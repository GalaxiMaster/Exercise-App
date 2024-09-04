import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:path_provider/path_provider.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: CalendarWidget(),
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
    actions: const [
      Center(
        child: MyIconButton(
          filepath: 'Assets/settings.svg',
          width: 37,
          height: 37,
          borderRadius: 10,
          pressedColor: Color.fromRGBO(163, 163, 163, .7),
          color: Color.fromARGB(255, 245, 241, 241),
          iconHeight: 20,
          iconWidth: 20,
        ),
      )
    ],
  );
}

class CalendarWidget extends StatefulWidget {
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
    var data = await gatherData();
    setState(() {
      exerciseData = data;
      highlightedDays = data.keys.map((x) => DateTime.parse(x)).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      minDate: DateTime(2024, 1, 1), // startdate
      maxDate: DateTime(2024, 12, 31), /// year from now
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
                    builder: (context) => DayScreen(date: date, day: exerciseData[DateFormat('yyyy-MM-dd').format(date).toString()]),
                  ),
                );
            }   
          },
          child: Transform.scale(
            scale: 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : Colors.black,
                    fontSize: 19
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
                                  initialValue: day[exercise]![i]['Weight'].toString(),
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
                                  initialValue: day[exercise]![i]['Reps'].toString(),
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
                      //       addNewSet(exercise);
                      //     },
                      //     child: const Text('Add Set'),
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () async {
            //     // Navigate to WorkoutList and wait for the result
            //     final result = await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const WorkoutList(),
            //       ),
            //     );

            //     if (result != null) {
            //       setState(() {
            //         selectedExercises.add(result);
            //         sets[result] = [
            //           {'weight': '', 'reps': '', 'type': 'Normal'}
            //         ]; // Initialize sets list for the new exercise
            //         // debugPrint(selectedExercises.toString());
            //       });
            //     }
            //   },
            //   child: const Text('Select Exercise'),
            // ),
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

Future<Map> gatherData()async {
  Map exerciseData = {};
  List data = await readFromCsv();
  for (var set in data){
    String day = set[0].split(' ')[0];
    if (exerciseData.containsKey(day) && exerciseData[day].containsKey(set[2])){
      exerciseData[day][set[2]].add({'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]});
    } else if(exerciseData.containsKey(day)){
      exerciseData[day][set[2]] = [{'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]}];
    } else{
      exerciseData[day] = {};
      exerciseData[day][set[2]] = [{'Weight' : set[6], 'Reps' : set[7], 'Type' : set[5]}];
    }
  }
  return exerciseData;
}

Future<List<List<dynamic>>> readFromCsv() async {
  List<List<dynamic>> csvData = [];
  try {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final path = '${dir.path}/output.csv';
      final file = File(path);

      // Check if the file exists before attempting to read it
      if (await file.exists()) {
        final csvString = await file.readAsString();
        const converter = CsvToListConverter(
          fieldDelimiter: ',', // Default
          eol: '\n',           // End-of-line character
        );

        List<List<dynamic>> csvData = converter.convert(csvString);
        debugPrint('CSV Data: $csvData');
        return csvData;
      } else {
        debugPrint('Error: CSV file does not exist');
      }
    } else {
      debugPrint('Error: External storage directory is null');
    }
  } catch (e) {
    debugPrint('Error reading CSV file: $e');
  }
  return csvData;
}