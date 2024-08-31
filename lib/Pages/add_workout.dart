import 'package:flutter/material.dart';
import 'workout_list.dart'; // Make sure the path to your WorkoutList file is correct

class Addworkout extends StatefulWidget {
  @override
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  String selectedExercise = '';
  var selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the selected exercise or a default message
            Text(
              selectedExercise.isEmpty
                  ? 'No exercise selected'
                  : 'Selected Exercise: $selectedExercise',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to WorkoutList and wait for the result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutList(),
                  ),
                );

                // If an exercise was selected, update the state with the selected exercise
                if (result != null) {
                  setState(() {
                    selectedExercise = result;
                    selectedExercises.add(result);
                  });
                }
              },
              child: Text('Select Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}

