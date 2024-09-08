import 'package:exercise_app/Pages/ExerciseScreen.dart';
import 'package:exercise_app/muscleinformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  var exercises = [
    // Chest Exercises
    "Bench Press (Barbell)",
    "Bench Press (Dumbbell)",
    "Incline Bench Press (Barbell)",
    "Incline Bench Press (Dumbbell)",
    "Decline Bench Press (Barbell)",
    "Decline Bench Press (Dumbbell)",
    "Chest Flyes (Flat)",
    "Chest Flyes (Incline)",
    "Chest Flyes (Decline)",
    "Push-Ups (Standard)",
    "Push-Ups (Incline)",
    "Push-Ups (Decline)",
    "Push-Ups (Wide-Grip)",
    "Push-Ups (Close-Grip)",
    "Push-Ups (Archer)",
    "Push-Ups (Plyometric)",
    "Chest Dips",
    "Cable Crossovers (High)",
    "Cable Crossovers (Mid)",
    "Cable Crossovers (Low)",

    // Back Exercises
    "Deadlifts (Conventional)",
    "Deadlifts (Sumo)",
    "Deadlifts (Romanian)",
    "Deadlifts (Stiff-Legged)",
    "Rack Pulls",
    "Deficit Deadlifts",
    "Pull-Ups (Standard)",
    "Pull-Ups (Wide-Grip)",
    "Pull-Ups (Close-Grip)",
    "Pull-Ups (Neutral-Grip)",
    "Chin-Ups (Underhand)",
    "Chin-Ups (Overhand)",
    "Chin-Ups (Neutral-Grip)",
    "Weighted Pull-Ups",
    "Weighted Chin-Ups",
    "Bent-Over Rows (Barbell)",
    "Bent-Over Rows (Dumbbell)",
    "Pendlay Rows",
    "T-Bar Rows (Neutral-Grip)",
    "T-Bar Rows (Wide-Grip)",
    "Seated Cable Rows (Close-Grip)",
    "Seated Cable Rows (Wide-Grip)",
    "Lat Pulldowns (Wide-Grip)",
    "Lat Pulldowns (Close-Grip)",
    "Lat Pulldowns (Underhand)",
    "Lat Pulldowns (Overhand)",
    "Single-Arm Dumbbell Rows",
    "Meadows Rows",
    "Seal Rows",

    // Shoulder Exercises
    "Overhead Press (Barbell)",
    "Overhead Press (Dumbbell)",
    "Overhead Press (Seated Barbell)",
    "Overhead Press (Seated Dumbbell)",
    "Push Press (Barbell)",
    "Push Press (Dumbbell)",
    "Lateral Raises (Dumbbell)",
    "Lateral Raises (Cable)",
    "Lateral Raises (Machine)",
    "Front Raises (Dumbbell)",
    "Front Raises (Barbell)",
    "Front Raises (Cable)",
    "Front Raises (Plate)",
    "Rear Delt Flyes (Dumbbell)",
    "Rear Delt Flyes (Cable)",
    "Rear Delt Flyes (Machine)",
    "Face Pulls",
    "Arnold Press",
    "Shrugs (Barbell)",
    "Shrugs (Dumbbell)",
    "Shrugs (Trap Bar)",
    "Shrugs (Smith Machine)",
    "Bradford Press",
    "Cuban Press",

    // Bicep Exercises
    "Barbell Curls (Standard)",
    "Barbell Curls (Wide-Grip)",
    "Barbell Curls (Close-Grip)",
    "Dumbbell Curls (Alternating)",
    "Dumbbell Curls (Simultaneous)",
    "Dumbbell Curls (Seated)",
    "Dumbbell Curls (Standing)",
    "Hammer Curls (Standing)",
    "Hammer Curls (Seated)",
    "Hammer Curls (Cross-Body)",
    "Preacher Curls (Barbell)",
    "Preacher Curls (Dumbbell)",
    "Preacher Curls (Machine)",
    "Concentration Curls (Seated)",
    "Concentration Curls (Standing)",
    "Cable Curls (Straight Bar)",
    "Cable Curls (Rope)",
    "Cable Curls (Single-Arm)",
    "Reverse Curls (Barbell)",
    "Reverse Curls (EZ Bar)",
    "Spider Curls (Barbell)",
    "Spider Curls (Dumbbell)",
    "Zottman Curls",

    // Tricep Exercises
    "Tricep Dips (Bench)",
    "Tricep Dips (Parallel Bars)",
    "Tricep Dips (Weighted)",
    "Skull Crushers (Barbell)",
    "Skull Crushers (Dumbbell)",
    "Skull Crushers (EZ Bar)",
    "Skull Crushers (Cable)",
    "Tricep Pushdowns (Rope)",
    "Tricep Pushdowns (Straight Bar)",
    "Tricep Pushdowns (V-Bar)",
    "Overhead Tricep Extension (Dumbbell)",
    "Overhead Tricep Extension (Rope)",
    "Overhead Tricep Extension (Barbell)",
    "Close-Grip Bench Press",
    "Dumbbell Kickbacks (Single-Arm)",
    "Dumbbell Kickbacks (Double-Arm)",
    "Cable Kickbacks (Single-Arm)",
    "Cable Kickbacks (Double-Arm)",
    "Reverse-Grip Tricep Pushdowns",
    "JM Press",

    // Leg Exercises
    "Squats (Barbell)",
    "Squats (Dumbbell)",
    "Front Squats (Barbell)",
    "Front Squats (Dumbbell)",
    "Zercher Squats",
    "Bulgarian Split Squats (Barbell)",
    "Bulgarian Split Squats (Dumbbell)",
    "Bulgarian Split Squats (Smith Machine)",
    "Goblet Squats",
    "Pistol Squats",
    "Hack Squats (Machine)",
    "Leg Press (Standard)",
    "Leg Press (Close-Stance)",
    "Leg Press (Wide-Stance)",
    "Leg Press (Single-Leg)",
    "Lunges (Walking)",
    "Lunges (Reverse)",
    "Lunges (Side)",
    "Lunges (Bulgarian)",
    "Lunges (Stationary)",
    "Step-Ups (Barbell)",
    "Step-Ups (Dumbbell)",
    "Romanian Deadlifts (Barbell)",
    "Romanian Deadlifts (Dumbbell)",
    "Sumo Deadlifts",
    "Deficit Deadlifts",
    "Leg Curls (Seated)",
    "Leg Curls (Lying)",
    "Leg Curls (Standing)",
    "Leg Extensions",
    "Calf Raises (Seated)",
    "Calf Raises (Standing)",
    "Calf Raises (Single-Leg)",
    "Calf Raises (Smith Machine)",
    "Calf Press (Leg Press Machine)",
    "Hip Thrusts (Barbell)",
    "Hip Thrusts (Dumbbell)",
    "Glute Bridges (Barbell)",
    "Glute Bridges (Dumbbell)",

    // Core Exercises
    "Planks (Standard)",
    "Planks (Side)",
    "Planks (Extended)",
    "Planks (Weighted)",
    "Russian Twists (Bodyweight)",
    "Russian Twists (Medicine Ball)",
    "Russian Twists (Dumbbell)",
    "Sit-Ups (Bodyweight)",
    "Sit-Ups (Weighted)",
    "Sit-Ups (Decline)",
    "Leg Raises (Hanging)",
    "Leg Raises (Lying)",
    "Leg Raises (Incline)",
    "Mountain Climbers",
    "Ab Wheel Rollouts",
    "Bicycle Crunches",
    "Hanging Leg Raises",
    "Flutter Kicks",
    "V-Ups",
    "Cable Crunches",
    "Dragon Flags",
    "Windshield Wipers",
    "Cable Woodchoppers",

    // Cardio Exercises
    "Running (Treadmill)",
    "Running (Outdoor)",
    "Cycling (Stationary)",
    "Cycling (Outdoor)",
    "Rowing (Machine)",
    "Jump Rope (Standard)",
    "Jump Rope (Double Under)",
    "Stair Climber",
    "Elliptical",
    "Battle Ropes",
    "Box Jumps",
    "Burpees",

    // Compound Movements
    "Clean and Press (Barbell)",
    "Clean and Press (Dumbbell)",
    "Snatch (Barbell)",
    "Snatch (Dumbbell)",
    "Power Clean",
    "Power Snatch",
    "Thrusters (Barbell)",
    "Thrusters (Dumbbell)",
    "Push Jerk",
    "Split Jerk",

    // Stretching and Mobility Exercises
    "Static Stretching",
    "Dynamic Stretching",
    "Foam Rolling",
    "Yoga Poses (Downward Dog)",
    "Yoga Poses (Warrior)",
    "Yoga Poses (Child's Pose)",
    "Yoga Poses (Pigeon Pose)",
    "Hip Flexor Stretch",
    "Hamstring Stretch",
    "Quad Stretch",
    "Chest Stretch",
    "Shoulder Stretch"
  ];

  String query = '';

  @override
  Widget build(BuildContext context) {
    var filteredExercises = exercises
        .where((exercise) =>
            exercise.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
      ),
      body: Column(
        children: [
          SearchBar(onQueryChanged: (newQuery) {
            setState(() {
              query = newQuery;
            });
          }),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          ExerciseScreen(exercise: filteredExercises[index])
                        )
                      );
                  },
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SvgPicture.asset(
                            "Assets/profile.svg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(filteredExercises[index]),
                            Text(getMuscles(filteredExercises[index]))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onQueryChanged;

  const SearchBar({super.key, required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onQueryChanged,
        decoration: const InputDecoration(
          labelText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

String getMuscles(String exercise){
  String muscle = exerciseMuscles[exercise]!['Primary']!.keys.toList()[0];
  return muscle != 'null' ? muscle : 'No muscle';
}