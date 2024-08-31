import 'package:exercise_app/Pages/workout_list.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'home.dart';

// ignore: must_be_immutable
class Addworkout extends StatelessWidget {
  Addworkout({super.key});
  var chosenExercises = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body:  Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    WorkoutList()
                  ),
                );
              },
              child: const Text(
                'Add Exercises',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: 
                  FontWeight.bold
                ),
              ),
              ),
            ),
        ]
      ),
    );
  }
}

AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Exercises',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
  }
