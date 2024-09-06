import 'dart:io';
import 'package:csv/csv.dart';
import 'package:exercise_app/Pages/Calender.dart';
import 'package:exercise_app/Pages/exercise_list.dart';
import 'package:exercise_app/Pages/muscle_data.dart';
import 'package:exercise_app/Pages/settings.dart';
import 'package:exercise_app/Pages/stats.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> messages = ['Calender', 'Exercises', 'Muscles', 'Stats'];
    return Scaffold(
      appBar: appBar(context),
      body: SizedBox(
              width: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2, // Adjust to fit your needs
                ),
                shrinkWrap: true,
                padding: EdgeInsets.zero, // Remove padding around the GridView
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Widget destination;
                      if (index == 0) {
                        destination = const CalenderScreen();
                      } else if (index == 1) {
                        destination = const ExerciseList();
                      } else if (index == 2){
                        destination = const MuscleData();
                      } else {
                        destination = const Stats();
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => destination)
                      );
                    },
                    child: Center(
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
                              style: const TextStyle(
                                fontSize: 20,
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
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      actions: [
        Center(
          child: MyIconButton(
            filepath: 'Assets/settings.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: const Color.fromRGBO(163, 163, 163, .7),
            color: const Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => 
                  const Settings()
                )
              );
            },
            ),
        )
      ],
    );
  }

void getStats(){
  
}

Future<List<List<dynamic>>> readFromCsv() async {
  List<List<dynamic>> csvData = [];
  debugPrint('****************************************************************************************');
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
  debugPrint("balls");
  return csvData;
}