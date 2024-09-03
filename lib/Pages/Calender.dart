import 'dart:io';

import 'package:csv/csv.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
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
  final List<DateTime> highlightedDays = [
    DateTime(2024, 8, 21),
    DateTime(2024, 8, 22),
    DateTime(2024, 8, 24),
    DateTime(2024, 8, 27),
    DateTime(2024, 8, 29),
    DateTime(2024, 8, 31),
  ];

  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      minDate: DateTime(2024, 1, 1),
      maxDate: DateTime(2024, 12, 31),
      dayBuilder: (context, date) {
        bool isHighlighted = highlightedDays.any((highlightedDay) =>
            date.year == highlightedDay.year &&
            date.month == highlightedDay.month &&
            date.day == highlightedDay.day);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayScreen(date: date),
              ),
            );
          },
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

  const DayScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${date.day}/${date.month}/${date.year}'),
      ),
      body: Center(
        child: Text(
          'Activities for ${date.day}/${date.month}/${date.year}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

List gatherData(){
  List days = [];
  Future<List<List>> data = readFromCsv();
  
  return days;
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