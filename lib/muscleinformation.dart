var exerciseMuscles = {
  // Chest Exercises
  'Bench Press (Barbell)': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Triceps': 20, 'Front Delts': 10}
  },
  'Bench Press (Dumbbell)': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Triceps': 20, 'Front Delts': 10}
  },
  'Incline Bench Press (Barbell)': {
    'Primary': {'Pectorals (Upper)': 70},
    'Secondary': {'Triceps': 15, 'Front Delts': 15}
  },
  'Incline Bench Press (Dumbbell)': {
    'Primary': {'Pectorals (Upper)': 70},
    'Secondary': {'Triceps': 15, 'Front Delts': 15}
  },
  'Decline Bench Press (Barbell)': {
    'Primary': {'Pectorals (Lower)': 75},
    'Secondary': {'Triceps': 15, 'Front Delts': 10}
  },
  'Decline Bench Press (Dumbbell)': {
    'Primary': {'Pectorals (Lower)': 75},
    'Secondary': {'Triceps': 15, 'Front Delts': 10}
  },
  'Chest Flyes (Flat)': {
    'Primary': {'Pectorals': 80},
    'Secondary': {'Side Delts': 20}
  },
  'Chest Flyes (Incline)': {
    'Primary': {'Pectorals (Upper)': 80},
    'Secondary': {'Front Delts': 20}
  },
  'Chest Flyes (Decline)': {
    'Primary': {'Pectorals (Lower)': 80},
    'Secondary': {'Front Delts': 20}
  },
  'Push-Ups (Standard)': {
    'Primary': {'Pectorals': 60},
    'Secondary': {'Triceps': 30, 'Front Delts': 10}
  },
  'Push-Ups (Incline)': {
    'Primary': {'Pectorals (Upper)': 60},
    'Secondary': {'Triceps': 30, 'Front Delts': 10}
  },
  'Push-Ups (Decline)': {
    'Primary': {'Pectorals (Lower)': 60},
    'Secondary': {'Triceps': 30, 'Front Delts': 10}
  },
  'Push-Ups (Wide-Grip)': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Side Delts': 20, 'Triceps': 10}
  },
  'Push-Ups (Close-Grip)': {
    'Primary': {'Triceps': 60},
    'Secondary': {'Pectorals': 30, 'Front Delts': 10}
  },
  'Push-Ups (Archer)': {
    'Primary': {'Pectorals': 60},
    'Secondary': {'Triceps': 25, 'Side Delts': 15}
  },
  'Push-Ups (Plyometric)': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Side Delts': 20, 'Triceps': 10}
  },
  'Chest Dips': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Triceps': 20, 'Front Delts': 10}
  },
  'Cable Crossovers (High)': {
    'Primary': {'Pectorals': 80},
    'Secondary': {'Side Delts': 20}
  },
  'Cable Crossovers (Mid)': {
    'Primary': {'Pectorals': 80},
    'Secondary': {'Side Delts': 20}
  },
  'Cable Crossovers (Low)': {
    'Primary': {'Pectorals': 80},
    'Secondary': {'Side Delts': 20}
  },

  // Back Exercises
  'Deadlifts (Conventional)': {
    'Primary': {'Erector Spinae': 60},
    'Secondary': {'Hamstrings': 20, 'Glutes': 10, 'Upper Traps': 10}
  },
  'Deadlifts (Sumo)': {
    'Primary': {'Glutes': 60},
    'Secondary': {'Hamstrings': 20, 'Quadriceps': 10, 'Erector Spinae': 10}
  },
  'Deadlifts (Romanian)': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
  },
  'Deadlifts (Stiff-Legged)': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
  },
  'Rack Pulls': {
    'Primary': {'Erector Spinae': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Upper Traps': 10}
  },
  'Deficit Deadlifts': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 20, 'Lower Back': 10, 'Upper Traps': 10}
  },
  'Pull-Ups (Standard)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Upper Traps': 10}
  },
  'Pull-Ups (Wide-Grip)': {
    'Primary': {'Lats': 80},
    'Secondary': {'Biceps': 10, 'Upper Traps': 10}
  },
  'Pull-Ups (Close-Grip)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Upper Traps': 10}
  },
  'Pull-Ups (Neutral-Grip)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Upper Traps': 10}
  },
  'Chin-Ups (Underhand)': {
    'Primary': {'Biceps': 60},
    'Secondary': {'Lats': 30, 'Upper Traps': 10}
  },
  'Chin-Ups (Overhand)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Upper Traps': 10}
  },
  'Chin-Ups (Neutral-Grip)': {
    'Primary': {'Biceps': 60},
    'Secondary': {'Lats': 30, 'Upper Traps': 10}
  },
  'Weighted Pull-Ups': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Upper Traps': 10}
  },
  'Weighted Chin-Ups': {
    'Primary': {'Biceps': 60},
    'Secondary': {'Lats': 30, 'Upper Traps': 10}
  },
  'Bent-Over Rows (Barbell)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Biceps': 20, 'Upper Traps': 20}
  },
  'Bent-Over Rows (Dumbbell)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Biceps': 20, 'Upper Traps': 20}
  },
  'Pendlay Rows': {
    'Primary': {'Lats': 70},
    'Secondary': {'Upper Traps': 20, 'Biceps': 10}
  },
  'T-Bar Rows (Neutral-Grip)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Upper Traps': 20, 'Biceps': 20}
  },
  'T-Bar Rows (Wide-Grip)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Upper Traps': 20, 'Biceps': 20}
  },
  'Seated Cable Rows (Close-Grip)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Upper Traps': 20, 'Biceps': 20}
  },
  'Seated Cable Rows (Wide-Grip)': {
    'Primary': {'Lats': 60},
    'Secondary': {'Upper Traps': 20, 'Biceps': 20}
  },
  'Lat Pulldowns (Wide-Grip)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Rhomboids': 10}
  },
  'Lat Pulldowns (Close-Grip)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Rhomboids': 10}
  },
  'Lat Pulldowns (Underhand)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Rhomboids': 10}
  },
  'Lat Pulldowns (Neutral-Grip)': {
    'Primary': {'Lats': 70},
    'Secondary': {'Biceps': 20, 'Rhomboids': 10}
  },

  // Shoulder Exercises
  'Overhead Press (Barbell)': {
    'Primary': {'Front Delts': 50, 'Side Delts': 20},
    'Secondary': {'Triceps': 20, 'Trapezius': 10}
  },
  'Overhead Press (Dumbbell)': {
    'Primary': {'Front Delts': 50, 'Side Delts': 20},
    'Secondary': {'Triceps': 20, 'Trapezius': 10}
  },
  'Push Press': {
    'Primary': {'Front Delts': 50, 'Side Delts': 20},
    'Secondary': {'Triceps': 20, 'Quadriceps': 10}
  },
  'Arnold Press': {
    'Primary': {'Front Delts': 50, 'Side Delts': 20},
    'Secondary': {'Triceps': 20, 'Trapezius': 10}
  },
  'Lateral Raises (Dumbbell)': {
    'Primary': {'Side Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Lateral Raises (Cable)': {
    'Primary': {'Side Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Front Raises (Dumbbell)': {
    'Primary': {'Front Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Front Raises (Cable)': {
    'Primary': {'Front Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Rear Delt Flyes (Dumbbell)': {
    'Primary': {'Posterior Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Rear Delt Flyes (Cable)': {
    'Primary': {'Posterior Delts': 80},
    'Secondary': {'Trapezius': 20}
  },
  'Shrugs (Dumbbell)': {
    'Primary': {'Trapezius': 90},
    'Secondary': {'Posterior Delts': 10}
  },
  'Shrugs (Barbell)': {
    'Primary': {'Trapezius': 90},
    'Secondary': {'Posterior Delts': 10}
  },

  // Bicep Exercises
  'Barbell Curls (Standard)': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Dumbbell Curls': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Hammer Curls': {
    'Primary': {'Brachialis': 70},
    'Secondary': {'Forearms': 30}
  },
  'Preacher Curls': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Concentration Curls': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Cable Curls': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Spider Curls': {
    'Primary': {'Biceps': 90},
    'Secondary': {'Forearms': 10}
  },

  //triceps
  'Tricep Dips': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Front Delts': 10, 'Pectorals': 10}
  },
  'Skull Crushers (Barbell)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Skull Crushers (Dumbbell)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Skull Crushers (EZ Bar)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Skull Crushers (Cable)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Overhead Tricep Extension (Dumbbell)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Overhead Tricep Extension (Cable)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Tricep Kickbacks': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Rear Delts': 10}
  },
  'Close-Grip Bench Press': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Pectorals': 20, 'Front Delts': 10}
  },
  'Cable Tricep Pushdowns': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  'Rope Tricep Extensions': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Forearms': 10}
  },
  // Leg Exercises
  'Squats (Barbell)': {
    'Primary': {'Quadriceps': 50},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10, 'Lower Back': 10}
  },
  'Front Squats': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Core': 10}
  },
  'Leg Press': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
  },
  'Lunges (Dumbbell)': {
    'Primary': {'Quadriceps': 40},
    'Secondary': {'Glutes': 40, 'Hamstrings': 20}
  },
  'Lunges (Barbell)': {
    'Primary': {'Quadriceps': 40},
    'Secondary': {'Glutes': 40, 'Hamstrings': 20}
  },
  'Bulgarian Split Squats': {
    'Primary': {'Quadriceps': 50},
    'Secondary': {'Glutes': 30, 'Hamstrings': 20}
  },
  'Leg Curls': {
    'Primary': {'Hamstrings': 90},
    'Secondary': {'Glutes': 10}
  },
  'Leg Extensions': {
    'Primary': {'Quadriceps': 90},
    'Secondary': {}
  },
  'Romanian Deadlifts': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
  },
  'Glute Bridges': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 20, 'Lower Back': 10}
  },
  'Hip Thrusts': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 20, 'Quadriceps': 10}
  },
  'Calf Raises (Standing)': {
    'Primary': {'Calves': 90},
    'Secondary': {}
  },
  'Calf Raises (Seated)': {
    'Primary': {'Calves': 90},
    'Secondary': {}
  },
  'Step-Ups': {
    'Primary': {'Quadriceps': 50},
    'Secondary': {'Glutes': 30, 'Hamstrings': 20}
  },
  // Core Exercises
  'Crunches': {
    'Primary': {'Rectus Abdominis': 90},
    'Secondary': {'Obliques': 10}
  },
  'Leg Raises': {
    'Primary': {'Lower Abs': 90},
    'Secondary': {'Hip Flexors': 10}
  },
  'Plank': {
    'Primary': {'Core': 90},
    'Secondary': {'Shoulders': 10}
  },
  'Russian Twists': {
    'Primary': {'Obliques': 90},
    'Secondary': {'Core': 10}
  },
  'Bicycle Crunches': {
    'Primary': {'Obliques': 70},
    'Secondary': {'Rectus Abdominis': 30}
  },
  'Mountain Climbers': {
    'Primary': {'Core': 70},
    'Secondary': {'Quadriceps': 20, 'Shoulders': 10}
  }
};
