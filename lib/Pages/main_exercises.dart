import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MainExercisesPage extends StatelessWidget {
  Map sets;
  MainExercisesPage({super.key, required this.sets});   
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: myAppBar(context, 'Radar Chart'),
        body: Column(),
      );
    }
}
