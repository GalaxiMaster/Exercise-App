import 'package:flutter/material.dart';
import 'workout_list.dart'; // Make sure the path to your WorkoutList file is correct

class Addworkout extends StatefulWidget {
  @override
  _AddworkoutState createState() => _AddworkoutState();
}

class _AddworkoutState extends State<Addworkout> {
  var selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display the selected exercise or a default message
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: selectedExercises.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 30,
                  child:Column(
                    children: [
                      Text(
                        selectedExercises[index],
                      )
                    ],
                  )
                );
              }
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

                if (result != null) {
                  setState(() {
                    // if (!selectedExercises.contains(result)){
                      selectedExercises.add(result);
                    // }
                    debugPrint(selectedExercises.toString());
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

