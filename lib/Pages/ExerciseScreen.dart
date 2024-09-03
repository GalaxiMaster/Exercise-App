// import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  final String exercise;

  const ExerciseScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, exercise),
      body: Center()
    );
  }
}
AppBar appBar(BuildContext context, String exercise) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        exercise,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
    );
  }

