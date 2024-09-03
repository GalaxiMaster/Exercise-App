import 'dart:io';
import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), // Pass context to appBar
      body: Column(
        children: [
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MyTextButton(
              text: "Start Workout", 
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 40, 
              width: 400, 
              height: 50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    const Addworkout()
                  ),
                );
              }
            )
          ),   
          const SizedBox(height: 20,),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: MyTextButton(
              text: "Reset CSV", 
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 40, 
              width: 400, 
              height: 50,
              onTap: resetCsv, // Assuming resetCsv is a static method or function
            )
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) { // Accept context as a parameter
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Workout',
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
            filepath: 'Assets/profile.svg',
            width: 37,
            height: 37,
            borderRadius: 10,
            pressedColor: const Color.fromRGBO(163, 163, 163, .7),
            color: const Color.fromARGB(255, 245, 241, 241),
            iconHeight: 20,
            iconWidth: 20,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => 
                  const Profile()
                ),
              );
            }
          ),
        )
      ],
    );
  }
}



Future<void> resetCsv() async {
  try {
    // Ensure the CSV string ends with a newline

    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path}/output.csv';
    final file = File(path);
    // Write or append the CSV data
    await file.writeAsString(
      '',
    );

    debugPrint('CSV reset at: $path');
  } catch (e) {
    debugPrint('Error saving CSV file: $e');
  }
    try {
    // Ensure the CSV string ends with a newline

    final dir = await getExternalStorageDirectory();
    final path = '${dir?.path}/currentWorkout.csv';
    final file = File(path);
    // Write or append the CSV data
    await file.writeAsString(
      '',
    );

    debugPrint('CSV reset at: $path');
  } catch (e) {
    debugPrint('Error saving CSV file: $e');
  }
}