import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), // Pass context to appBar
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                "Blank",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            const SizedBox(height: 5),
            MyTextButton(
              text: "Start Workout", 
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 15, 
              width: double.infinity, 
              height: 50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    const Addworkout()
                  ),
                );
              }
            ),  
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                "Routines",
                style: TextStyle(
                  fontSize: 18
                ),
              ),
            ),
            const SizedBox(height: 5),
            MyTextButton(
              text: "New routine", 
              pressedColor: Colors.blue, 
              color: Colors.green, 
              borderRadius: 15, 
              width: double.infinity, 
              height: 50,
              onTap: () {
                readData(path: 'output');
              }
            ),
            const SizedBox(height: 20),
            _buildStreakRestBox(label: 'tESSSZT', exercises: 'bench press, cable fly')
          ],
        ),
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

Widget _buildStreakRestBox({
  required String label,
  required String exercises,
}) {
  Color color = Colors.blue;
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Ensure the whole column aligns to the left
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // Align the text to the left within this column
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      exercises,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_vert, color: color),
                ),
              ],
            ),
            const SizedBox(height: 15),
            MyTextButton(
              text: 'Start routine',
              pressedColor: Colors.black,
              color: color,
              borderRadius: 12.5,
              width: double.infinity,
              height: 40,
            ),
          ],
        ),
      ),
    ],
  );
}




