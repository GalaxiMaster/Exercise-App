Map<String, List<String>> muscleGroups = {
  'Back': ['Lats', 'Erectors', 'Rhomboids', 'Traps'],
  'Chest': ['Chest', 'Upper Chest', 'Lower Chest'],
  'Shoulders': ['Front Delts', 'Side Delts', 'Rear Delts'],
  'Arms': ['Biceps', 'Triceps', 'Forearms', 'Brachialis'],
  'Legs': ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
  'Core': ['Abdominals', 'Obliques', 'Hip Flexors']
};

Map<String, Map<String, dynamic>> exerciseMuscles = {
    "Lat Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 15,
            "Traps": 10,
            "Rhomboids": 5
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Barbell Clean and Press": {
        "Primary": {
            "Front Delts": 30,
            "Side Delts": 15,
            "Traps": 35
        },
        "Secondary": {
            "Quads": 10,
            "Glutes": 10
        },
        "type": "Weighted"
    },
    "Barbell Overhead Squat": {
        "Primary": {
            "Quads": 40,
            "Front Delts": 20,
            "Side Delts": 10
        },
        "Secondary": {
            "Glutes": 15,
            "Hamstrings": 15
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Shoulder Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Barbell Pullover To Press": {
        "Primary": {
            "Chest": 40,
            "Lats": 30,
            "Front Delts": 20
        },
        "Secondary": {
            "Triceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Seated One Arm Arnold Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 20
        },
        "Secondary": {
            "Triceps": 20,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Standing Overhead Press (Barbell)": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 20
        },
        "Secondary": {
            "Triceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Arnold Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 20
        },
        "Secondary": {
            "Triceps": 20,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Cable Shoulder Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated One Arm Shoulder Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Side Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Shoulder Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Reverse Dip": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Dumbbell Standing Biceps Curl to Shoulder Press": {
        "Primary": {
            "Biceps": 50,
            "Front Delts": 30,
            "Side Delts": 10
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Alternate Hammer Curl and Press": {
        "Primary": {
            "Biceps": 40,
            "Brachialis": 30,
            "Front Delts": 10,
            "Side Delts": 10
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Body Up": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Biceps Curl to Shoulder Press": {
        "Primary": {
            "Biceps": 50,
            "Front Delts": 30,
            "Side Delts": 10
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Ring Dip": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Chest Dip on Straight Bar": {
        "Primary": {
            "Triceps": 25,
            "Chest": 65
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Dumbbell Lying Triceps Extension": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Chest": 5,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Barbell Thruster": {
        "Primary": {
            "Quads": 25,
            "Front Delts": 15,
            "Side Delts": 10
        },
        "Secondary": {
            "Glutes": 25,
            "Hamstrings": 12.5,
            "Triceps": 12.5
        },
        "type": "Weighted"
    },

    "Dumbbell Arnold Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 20
        },
        "Secondary": {
            "Triceps": 20,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Cable Incline Triceps Extension": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Chest": 5,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Barbell Lying Triceps Extension": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Chest": 5,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Floor Skullcrusher": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Chest": 5,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Incline Push up": {
        "Primary": {
            "Chest": 50,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Bodyweight"
    },
    "Back Lever": {
        "Primary": {
            "Lats": 50,
            "Abdominals": 30
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Band Assisted Dips": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Banded"
    },
    "Band Assisted Muscle up": {
        "Primary": {
            "Lats": 40,
            "Biceps": 30
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Banded"
    },
    "Bar Shoulder Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 10
        },
        "Secondary": {
            "Triceps": 30,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Barbell Close Grip Bench Press": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Decline Close Grip To Skull Press": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Incline Close Grip Bench Press": {
        "Primary": {
            "Upper Chest": 50,
            "Triceps": 40
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell JM Bench Press": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Battle Ropes": {
        "Primary": {
            "Front Delts": 20,
            "Side Delts": 20,
            "Arms": 30
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "Weighted"
    },
    "Bodyweight Kneeling Triceps Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Bodyweight"
    },
    "Cable Concentration Extension (on knee)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Machine Lat Pulldowns": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 15,
            "Traps": 10,
            "Rhomboids": 5
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Twisted Flyes": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Lever Chest Press (plate loaded)": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Bench Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Behind Back Finger Curl": {
        "Primary": {
            "Forearms": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Lever Incline Chest Press (plate loaded)": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Single Leg Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Reverse Preacher Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lever Pendulum Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Reverse Grip Curl (Straight bar)": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Brachialis": 30
        },
        "type": "Weighted"
    },
    "Side Lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Cable kickback": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Inner Biceps Curl": {
        "Primary": {
            "Biceps (short head)": 70
        },
        "Secondary": {
            "Biceps (long head)": 20,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Barbell Good Morning": {
        "Primary": {
            "Hamstrings": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Lever Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Cable One Arm High Pulley Overhead Triceps Extension": {
        "Primary": {
            "Triceps (long head)": 80
        },
        "Secondary": {
            "Triceps (lateral & medial heads)": 20
        },
        "type": "Weighted"
    },
    "Self Assisted Nordic Hamstring Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Weighted"
    },
    "Barbell Stiff Legged Deadlift": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Barbell Hip Thrust": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Lever Seated Leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Supine Reverse Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Kettlebell Russian Twist": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Abdominals": 40
        },
        "type": "Weighted"
    },
    "Dumbbell Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Weighted Russian Twist (legs up)": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "Weighted"
    },
    "Barbell Spider Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Lever Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Prone Incline Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "EZ Barbell Close grip Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Decline Hammer Press": {
        "Primary": {
            "Lower Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Curl (V Bar)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One arm Revers Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Cable Reverse grip Pushdown": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Seated Neutral Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Rear Lateral Raise": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Neutral Grip Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Reverse Crunch": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "Bodyweight"
    },
    "Dumbbell Full Can Lateral Raise": {
        "Primary": {
            "Side Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Bent Leg Kickback (kneeling)": {
        "Primary": {

            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Cable Seated Shoulder Internal Rotation": {
        "Primary": {
            "Subscapularis": 70
        },
        "Secondary": {
            "Chest": 20,
            "Lats": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Romanian Deadlift": {
        "Primary": {
            "Hamstrings": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "EZ Barbell Reverse Grip Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Brachialis": 30
        },
        "type": "Weighted"
    },
    "Barbell Incline Row": {
        "Primary": {
            "Rhomboids": 30,
            "Traps": 30,
        },
        "Secondary": {
            "Biceps": 30,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Reverse Grip Biceps Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Brachialis": 30
        },
        "type": "Weighted"
    },
    "Archer Push up": {
        "Primary": {
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 40
        },
        "type": "Weighted"
    },
    "Wall Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Resistance Band Seated Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Banded"
    },
    "Cable Standing Alternate Low Fly": {
        "Primary": {
            "Lower Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Prone Incline Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Hanging Toes to Bar": {
        "Primary": {
            "Abdominals": 50,
            "Lats": 30
        },
        "Secondary": {
            "Hip Flexors": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Front Raise": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Side Delts": 30
        },
        "type": "Weighted"
    },
    "Seated Flutter Kick": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Barbell Shrug": {
        "Primary": {
            "Traps": 80
        },
        "Secondary": {
            "Rhomboids": 20
        },
        "type": "Weighted"
    },
    "Barbell Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Cable High Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Seated Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearm": 10
        },
        "type": "Weighted"
    },
    "Barbell Pin Presses": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Overhead Triceps Extension (Straight Bar)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Cable Seated High Row (V bar)": {
        "Primary": {
            "Rhomboids": 30,
            "Trapezius": 30
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Lateral Raise": {
        "Primary": {
            "Side Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Triceps Dips Floor": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Bodyweight"
    },
    "Dumbbell Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Donkey Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Standing One Arm Triceps Pushdown (Overhand Grip)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Palms Up Wrist Curl Over A Bench": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Smith Close Grip Bench Press": {
        "Primary": {
            "Triceps": 60,
            "Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Decline Pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Resistance Band Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Banded"
    },
    "Cable Incline Pushdown": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Goblet Curtsey Lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Reverse Grip Press": {
        "Primary": {
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Half Kneeling Push Pull": {
        "Primary": {
            "Chest": 40,
            "Back": 40
        },
        "Secondary": {
            "Triceps": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "EZ Barbell Incline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Lever Incline Hammer Chest Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Kettlebell Swing": {
        "Primary": {
            "Glutes": 50,
            "Hamstrings": 30
        },
        "Secondary": {
            "Erectors": 10,
            "Abdominals": 10
        },
        "type": "Weighted"
    },
    "Smith Sumo Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Cable Upright Row": {
        "Primary": {
            "Traps": 50,
            "Side Delts": 40
        },
        "Secondary": {
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Neutral Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Lever Standing Rear Kick": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Concentration Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Bent Over Reverse Grip Row": {
        "Primary": {
            "Lats": 60,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Rear Delt Row": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Biceps": 10
        },
        "type": "Weighted"
    },

    "Dumbbell Low Fly": {
        "Primary": {
            "Lower Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Weighted Seated Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Bodyweight Kneeling Sissy Squat": {
        "Primary": {
            "Quads": 80
        },
        "Secondary": {
            "Knee Joint": 20
        },
        "type": "Bodyweight"
    },
    "Lever Donkey Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Weighted Seated Reverse Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Cable Assisted Nordic Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Glutes": 10,
            "Erectors": 10
        },
        "type": "Banded"
    },
    "Resistance Band Assisted Nordic Hamstring Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Glutes": 10,
            "Erectors": 10
        },
        "type": "Banded"
    },
    "Cable Standing Chest Press": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Triceps": 15,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Barbell Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Biceps Curl Reverse Grip": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Standing Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Barbell Palms Down Wrist Curl Over A Bench": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Elbow to Knee": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Abdominals": 40
        },
        "type": "Weighted"
    },
    "Smith Bent Knee Good morning": {
        "Primary": {
            "Hamstrings": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Hip Raise (bent knee)": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Barbell Straight Leg Deadlift": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Landmine Romanian Deadlift": {
        "Primary": {
            "Hamstrings": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Dumbbell RDL Death March": {
        "Primary": {
            "Hamstrings": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Cable Seated One Arm Concentration Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "EZ bar Biceps Curl (with arm blaster)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Middle Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Barbell Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Weighted Sissy Squat": {
        "Primary": {
            "Quads": 80
        },
        "Secondary": {
            "Knee Joint": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lever Seated Squat Calf Raise on Leg Press Machine": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Quads": 10
        },
        "type": "Weighted"
    },
    "Diamond Press": {
        "Primary": {
            "Triceps": 60,
            "Inner Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Trap Bar Deadlift": {
        "Primary": {
            "Quads": 40,
            "Hamstrings": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Cable Cross over Revers Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Sled Lying Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Hammer Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Smith Seated Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Lever Crossovers": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Barbell Standing Reverse Grip Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Brachialis": 30
        },
        "type": "Weighted"
    },
    "Weighted Cossack Squats": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Band face pull": {
        "Primary": {
            "Rear Delts": 60,
            "Traps": 30
        },
        "Secondary": {
            "Rhomboids": 10
        },
        "type": "Banded"
    },
    "Dumbbell Standing Concentration Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Seated Pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Smith Standing Back Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Seated Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Finger Push up": {
        "Primary": {
            "Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Russian Twist": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Abdominals": 40
        },
        "type": "Weighted"
    },
    "Barbell Behind Back Finger Curl": {
        "Primary": {
            "Forearms": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Back Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Barbell Lunge": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Hammer Preacher Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Cable Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Decline Bench Press": {
        "Primary": {
            "Lower Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable One Arm Reverse Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Deadlift": {
        "Primary": {
            "Hamstrings": 40,
            "Quads": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Lever Deadlift": {
        "Primary": {
            "Hamstrings": 40,
            "Quads": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Lever Horizontal One leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Weighted Curtsey Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Curtsey Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 20
        },
        "type": "Bodyweight"
    },
    "Cable Drag Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Weighted Pistol Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 25,
            "Hamstrings": 15,
        },
        "type": "Weighted"
    },
    "Dumbbell Goblet Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Kicks Leg Bent": {
        "Primary": {
            "Hamstrings": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Barbell Bent Arm Pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Barbell Seated Good morning": {
        "Primary": {
            "Hamstrings": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Lying Scissor Kick": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Cable Overhead Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell side lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Barbell Reverse Grip Incline Bench Row": {
        "Primary": {
            "Rhomboids": 30,
            "Trapezius": 30,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Lever Chest Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Incline Fly": {
        "Primary": {
            "Upper Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable One Arm Side Triceps Pushdown": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Incline Cross Rear Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Reverse Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Cable Seated Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Hyght Dumbbell Fly": {
        "Primary": {
            "Upper Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable Upper Chest Crossovers": {
        "Primary": {
            "Upper Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Barbell Rear Delt Raise": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Lateral Raise": {
        "Primary": {
            "Side Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Alternate Biceps Curl (with arm blaster)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Single Arm Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Cable Lying Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Lying Back of the Head Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Underhand Seal Row": {
        "Primary": {
            "Biceps": 60
        },
        "Secondary": {
            "Lats": 20,
            "Rear Delts": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Bulgarian Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Fly (Chest Supported)": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable One Arm Lateral Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 20,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Reverse Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lever Leg Extension (plate loaded)": {
        "Primary": {
            "Quads": 90
        },
        "Secondary": {
            "Knee Joint Stability": 10
        },
        "type": "Weighted"
    },
    "Band Standing Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Banded"
    },
    "Cable Kneeling Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "EZ Bar Standing French Press": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Fly": {
        "Primary": {
            "Upper Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Tiger Tail Hamstring": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Calves": 30
        },
        "type": "Weighted"
    },
    "Sled Calf Press On Leg Press": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Quads": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Lunge": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Incline Skull Crusher": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Barbell Decline wide grip pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Over Bench One Arm Reverse Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Cable High Pulley Overhead Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Incline Triceps Extension Skull Crusher": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Cable Hammer Curl (Rope)": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Alternate Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Scissors (advanced)": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Barbell Standing Close Grip Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Lever Standing Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "type": "Weighted"
    },
    "Barbell Reverse Preacher Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Barbell Reverse Grip Bent over Row": {
        "Primary": {
            "Lats": 60,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Seal Row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Lying Scissor Crunch": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Bodyweight"
    },
    "Kneeling Hip Flexor": {
        "Primary": {
            "Hip Flexors": 70
        },
        "Secondary": {
            "Quads": 30
        },
        "type": "Weighted"
    },
    "Cable Rope Hammer Preacher Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "EZ Bar California Skullcrusher": {
        "Primary": {
            "Triceps (long head)": 80
        },
        "Secondary": {
            "Triceps (lateral & medial heads)": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Low Fly": {
        "Primary": {
            "Lower Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Squeeze Bench Press": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Triceps": 15,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Smith Machine Incline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },

    "EZ Barbell Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Barbell Sumo Deadlift": {
        "Primary": {
            "Quads": 40,
            "Hamstrings": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Cable Seated Chest Press": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Triceps": 15,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Lever Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Kettlebell Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
     "Kettlebell Front Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 25,
            "Hamstrings": 15
        },
        "type": "Weighted"
    },
    "Kettlebell Sumo Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Barbell Seated Overhead Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline T Raise": {
        "Primary": {
            "Rear Delts": 60,
            "Side Delts": 30
        },
        "Secondary": {
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Decline Push Up": {
        "Primary": {
            "Upper Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Cocoons": {
        "Primary": {
            "Abdominals": 50,
            "Obliques": 40
        },
        "Secondary": {
            "Hip Flexors": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Reverse Preacher Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable One Arm Triceps Pushdown": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Seated Leg Raise": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
        },
        "type": "Weighted"
    },
    "Dumbbell Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Close grip Press Variation": {
        "Primary": {
            "Upper Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Low Fly": {
        "Primary": {
            "Lower Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Weighted One Leg Hip Thrust": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "EZ Barbell Seated Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbells Seated Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Around Pullover": {
        "Primary": {
            "Lats": 50,
            "Chest": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (V bar) (with arm blaster)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Hack Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Hand Spring Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Rear Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Sit (wall)": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Cable Close Grip Lat Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 20,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Prone Incline Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Barbell Bent Over Row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Barbell Front Raise and Pullover": {
        "Primary": {
            "Front Delts": 40,
            "Lats": 40
        },
        "Secondary": {
            "Triceps": 10,
            "Chest": 10
        },
        "type": "Weighted"
    },
    "Smith Lateral Step Up": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "EZ bar Close Grip Bench Press": {
        "Primary": {
            "Triceps": 60,
            "Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Wide Reverse Grip Bench Press": {
        "Primary": {
            "Upper Chest": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Face Pull (Rope)": {
        "Primary": {
            "Rear Delts": 60,
            "Traps": 30
        },
        "Secondary": {
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Alternate Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Y Raise": {
        "Primary": {
            "Upper Traps": 50,
            "Side Delts": 40
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Deadlift": {
        "Primary": {
            "Hamstrings": 40,
            "Quads": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Weighted Seated Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "type": "Weighted"
    },
    "Lever Seated Leg Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Weighted"
    },
    "Barbell Front Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Seated Rear Lateral Raise": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Decline Bent Leg Reverse Crunch": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "Bodyweight"
    },
    "Cable Kneeling One Arm Lat Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 20,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Negative Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "Dumbbell Seated Palms Up Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Barbell Glute Bridge": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Cable Pull Through (Rope)": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Zottman Preacher Curl": {
        "Primary": {
            "Biceps": 45,
            "Brachialis": 35
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Stiff Leg Deadlift from Stepbox": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Inner Biceps Curl": {
        "Primary": {
            "Biceps (short head)": 70
        },
        "Secondary": {
            "Biceps (long head)": 20,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Drag Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Lying Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Barbell Lying Triceps Extension Skull Crusher": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Deadlift": {
        "Primary": {
            "Hamstrings": 40,
            "Quads": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Handboard Hang with 135 Degree Elbow": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Bench Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "EZ Barbell Standing Wide Grip Biceps Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Biceps": 20,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "type": "Weighted"
    },
    "Barbell Standing Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "type": "Weighted"
    },
    "Barbell Behind The Back Shrug": {
        "Primary": {
            "Traps": 90
        },
        "Secondary": {
            "Rhomboids": 10,
        },
        "type": "Weighted"
    },
    "Biceps Leg Concentration Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Weighted"
    },
    "Weighted Seated One Arm Reverse Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Barbell High Bar Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Incline Chest Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Alternate Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Decline Crunch": {
        "Primary": {
            "Upper Abdominals": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "Bodyweight"
    },
    "Lever Alternate Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Smith Lunge": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "EZ Barbell Seated Curls": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Standing Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Pullover": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Chest": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Push up": {
        "Primary": {
            "Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Twisted Fly": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "EZ Barbell Decline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Upper Chest": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Standing One Arm Reverse Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Cable Crossover Variation": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable One Arm Bent over Row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Barbell Romanian Deadlift": {
        "Primary": {
            "Hamstrings": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "EZ Bar Lying Close Grip Triceps Extension Behind Head": {
        "Primary": {
            "Triceps (long head)": 80
        },
        "Secondary": {
            "Triceps (lateral & medial heads)": 20
        },
        "type": "Weighted"
    },
    "Lever Decline Chest Press": {
        "Primary": {
            "Lower Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Bench Dip": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Bodyweight"
    },
    "Cable Rope High Pulley Overhead Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Sumo Romanian Deadlift": {
        "Primary": {
            "Hamstrings": 60,
            "Adductors": 30
        },
        "Secondary": {
            "Glutes": 10
        },
        "type": "Weighted"
    },
    "Lever Seated Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "Smith Front Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Smith Hack Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Sled One Leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Decline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Upper Chest": 20
        },
        "type": "Weighted"
    },
    "Smith Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Stiff Leg Deadlift": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },

    "Dumbbell Rotation Reverse Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Inner Curl": {
        "Primary": {
            "Biceps (short head)": 70
        },
        "Secondary": {
            "Biceps (long head)": 20,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Lying Triceps Extension (Rope)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Cable Rope Incline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Alternate Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Low Seated Row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Front Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "EZ Bar Seated Close Grip Concentration Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Lever Triceps Dip (plate loaded)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Bodyweight"
    },
    "Lever Hip Thrust": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Rear Delt Raise": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Barbell Reverse Grip Skullcrusher": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Alternate Front Raise": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Side Delts": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Decline Bench Press": {
        "Primary": {
            "Lower Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Lever Preacher Curl (plate loaded)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Cable Reverse Wrist Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Decline Fly": {
        "Primary": {
            "Lower Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Squat (Bodyweight)": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Reverse Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Hamstring Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Weighted"
    },
    "Smith Stiff Legged Deadlift": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Lever Seated Horizontal Leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Cable Rear Drive": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Reverse Curl": {
        "Primary": {
            "Brachialis": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Barbell Seated Close grip Concentration Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Peacher Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Side Lying Clam": {
        "Primary": {
            "Hip Abductors": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Cable Seated Rear Delt Fly with Chest Support": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Landmine Front Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Cross Body Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Hanging Leg Raise": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
        },
        "type": "Weighted"
    },
    "Cable Kneeling External Rotation": {
        "Primary": {
            "Rotator Cuff": 80
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Cable seated row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Hack Squat": {
        "Primary": {
            "Quads": 60,
            "Adductors": 30
        },
        "Secondary": {
            "Glutes": 10
        },
        "type": "Weighted"
    },
    "Otis Up": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Biceps": 30,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Guillotine Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Decline Wide grip Press": {
        "Primary": {
            "Lower Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Lateral Raise": {
        "Primary": {
            "Side Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Front Raise": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Side Delts": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Elbow Press": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One arm Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Barbell Biceps Curl (with arm blaster)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Svend Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Reverse Spider Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Palm in Press": {
        "Primary": {
            "Triceps": 60,
            "Upper Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Two Arm Lateral Raise": {
        "Primary": {
            "Side Delts": 70
        },
        "Secondary": {
            "Traps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Tate Press": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Triceps Press": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Cable Neutral Grip Lat Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 20,
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Single Leg Step up": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Barbell Standing Overhead Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Barbell Wide Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Smith Deadlift": {
        "Primary": {
            "Hamstrings": 40,
            "Quads": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Knee Touch Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "V up": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
        },
        "type": "Weighted"
    },
    "Cable Standing Front Raise Variation": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Side Delts": 30
        },
        "type": "Weighted"
    },
    "Barbell Wide Shrug": {
        "Primary": {
            "Traps": 80
        },
        "Secondary": {
            "Rhomboids": 20
        },
        "type": "Weighted"
    },
    "Squat (with band)": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Barbell Rack Pull": {
        "Primary": {
            "Rhomboids": 20,
            "Trapezius": 30,
            "Erectors": 50
        },
        "Secondary": {
            "Hamstrings": 10,
            "Glutes": 10
        },
        "type": "Weighted"
    },
    "Kettlebell Goblet Curtsey Lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Triceps Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Lever Seated Dip": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Cable Standing Wrist Reverse Curl": {
        "Primary": {
            "Forearms (extensors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Nordic Hamstring Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Glutes": 10,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Barbell Front Raise": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Side Delts": 30
        },
        "type": "Weighted"
    },
    "Weighted Triceps Dips": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Weighted"
    },
    "EZ Barbell Reverse grip Preacher Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Lever Overhand Triceps Dip": {
        "Primary": {
            "Triceps": 70,
            "Chest": 20
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Bent Over Row": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Rhomboids": 15,
            "Traps": 15
        },
        "type": "Weighted"
    },
    "Smith Hip Thrust": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Hanging Oblique Knee Raise": {
        "Primary": {
            "Obliques": 80
        },
        "Secondary": {
            "Abdominals": 20
        },
        "type": "Weighted"
    },
    "Weighted Standing Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lever seated Single Leg Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Alternate Oblique Crunch": {
        "Primary": {
            "Obliques": 80
        },
        "Secondary": {
            "Abdominals": 20
        },
        "type": "Bodyweight"
    },
    "Barbell Seated Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Cable Lateral Raise": {
        "Primary": {
            "Side Delts": 85
        },
        "Secondary": {
            "Front Delts": 10,
            "Traps": 5
        },
        "type": "Weighted"
    },
    "Diamond Push up (on knees)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Smith Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 15,
            "Hamstrings": 15
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Kettlebell Farmers Carry": {
        "Primary": {
            "Forearms": 50
        },
        "Secondary": {
            "Traps": 25,
            "Abdominals": 10,
            "Obliques": 15
        },
        "type": "Weighted"
    },
    "Cable Seated Row (Bent bar)": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Rhomboids": 10,
            "Traps": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Cable Incline Bench Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Front Delts": 15,
            "Triceps": 15
        },
        "type": "Weighted"
    },
    "Incline Twisting Situp": {
        "Primary": {
            "Abdominals": 35,
            "Obliques": 35
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Seated One Arm Triceps Extension": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Lats": 10
        },
        "type": "Weighted"
    },
    "Hand Opposite Knee Crunch": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "Bodyweight"
    },
    "Cable Seated Floor One Arm Concentration Curl": {
        "Primary": {
            "Biceps": 90
        },
        "Secondary": {
            "Brachialis": 5,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lying Leg Raise": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Sit up": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Lever Calf Press": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Barbell Upright Row": {
        "Primary": {
            "Traps": 30,
            "Side Delts": 30
        },
        "Secondary": {
            "Biceps": 20,
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Hammer Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Front Delts": 15,
            "Triceps": 15
        },
        "type": "Weighted"
    },
    "Barbell Drag Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Weighted Seated Tuck Crunch on Floor": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 15,
            "Obliques": 15
        },
        "type": "Bodyweight"
    },
    "Dumbbell Incline Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Seated Row (Rope)": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Rhomboids": 10,
            "Traps": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Barbell Incline Bench Press": {
        "Primary": {
            "Upper Chest": 70
        },
        "Secondary": {
            "Front Delts": 15,
            "Triceps": 15
        },
        "type": "Weighted"
    },
    "Barbell Decline Bent Arm Pullover": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Chest": 15,
            "Triceps": 15
        },
        "type": "Weighted"
    },
    "Smith Leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 10,
            "Hamstrings": 10,
            "Calves": 10
        },
        "type": "Weighted"
    },
    "Cable Pulldown Bicep Curl": {
        "Primary": {
            "Lats": 25,
            "Biceps": 25
        },
        "Secondary": {
            "Forearms": 50
        },
        "type": "Weighted"
    },
    "Cable Seated Face Pull (Rope)": {
        "Primary": {
            "Rear Delts": 35,
            "Traps": 35
        },
        "Secondary": {
            "Rhomboids": 15,
            "Rotator Cuff": 15
        },
        "type": "Weighted"
    },
    "Cable Cross over Lateral Pulldown": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Rear Delts": 15,
            "Biceps": 15
        },
        "type": "Weighted"
    },
    "Sled Leg Press": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 10,
            "Hamstrings": 10,
            "Calves": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Step up": {
        "Primary": {
            "Quads": 40,
            "Glutes": 40
        },
        "Secondary": {
            "Hamstrings": 10,
            "Calves": 10,
        },
        "type": "Weighted"
    },
    "Tuck Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Hip Flexors": 10,
            "Obliques": 10
        },
        "type": "Bodyweight"
    },
    "Dumbbell Close Grip Press": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 15,
            "Front Delts": 15
        },
        "type": "Weighted"
    },
    "Barbell Standing Back Wrist Curl": {
        "Primary": {
            "Forearm Extensors": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Cable Reverse Preacher Curl": {
        "Primary": {
            "Brachialis": 70
        },
        "Secondary": {
            "Biceps": 15,
            "Forearms": 15
        },
        "type": "Weighted"
    },
    "EZ bar Drag Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Smith Machine Decline Close Grip Bench Press": {
        "Primary": {
            "Lower Chest": 35,
            "Triceps": 35
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Barbell Stiff Leg Good Morning": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 10,
            "Erectors": 20,
        },
        "type": "Weighted"
    },
    "Dumbbell Standing Zottman Preacher Curl": {
        "Primary": {
            "Biceps": 45,
            "Brachialis": 35
        },
        "Secondary": {
            "Forearms": 20,
        },
        "type": "Weighted"
    },
    "Dumbbell Zottman Curl": {
        "Primary": {
            "Biceps": 45,
            "Brachialis": 35
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Seated Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "Barbell Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Biceps Curl (EZ bar)": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Hammer Curl": {
        "Primary": {
            "Brachialis": 25,
            "Biceps": 25
        },
        "Secondary": {
            "Forearms": 50
        },
        "type": "Weighted"
    },
    "EZ Barbell Standing Wrist Reverse Curl": {
        "Primary": {
            "Forearm Extensors": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Lever Total Abdominal Crunch": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 15,
            "Obliques": 15
        },
        "type": "Bodyweight"
    },
    "Cable Incline Bench Row": {
        "Primary": {
            "Lats": 60,
            "Rhomboids": 10,
            "Trapezius": 10
        },
        "Secondary": {
            "Rear Delts": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Side Bend": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Lats": 15,
            "Erectors": 15
        },
        "type": "Weighted"
    },
    "EZ Barbell JM Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Oblique Crunches Floor": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "Bodyweight"
    },
    "EZ Barbell Close Grip Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Single Arm Lateral Raise": {
        "Primary": {
            "Side Delts": 80
        },
        "Secondary": {
            "Front Delts": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Cable Single Arm Neutral Grip Front Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 10,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Crossover Face Pull": {
        "Primary": {
            "Rear Delts": 60,
            "Traps": 20
        },
        "Secondary": {
            "Rhomboids": 10,
            "Rotator Cuff": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Hammer Curls (with arm blaster)": {
        "Primary": {
            "Brachialis": 50,
            "Biceps": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Cable Front Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
    },
    "Jump Squat": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10,
            "Calves": 10
        },
        "type": "Weighted"
    },
    "Diamond Push up": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Lying Rear Lateral Raise": {
        "Primary": {
            "Rear Delts": 80
        },
        "Secondary": {
            "Traps": 10,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Cable Reverse One Arm Curl": {
        "Primary": {
            "Brachialis": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Barbell One Arm Bent over Row": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Rear Delts": 15,
            "Biceps": 15
        },
        "type": "Weighted"
    },
    "Barbell Incline Lying Rear Delt Raise": {
        "Primary": {
            "Rear Delts": 80
        },
        "Secondary": {
            "Traps": 10,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Sissy Squat Bodyweight": {
        "Primary": {
            "Quads": 90
        },
        "Secondary": {
            "Calves": 10
        },
        "type": "Bodyweight"
    },
    "EZ Barbell Standing Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 20
        },
        "type": "Weighted"
    },
    "Lever Hammer Grip Preacher Curl": {
        "Primary": {
            "Brachialis": 50,
            "Biceps": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Cross Body Crunch": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "Bodyweight"
    },
    "Resistance Band Side Walk": {
        "Primary": {
            "Hip Abductors": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Banded"
    },
    "EZ Barbell Spider Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 10,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Cable Y raise": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Dumbbell Lying Supine Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Standing Up Straight Crossovers": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Glute Ham Raise": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 15,
            "Calves": 15
        },
        "type": "Weighted"
    },
    "Sumo Squat": {
        "Primary": {
            "Quads": 40,
            "Glutes": 30,
            "Adductors": 20
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Barbell Sumo Squat": {
        "Primary": {
            "Quads": 40,
            "Glutes": 30,
            "Adductors": 20
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Handboard Slope Hang": {
        "Primary": {
            "Forearms": 50,
            "Grip Strength": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Dumbbell Bent Over Alternate Rear Delt Fly": {
        "Primary": {
            "Rear Delts": 80
        },
        "Secondary": {
            "Traps": 10,
            "Rhomboids": 10
        },
        "type": "Weighted"
    },
    "Barbell Pendlay Row": {
        "Primary": {
            "Lats": 60,
            "Traps": 20
        },
        "Secondary": {
            "Rhomboids": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Hip Thrusts": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Hammer Preacher Curl": {
        "Primary": {
            "Brachialis": 50,
            "Biceps": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Dumbbell Incline Front Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Standing Hammer Curl": {
        "Primary": {
            "Brachialis": 50,
            "Biceps": 50
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Dumbbell Straight Arm Pullover": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Chest": 15,
            "Triceps": 15
        },
        "type": "Weighted"
    },
    "Barbell Narrow Row": {
        "Primary": {
            "Lats": 60,
            "Traps": 20
        },
        "Secondary": {
            "Rhomboids": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Barbell Lying Close grip Press": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Elevanted Push Up": {
        "Primary": {
            "Chest": 50,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Bodyweight"
    },
    "Dumbbell Reverse Bench Press": {
        "Primary": {
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Close Grip Push up": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Front Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Seated Chest Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Bench Reverse Crunch Circle": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 20,
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "Dumbbell Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Single Arm Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Bent Over Bench Row": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Rear Delts": 15,
            "Biceps": 20,
            "Traps": 15
        },
        "type": "Weighted"
    },
    "Lying T-Bar Row": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Rear Delts": 10,
            "Biceps": 20,
            "Traps": 20
        },
        "type": "Weighted"
    },
    "Rear Delt Fly (Machine)": {
        "Primary": {
            "Rear Delts": 80
        },
        "Secondary": {
            "Traps": 20
        },
        "type": "Weighted"
    },
    "Chest Dips": {
        "Primary": {
            "Triceps": 25,
            "Chest": 65
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Triceps Dips": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Assisted Chest Dips": {
        "Primary": {
            "Triceps": 25,
            "Chest": 65
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Assisted"
    },
    "Assisted Triceps Dips": {
        "Primary": {
            "Triceps": 65,
            "Chest": 25
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Assisted"
    },
    "Weighted Neutral Grip Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Assisted Neutral Grip Pull Ups": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Assisted"
    },
    "Neutral Grip Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Commando Pull Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Band Assisted One Arm Chin Up": {
        "Primary": {
            "Lats": 40
        },
        "Secondary": {
            "Biceps": 35,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Banded"
    },
    "Weighted One Handed Pull Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Close Grip Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Archer Pull Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Chin Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Close Grip Chin Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Band Assisted Chin Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Banded"
    },
    "Assisted Close Grip Chin Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Assisted"
    },
    "Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "Single Arm Pull Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Bodyweight"
    },
    "L-Pull Ups": {
        "Primary": {
            "Lats": 40
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10,
            "Abdominals": 10
        },
        "type": "Weighted"
    },
    "Weighted Chin Up": {
        "Primary": {
            "Lats": 45
        },
        "Secondary": {
            "Biceps": 30,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Assisted Chin up": {
        "Primary": {
            "Lats": 50,
            "Biceps": 40
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Assisted"
    },
    "Back Extensions": {
        "Primary": {
            "Erectors": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Barbell Bent Over Wide Grip Row": {
        "Primary": {
            "Rhomboids": 30,
            "Trapezius": 30,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 10
        },
        "type": "Weighted"
    },
    "Barbell Deadstop Row": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Erectors": 20
        },
        "type": "Weighted"
    },
    "Barbell Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Barbell Reverse Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Cable Decline Fly": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Hip Abduction": {
        "Primary": {
            "Glutes": 80
        },
        "Secondary": {
            "Outer Thighs": 20
        },
        "type": "Weighted"
    },
    "Cable Kneeling High Row (Rope)": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Cable Lateral Pulldown (Rope)": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
    },
    "Cable Lateral Pulldown (V Bar)": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
    },
    "Cable Lying Biceps Curl": {
        "Primary": {
            "Biceps": 75
        },
        "Secondary": {
            "Forearms": 25
        },
        "type": "Weighted"
    },
    "Cable Lying Extension Pullover (Rope)": {
        "Primary": {
            "Lats": 50,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable One Arm Biceps Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Cable Overhead Single Arm Triceps Extension (Rope)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Overhead Triceps Extension (Rope)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (Rope)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Reverse Grip Pulldown": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
    },
    "Cable Single Arm Triceps Pushdown (Rope)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Standing High Cross Triceps Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (V Bar)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Bayesian Curl": {
        "Primary": {
            "Front Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Chest Dip": {
        "Primary": {
            "Triceps": 25,
            "Chest": 65
        },
        "Secondary": {
          "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Cobra Push Up": {
        "Primary": {
            "Triceps": 60,
            "Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Bodyweight"
    },
    "Dumbbell Cuban Press": {
        "Primary": {
            "Side Delts": 40,
            "Front Delts": 20,
            "Traps": 30
        },
        "Secondary": {
            "Triceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Devils Press": {
        "Primary": {
            "Chest": 40,
            "Front Delts": 30
        },
        "Secondary": {
            "Triceps": 20,
            "Quads": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Lying One Arm Press": {
        "Primary": {
            "Chest": 50,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Dumbbell One Arm Reverse Fly (with support)": {
        "Primary": {
            "Rear Delts": 60
        },
        "Secondary": {
            "Traps": 30,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Reverse Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Bench Triceps Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Side Lunge": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Walking Lunges": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Finger Curls": {
        "Primary": {
            "Forearms": 100
        },
        "type": "Weighted"
    },
    "Kettlebell Step Up": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Kneeling Push Up": {
        "Primary": {
            "Chest": 50,
            "Lats": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Bodyweight"
    },
    "Landmine Rear Lunge": {
        "Primary": {
            "Glutes": 50,
            "Quads": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Lever Hip Extension": {
        "Primary": {
            "Glutes": 60
        },
        "Secondary": {
            "Erectors": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Lever Incline Chest Press": {
        "Primary": {
            "Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Lever Leg Extension": {
        "Primary": {
            "Quads": 100
        },
        "type": "Weighted"
    },
    "Lever Lying Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Lever Lying Single Leg Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Lever Seated Hip Adduction": {
        "Primary": {
            "Adductors": 80
        },
        "Secondary": {
            "Glutes": 20
        },
        "type": "Weighted"
    },

    "Lever Seated One Leg Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Machine Back Extension": {
        "Primary": {
            "Erectors": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Machine Shoulder Press": {
        "Primary": {
            "Front Delts": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "One Leg Floor Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {
        },
        "type": "Weighted"
    },
    "Single Leg Leg Extension": {
        "Primary": {
            "Quads": 100
        },
        "type": "Weighted"
    },
    "Resistance Band Bent Leg Kickback (Kneeling)": {
        "Primary": {
            "Glutes": 60
        },
        "Secondary": {
            "Hamstrings": 30,
            "Erectors": 10
        },
        "type": "Banded"
    },
    "Resistance Band Leg Extension": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Banded"
    },
    "Resistance Band Leg Lift": {
        "Primary": {
            "Glutes": 60,
            "Quads": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Banded"
    },
    "Resistance Band Seated Single Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Banded"
    },
    "Seated Lever Machine Row": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Seated Machine Row": {
        "Primary": {
            "Lats": 50,
            "Biceps": 30
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Seated Overhead Press (Barbell)": {
        "Primary": {
            "Front Delts": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Single Leg Hip Thrust": {
        "Primary": {
            "Glutes": 60
        },
        "Secondary": {
            "Hamstrings": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Pistol Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Sit Up": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Smith Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {
        },
        "type": "Weighted"
    },
    "Smith Machine Standing Overhead Press": {
        "Primary": {
            "Front Delts": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Upper Chest": 10
        },
        "type": "Weighted"
    },
    "Suspender Arm Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Suspender Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Suspender Straight Hip Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "Weighted"
    },
    "Suspender Triceps Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Walking Lunge": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Weighted Crunch": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Bodyweight"
    },
    "Weighted Push Up": {
        "Primary": {
            "Chest": 50,
            "Front Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Bodyweight"
    },
    "Cable Seated Horizontal Shrug": {
        "Primary": {
            "Traps": 70
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Shrug": {
        "Primary": {
            "Traps": 80
        },
        "Secondary": {
            "Rhomboids": 20
        },
        "type": "Weighted"
    },
    "Incline Shrug": {
        "Primary": {
            "Traps": 80
        },
        "Secondary": {
            "Rhomboids": 20
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (EZ bar)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (Straight Bar)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (V bar)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Over Bench Neutral Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Over Bench Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Over Bench Reverse Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Over Bench One Arm Wrist Curl": {
        "Primary": {
            "Forearms": 70
        },
        "Secondary": {
            "Biceps": 30
        },
        "type": "Weighted"
    },
    "Machine Chest Fly": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable Pullover": {
    "Primary": {
        "Lats": 70
    },
    "Secondary": {
        "Chest": 15,
        "Triceps": 15
    },
    "type": "Weighted"
  },
  "Incline Chest Supported Row (Dumbbell)": {
    "Primary": {
        "Rhomboids": 50
    },
    "Secondary": {
        "Lats": 20,
        "Rear Delts": 15,
        "Biceps": 15
    },
    "type": "Weighted"
  },
    "Assault Bike": {
        "Primary": {
            "Quads": 35,
            "Hamstrings": 25,
            "Glutes": 15,
            "Calves": 10
        },
        "Secondary": {
            "Forearms": 5,
            "Biceps": 5,
            "Rectus Abdominis": 10,
        },
        "type": "Timed"
    },
    "Barbell Behind the Back Wrist Curls": {
        "Primary": {
            "Forearms": 90
        },
        "Secondary": {
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Cable Behind the Back Wrist Curls": {
        "Primary": {
            "Forearms": 90
        },
        "Secondary": {
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Cable One Arm Row": {
        "Primary": {
            "Lats": 40,
            "Biceps": 20,
            "Rear Delts": 20
        },
        "Secondary": {
            "Forearms": 10,
            "Traps": 10,
            "Obliques": 5,
            "Rectus Abdominis": 5
        },
        "type": "Weighted"
    },
    "Cable Wide Grip Neutral Lat Pulldown": {
        "Primary": {
            "Lats": 50,
            "Biceps": 15,
            "Rear Delts": 15
        },
        "Secondary": {
            "Traps": 10,
            "Forearms": 10,
            "Rectus Abdominis": 5,
            "Obliques": 5
        },
        "type": "Weighted"
    },
    "Captain Seat Leg Raise": {
        "Primary": {
            "Rectus Abdominis": 50,
            "Obliques": 20,
            "Hip Flexors": 30
        },
        "Secondary": {},
        "type": "Bodyweight"
    },
    "Dead Hang": {
        "Primary": {
            "Forearms": 60,
        },
        "Secondary": {
            "Lats": 30,
            "Front Delts": 5,
            "Side Delts": 5,
            "Rear Delts": 5
        },
        "type": "Timed"
    },
    "Farmer Walk": {
        "Primary": {
            "Forearms": 40,
            "Traps": 20,
            "Rectus Abdominis": 10,
            "Obliques": 10
        },
        "Secondary": {
            "Quads": 10,
            "Glutes": 10
        },
        "type": "Distance"
    },
    "Low Cable Fly": {
        "Primary": {
            "Lower Chest": 55,
            "Front Delts": 35
        },
        "Secondary": {
            "Triceps": 10,
        },
        "type": "Weighted"
    },
    "Smith Machine Bench Press": {
        "Primary": {
            "Chest": 60,
        },
        "Secondary": {
            "Front Delts": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Smith Machine Incline Bench Press": {
        "Primary": {
            "Upper Chest": 60,
        },
        "Secondary": {
            "Front Delts": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Stationary Bike": {
        "Primary": {
            "Quads": 40,
            "Hamstrings": 30,
            "Glutes": 20
        },
        "Secondary": {
            "Calves": 10,
            "Rectus Abdominis": 10,
        },
        "type": "Timed"
    },
    "Weighted Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Wide Grip Overhand Row": {
        "Primary": {
            "Rhomboids": 50,
            "Traps": 30
        },
        "Secondary": {
            "Biceps": 10,
            "Lats": 10
        },
        "type": "Weighted"
    },
    "Stair Master": {
        "Primary": {
            "Quads": 40,
            "Glutes": 30,
            "Hamstrings": 20
        },
        "Secondary": {
            "Calves": 10,
            "Rectus Abdominis": 3
        },
        "type": "Timed"
    },
    "Assisted Pull Up": {
        "Primary": {
            "Lats": 50
        },
        "Secondary": {
            "Biceps": 25,
            "Rhomboids": 15,
            "Traps": 10
        },
        "type": "Assisted"
    },
    "Hip Abductor": {
        "Primary": {
            "Glutes": 90
        },
        "Secondary": {
            "Hip Flexors": 10
        },
        "type": "Machine"
    },
    "Crunch": {
        "Primary": {
            "Rectus Abdominis": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "Bodyweight"
    },
    "Dumbbell Seated Arnold Press": {
        "Primary": {
            "Front Delts": 40,
            "Side Delts": 40
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Reverse Concentration Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachioradialis": 40
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Incline Lever Chest Press": {
        "Primary": {
            "Upper Chest": 60
        },
        "Secondary": {
            "Front Delts": 20,
            "Triceps": 20
        },
        "type": "Weighted"
    },
    "Running": {
        "Primary": {
            "Quads": 30,
            "Hamstrings": 25,
            "Glutes": 25
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Timed"
    },
    "Walking": {
        "Primary": {
            "Glutes": 30,
            "Quads": 30
        },
        "Secondary": {
            "Calves": 20,
            "Hamstrings": 20
        },
        "type": "Timed"
    },
    "Jumping Jacks": {
        "Primary": {
            "Glutes": 30,
            "Quads": 30
        },
        "Secondary": {
            "Calves": 20,
            "Side Delts": 20
        },
        "type": "Timed"
    },
    "Plank": {
        "Primary": {
            "Abdominis": 60
        },
        "Secondary": {
            "Obliques": 20,
            "Front Delts": 15,
            "Glutes": 5
        },
        "type": "Bodyweight"
    },
    "Reverse Plank": {
        "Primary": {
            "Glutes": 40,
            "Hamstrings": 30
        },
        "Secondary": {
            "Lower Back": 15,
            "Front Delts": 10,
            "Triceps": 5
        },
        "type": "Bodyweight"
    },
    "Side Plank": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Glutes": 20,
            "Side Delts": 20
        },
        "type": "Bodyweight"
    },
    "Cable One Arm Preacher Curl": {
      "Primary": {
          "Biceps": 50,
          "Brachialis": 35
      },
      "Secondary": {
          "Forearms": 15
      },
      "type": "Weighted"
  },

  "Handstand Push Up": {
      "Primary": {
          "Front Delts": 60,
          "Triceps": 30
      },
      "Secondary": {
          "Side Delts": 5,
          "Traps": 5
      },
      "type": "Bodyweight"
  },
  "Lever Seated Single Leg Calf Raise": {
      "Primary": {
          "Gastrocnemius": 60,
          "Soleus": 30
      },
      "Secondary": {
          "Tibialis Anterior": 10
      },
      "type": "Weighted"
  },

  "Lever Seated Squat": {
      "Primary": {
          "Quads": 55,
          "Glutes": 35
      },
      "Secondary": {
          "Hamstrings": 10
      },
      "type": "Weighted"
  },

  "Single Arm Zottman Preacher Curl": {
      "Primary": {
          "Biceps": 45,
          "Brachialis": 35,
          "Brachioradialis": 10
      },
      "Secondary": {
          "Forearms": 10
      },
      "type": "Weighted"
  },

  "Wall Handstand": {
      "Primary": {
          "Front Delts": 50,
          "Triceps": 30
      },
      "Secondary": {
          "Side Delts": 10,
          "Traps": 10
      },
      "type": "Bodyweight"
  },

  "Weighted Wall Squat": {
      "Primary": {
          "Quads": 60,
          "Glutes": 25
      },
      "Secondary": {
          "Hamstrings": 10,
          "Core": 5
      },
      "type": "Weighted"
  },

  "Zottman Curl": {
      "Primary": {
          "Biceps": 45,
          "Brachialis": 35,
          "Brachioradialis": 10
      },
      "Secondary": {
          "Forearms": 10
      },
      "type": "Weighted"
  },
  "Cable Close Grip Curl": {
      "Primary": {
          "Biceps": 80
      },
      "Secondary": {
          "Forearms": 20
      },
      "type": "Weighted"
  },
};