import 'package:exercise_app/Pages/add_workout.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/widgets.dart';

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



