import os


exerciseMuscles = {
'Cable Pushdown': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Standing Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Barbell Wide Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Cable Standing Rear Delt Horizontal Row': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Cable Two Arm Tricep Kickback': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
},
'Dumbbell Incline Twisted Flyes': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Front Deltoids': 30}
},

'Lever Chest Press (plate loaded)': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell Incline Bench Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell Behind Back Finger Curl': {
    'Primary': {'Forearms': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dip on Floor with Chair': {
    'Primary': {'Triceps': 60, 'Chest': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Lever Incline Chest Press (plate loaded)': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell Press Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Shoulders': 20}
},

'Dumbbell Single Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Dumbbell One Arm Reverse Preacher Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Dumbbell Single Leg Deadlift': {
    'Primary': {'Hamstrings': 50, 'Glutes': 30},
    'Secondary': {'Lower Back': 10, 'Balance & Stability': 10}
},

'Lever Seated Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
},

'Cable Standing Reverse Grip Curl (Straight bar)': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Side Lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable kickback': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
},

'Dumbbell Seated Inner Biceps Curl': {
    'Primary': {'Biceps (short head)': 70},
    'Secondary': {'Biceps (long head)': 20, 'Forearms': 10}
},

'Barbell Good Morning': {
    'Primary': {'Hamstrings': 60, 'Glutes': 30},
    'Secondary': {'Lower Back': 10}
},

'Lever Bicep Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Cable One Arm High Pulley Overhead Tricep Extension': {
    'Primary': {'Triceps (long head)': 80},
    'Secondary': {'Triceps (lateral & medial heads)': 20}
},

'Self assisted Inverse Leg Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Calves': 20}
},

'Dumbbell One Arm Chest Fly on Exercise Ball': {
    'Primary': {'Chest': 70},
    'Secondary': {'Front Deltoids': 20, 'Core': 10}
},

'Cross Body Twisting Crunch': {
    'Primary': {'Obliques': 60, 'Rectus Abdominis': 40}
},

'Barbell Stiff Legged Deadlift': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
},

'Sled 45 Leg Press (Back POV)': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Barbell Hip Thrust': {
    'Primary': {'Glutes': 80},
    'Secondary': {'Hamstrings': 20}
},

'Weighted Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Lever Seated Leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Kick out Sit (wall)': {
    'Primary': {'Core': 60},
    'Secondary': {'Hip Flexors': 30, 'Quads': 10}
},

'Cable Supine Reverse Fly': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Kettlebell Russian Twist': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Rectus Abdominis': 30, 'Core': 10}
},

'Handstand': {
    'Primary': {'Shoulders': 50},
    'Secondary': {'Core': 30, 'Triceps': 20}
},

'Dumbbell Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Weighted Russian Twist (legs up)': {
    'Primary': {'Obliques': 70},
    'Secondary': {'Rectus Abdominis': 30}
},

'Smith Front Squat (Clean Grip)': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Barbell Spider Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Lever Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Barbell Prone Incline Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'EZ Barbell Close grip Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Decline Hammer Press': {
    'Primary': {'Lower Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Cable Curl with Multipurpose V bar': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell One arm Revers Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Cable Front Seated Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Cable Reverse grip Pushdown': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Seated Supine grip Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Dumbbell One Arm Seated Neutral Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dumbbell Incline Rear Lateral Raise': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Dumbbell Neutral Grip Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Reverse Crunch m': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Obliques': 30}
},

'Dumbbell Full Can Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Front Deltoids': 10}
},

'Bent Leg Kickback (kneeling)': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
},

'Glute Bridge March': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 20, 'Core': 10}
},

'Assisted Hanging Knee Raise': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Hanging Leg Hip Raise': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Leg Raise Hip Lift': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Cable Seated Shoulder Internal Rotation': {
    'Primary': {'Subscapularis': 70},
    'Secondary': {'Pectoralis Major': 20, 'Latissimus Dorsi': 10}
},

'Dumbbell Romanian Deadlift': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
},

'EZ Barbell Reverse Grip Curl': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Kettlebell One Legged Deadlift': {
    'Primary': {'Hamstrings': 50, 'Glutes': 30},
    'Secondary': {'Lower Back': 10, 'Balance': 10}
},

'Barbell Clean and Press': {
    'Primary': {'Shoulders': 40, 'Trapezius': 30},
    'Secondary': {'Quadriceps': 10, 'Glutes': 10, 'Core': 10}
},

'Barbell Incline Row': {
    'Primary': {'Upper Back': 60},
    'Secondary': {'Biceps': 30, 'Posterior Deltoids': 10}
},

'Dumbbell Seated Reverse Grip Biceps Curl': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Archer Push up': {
    'Primary': {'Chest': 60, 'Triceps': 30},
    'Secondary': {'Core': 10}
},

'Barbell Overhead Squat': {
    'Primary': {'Quadriceps': 40, 'Shoulders': 30},
    'Secondary': {'Glutes': 15, 'Hamstrings': 10, 'Core': 5}
},

'Bodyweight Wall Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 30}
},

'Resistance Band Seated Biceps Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Standing Alternate Low Fly': {
    'Primary': {'Lower Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Dumbbell Prone Incline Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Curtsey lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Dumbbell Step Up Single Leg Balance with Bicep Curl': {
    'Primary': {'Quadriceps': 40, 'Glutes': 30, 'Biceps': 20},
    'Secondary': {'Hamstrings': 5, 'Balance': 5}
},

'Kettlebell Kickstand One Leg Deadlift': {
    'Primary': {'Hamstrings': 50, 'Glutes': 30},
    'Secondary': {'Lower Back': 10, 'Balance': 10}
},

'Hanging Toes to Bar': {
    'Primary': {'Rectus Abdominis': 50, 'Latissimus Dorsi': 30},
    'Secondary': {'Hip Flexors': 20}
},

'Lying Double Legs Biceps Curl with Towel': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Seated Front Raise': {
    'Primary': {'Front Deltoids': 70},
    'Secondary': {'Side Delts': 30}
},

'Barbell Standing Rocking Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Seated Flutter Kick': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Barbell Shrug': {
    'Primary': {'Trapezius': 80},
    'Secondary': {'Upper Back': 20}
},

'Barbell Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Cable High Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'EZ bar 21s': {
    'Primary': {'Biceps': 100}
},

'Dumbbell One Arm Seated Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearm': 10}
},

'Barbell Pin Presses': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Cable Overhead Tricep Extension Straight Bar': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Crunch (hands overhead)': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
},

'Cable Seated High Row (V bar)': {
    'Primary': {'Upper Back': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 20}
},

'Bodyweight Bent Over Rear Delt Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Dumbbell Seated Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Front Deltoids': 10}
},

'Dumbbell Goblet Box Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
},

'Split Lateral Squat with Roll': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Adductors': 10}
},

'Triceps Dips Floor': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
},

'Cable Rear Delt Row': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Dumbbell Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Donkey Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Hamstrings': 10}
},

'Cable Standing One Arm Tricep Pushdown (Overhand Grip)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Barbell Palms Up Wrist Curl Over A Bench': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Smith Close Grip Bench Press': {
    'Primary': {'Triceps': 60, 'Chest': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Reverse Plank with Leg Lift': {
    'Primary': {'Core': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Cable One Arm Straight Back High Row (kneeling)': {
    'Primary': {'Upper Back': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Cable Decline Seated Wide Grip Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Barbell Decline Pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Weighted Frog Pump': {
    'Primary': {'Glutes': 70, 'Adductors': 30}
},

'Modified Push Up to Forearms': {
    'Primary': {'Chest': 50, 'Triceps': 30},
    'Secondary': {'Core': 10, 'Forearms': 10}
},

'Resistance Band Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Cable Incline Pushdown': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Dumbbell Gobelt Curtsey Lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable Rope Extension Incline Bench Row': {
    'Primary': {'Upper Back': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Triceps': 10}
},

'Safety Bar Front Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Dumbbell One Arm Reverse Grip Press': {
    'Primary': {'Chest': 60},
    'Secondary': {'Triceps': 30, 'Front Deltoids': 10}
},

'Cable Half Kneeling Push Pull': {
    'Primary': {'Chest': 40, 'Back': 40},
    'Secondary': {'Triceps': 10, 'Biceps': 10}
},

'EZ Barbell Incline Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Lever Incline Hammer Chest Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Kettlebell Swing': {
    'Primary': {'Glutes': 50, 'Hamstrings': 30},
    'Secondary': {'Lower Back': 10, 'Core': 10}
},

'Smith Sumo Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable Lying Upright Row': {
    'Primary': {'Trapezius': 50, 'Side Delts': 40},
    'Secondary': {'Biceps': 10}
},

'Cable Upright Row': {
    'Primary': {'Trapezius': 50, 'Side Delts': 40},
    'Secondary': {'Biceps': 10}
},

'Dumbbell Seated Neutral Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Lever Standing Rear Kick': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
},

'Dumbbell Concentration Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Roll Seated Single Leg Shoulder Flexor Depresor Retractor': {
    'Primary': {'Shoulders': 60, 'Upper Back': 30},
    'Secondary': {'Core': 10}
},

'Cable Bent Over Reverse Grip Row': {
    'Primary': {'Latissimus Dorsi': 60, 'Biceps': 30},
    'Secondary': {'Posterior Deltoids': 10}
},

'Cable Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Incline Push up': {
    'Primary': {'Upper Chest': 60, 'Triceps': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Side Bridge (knee tuck)': {
    'Primary': {'Obliques': 70},
    'Secondary': {'Core': 20, 'Shoulders': 10}
},

'Barbell Rear Delt Row': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Reverse Push up': {
    'Primary': {'Triceps': 60},
    'Secondary': {'Chest': 30, 'Shoulders': 10}
},

'Cable Reverse grip Straight Back Seated High Row': {
    'Primary': {'Upper Back': 60, 'Biceps': 30},
    'Secondary': {'Posterior Deltoids': 10}
},

'Crab Twist Toe Touch': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Core': 20, 'Shoulders': 20}
},

'Dumbbell Low Fly': {
    'Primary': {'Lower Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Body Saw Plank': {
    'Primary': {'Core': 60},
    'Secondary': {'Shoulders': 20, 'Triceps': 20}
},

'Weighted Seated Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Seated Revers grip Concentration Curl': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Cable Straight Arm Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Triceps': 30}
},

'Bodyweight Kneeling Sissy Squat': {
    'Primary': {'Quadriceps': 80},
    'Secondary': {'Knee Joint': 20}
},

'Lever Donkey Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell Alternate Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Weighted Seated Reverse Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Resistance Band Assisted Nordic Hamstring Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Glutes': 10, 'Lower Back': 10}
},

'Cable Standing Chest Press': {
    'Primary': {'Chest': 80},
    'Secondary': {'Triceps': 15, 'Front Deltoids': 5}
},

'Assisted Prone Hamstring': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Glutes': 20}
},

'Barbell Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell Biceps Curl Reverse': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Dumbbell One Arm Standing Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Seated Bicep Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Barbell Pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Barbell Palms Down Wrist Curl Over A Bench': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Elbow to Knee': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Rectus Abdominis': 40}
},

'Smith Bent Knee Good morning': {
    'Primary': {'Hamstrings': 60, 'Glutes': 30},
    'Secondary': {'Lower Back': 10}
},

'Barbell Standing Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Hip Raise (bent knee)': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
},

'Barbell Straight Leg Deadlift': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
},

'Landmine Romanian Deadlift': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
},

'Hip Roll Plank': {
    'Primary': {'Core': 60},
    'Secondary': {'Obliques': 30, 'Glutes': 10}
},

'Dumbbell RDL Death March': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
},

'Resistance Band Plank March': {
    'Primary': {'Core': 70},
    'Secondary': {'Shoulders': 20, 'Glutes': 10}
},

'Twist Crunch (leg up)': {
    'Primary': {'Obliques': 60, 'Rectus Abdominis': 40}
},

'Cable Seated One Arm Concentration Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'EZ bar Biceps Curl (with arm blaster)': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Middle Fly': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Barbell Single Leg Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Weighted Sissy Squat': {
    'Primary': {'Quadriceps': 80},
    'Secondary': {'Knee Joint': 20}
},

'Dumbbell Seated Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Lever Seated Squat Calf Raise on Leg Press Machine': {
    'Primary': {'Calves': 90},
    'Secondary': {'Quadriceps': 10}
},

'Diamond Press': {
    'Primary': {'Triceps': 60, 'Inner Chest': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Trap Bar Deadlift': {
    'Primary': {'Quadriceps': 40, 'Hamstrings': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Kettlebell Sumo Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable Cross over Revers Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Dumbbell One Arm Shoulder Press': {
    'Primary': {'Shoulders': 80},
    'Secondary': {'Triceps': 20}
},

'Cable Kneeling Leaning Forward One Arm Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Sled Lying Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Dumbbell Lying Hammer Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Smith Seated Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dumbbell One Arm Kickback': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
},

'Lever Chair Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
},

'Lever Crossovers': {
    'Primary': {'Pectorals': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Superman Row with Towel': {
    'Primary': {'Upper Back': 50, 'Rear Deltoids': 30},
    'Secondary': {'Lower Back': 20}
},

'Barbell Standing Reverse Grip Curl': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Weighted Cossack Squats': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Band face pull': {
    'Primary': {'Rear Deltoids': 60, 'Trapezius': 30},
    'Secondary': {'Rhomboids': 10}
},

'Superman': {
    'Primary': {'Lower Back': 50},
    'Secondary': {'Glutes': 30, 'Hamstrings': 20}
},

'Dumbbell Standing Concentration Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Seated Pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Smith Standing Back Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dumbbell Alternate Seated Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Push up on Forearms': {
    'Primary': {'Chest': 50, 'Triceps': 30},
    'Secondary': {'Core': 10, 'Forearms': 10}
},

'Finger Push up': {
    'Primary': {'Chest': 60, 'Triceps': 30},
    'Secondary': {'Forearms': 10}
},

'Russian Twist': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Rectus Abdominis': 30, 'Core': 10}
},

'Barbell Behind Back Finger Curl': {
    'Primary': {'Forearms': 90},
    'Secondary': {'Grip Strength': 10}
},

'Cable Standing Back Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Weighted Seated Supination': {
    'Primary': {'Forearms (Supinators)': 100}
},

'Barbell Lunge': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell One Arm Snatch': {
    'Primary': {'Shoulders': 40, 'Trapezius': 30},
    'Secondary': {'Quadriceps': 10, 'Glutes': 10, 'Core': 10}
},

'Barbell Pullover To Press': {
    'Primary': {'Chest': 40, 'Latissimus Dorsi': 30, 'Shoulders': 20},
    'Secondary': {'Triceps': 10}
},

'Dumbbell Overhead Squat': {
    'Primary': {'Quadriceps': 40, 'Shoulders': 30},
    'Secondary': {'Glutes': 15, 'Hamstrings': 10, 'Core': 5}
},

'Dumbbell Alternate Hammer Preacher Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Cable Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Cable Reverse Grip Triceps Pushdown (with arm blaster)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Kettlebell One Arm Overhead Squat': {
    'Primary': {'Quadriceps': 40, 'Shoulders': 30},
    'Secondary': {'Glutes': 15, 'Hamstrings': 10, 'Core': 5}
},

'Cable Kneeling Rear Delt Row (Rope)': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Barbell Decline Bench Press': {
    'Primary': {'Lower Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell Front Rack Lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Core': 10}
},

'Balance Board': {
    'Primary': {'Core': 50, 'Ankles': 30},
    'Secondary': {'Calves': 20}
},

'Cable One Arm Reverse Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Rhomboids': 10}
},

'Dumbbell Deadlift': {
    'Primary': {'Hamstrings': 40, 'Quadriceps': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Dumbbell Fly (knees at 90 degrees)': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Lever Deadlift (plate loaded)': {
    'Primary': {'Hamstrings': 40, 'Quadriceps': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Dumbbell Alternate Biceps Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Lever Horizontal One leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Bodyweight Squatting Row (with towel)': {
    'Primary': {'Back': 50},
    'Secondary': {'Biceps': 30, 'Quadriceps': 20}
},

'Bodyweight Pulse Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Curtsey Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Cable Drag Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Kettlebell Goblet Squat Mobility': {
    'Primary': {'Hips': 40, 'Thoracic Spine': 30, 'Ankles': 20},
    'Secondary': {'Quadriceps': 10}
},

'Weighted Pistol Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Balance': 10}
},

'Dumbbell Goblet Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Kicks Leg Bent': {
    'Primary': {'Hamstrings': 60, 'Glutes': 30},
    'Secondary': {'Lower Back': 10}
},

'Cable Bent Over One Arm Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Core': 10}
},

'Barbell Bent Arm Pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Barbell Seated Good morning': {
    'Primary': {'Hamstrings': 60, 'Glutes': 30},
    'Secondary': {'Lower Back': 10}
},

'Lying Scissor Kick': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Cable Overhead Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell side lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Squat (arms overhead)': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Shoulders': 10}
},

'Dumbbell Seated One Arm Arnold Press': {
    'Primary': {'Shoulders': 70},
    'Secondary': {'Triceps': 20, 'Upper Chest': 10}
},

'Barbell Reverse Grip Incline Bench Row': {
    'Primary': {'Upper Back': 60, 'Biceps': 30},
    'Secondary': {'Posterior Deltoids': 10}
},

'Lever Chest Press': {
    'Primary': {'Pectorals': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Cable Incline Fly': {
    'Primary': {'Upper Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Cable Seated on Floor Row Rope': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Cable One Arm Side Triceps Pushdown': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Incline Cross Rear Fly': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Step up on Chair': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell Reverse Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Rhomboids': 10}
},

'Cable Seated Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Hyght Dumbbell Fly': {
    'Primary': {'Upper Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Cable Upper Chest Crossovers': {
    'Primary': {'Upper Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Barbell Rear Delt Raise': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Dumbbell Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Front Deltoids': 10}
},

'Dumbbell Alternate Biceps Curl (with arm blaster)': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Lying One Arm Supinated Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Cable Lying Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Dumbbell Seated Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Barbell Lying Back of the Head Tricep Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Barbell Lying Close Grip Underhand Row on Rack': {
    'Primary': {'Biceps': 60},
    'Secondary': {'Latissimus Dorsi': 20, 'Posterior Deltoids': 10, 'Forearms': 10}
},

'Bulgarian Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},


'Cable Fly with Chest Supported': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Cable one arm lat pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
},

'Barbell Reverse Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Lever Leg Extension (plate loaded)': {
    'Primary': {'Quadriceps': 90},
    'Secondary': {'Knee Joint Stability': 10}
},

'Band Standing Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Cable Kneeling Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
},

'EZ Bar Standing French Press': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Dumbbell Incline Fly': {
    'Primary': {'Upper Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Smith Low Bar Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 40},
    'Secondary': {'Hamstrings': 10}
},

'Tiger Tail Hamstring': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Calves': 30}
},

'Sled Calf Press On Leg Press': {
    'Primary': {'Calves': 90},
    'Secondary': {'Quadriceps': 10}
},

'Dumbbell Lunge': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Cable Incline Skull Crusher': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Barbell Decline wide grip pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Dumbbell Over Bench One Arm Reverse Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dumbbell Flat Around the World': {
    'Primary': {'Shoulders': 60},
    'Secondary': {'Trapezius': 20, 'Core': 20}
},

'Cable High Pulley Overhead Tricep Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Barbell Incline Triceps Extension Skull Crusher': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Cable Hammer Curl (Rope) m': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Single Leg Deadlift with Knee Lift': {
    'Primary': {'Hamstrings': 50, 'Glutes': 30},
    'Secondary': {'Lower Back': 10, 'Balance': 10}
},

'Cable Squatting Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Bent Knee Side Plank': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Core': 30, 'Shoulders': 10}
},

'Cable Alternate Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
},

'Scissors (advanced)': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Barbell Standing Close Grip Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Bar Grip Sumo Squat': {
    'Primary': {'Quadriceps': 50},
    'Secondary' : {'Glutes': 30, 'Adductors': 20}
},

'Lever Standing Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Barbell Reverse Preacher Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Barbell Reverse Grip Bent over Row': {
    'Primary': {'Latissimus Dorsi': 60, 'Biceps': 30},
    'Secondary': {'Posterior Deltoids': 10}
},

'Standing Overhead Press (Barbell)': {
    'Primary': {'Shoulders': 70},
    'Secondary': {'Triceps': 30}
},

'Barbell Lying Row on Rack': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Squat m': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Lying Scissor Crunch': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Dumbbell Incline Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Kneeling Hip Flexor': {
    'Primary': {'Hip Flexors': 70},
    'Secondary': {'Quadriceps': 30}
},

'Leg Curl (on stability ball)': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Calves': 10, 'Core': 10}
},

'Cable Rope Hammer Preacher Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Band kneeling one arm pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
},

'EZ Bar California Skullcrusher': {
    'Primary': {'Triceps (long head)': 80},
    'Secondary': {'Triceps (lateral & medial heads)': 20}
},

'Sled One Leg Calf Press on Leg Press': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Dumbbell One Arm Low Fly': {
    'Primary': {'Lower Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Dumbbell Squeeze Bench Press': {
    'Primary': {'Chest': 80},
    'Secondary': {'Triceps': 15, 'Front Deltoids': 5}
},

'One Leg Quarter Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Balance': 10}
},

'Butt ups': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 20, 'Lower Back': 10}
},

'Dumbbell Alternate Arnold Press': {
    'Primary': {'Shoulders': 70},
    'Secondary': {'Triceps': 20, 'Upper Chest': 10}
},

'Smith Machine Incline Tricep Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Cable One Arm Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
},

'EZ Barbell Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Barbell Sumo Deadlift': {
    'Primary': {'Quadriceps': 40, 'Hamstrings': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Cable Seated Chest Press': {
    'Primary': {'Chest': 80},
    'Secondary': {'Triceps': 15, 'Front Deltoids': 5}
},

'Bridge   Mountain Climber (Cross Body)': {
    'Primary': {'Core': 50, 'Glutes': 30},
    'Secondary': {'Shoulders': 10, 'Obliques': 10}
},

'Lever Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Kettlebell Front Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
},

'Barbell Seated Overhead Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Dumbbell Incline T Raise': {
    'Primary': {'Posterior Deltoids': 60, 'Side Delts': 30},
    'Secondary': {'Trapezius': 10}
},

'Bodyweight Side Lying Biceps Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Clock Push Up': {
    'Primary': {'Chest': 60, 'Triceps': 30},
    'Secondary': {'Core': 10}
},

'Decline Push Up m': {
    'Primary': {'Upper Chest': 60, 'Triceps': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Cocoons': {
    'Primary': {'Rectus Abdominis': 50, 'Obliques': 40},
    'Secondary': {'Hip Flexors': 10}
}, 

'Dumbbell Reverse Preacher Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
}, 

'Cable One Arm Tricep Pushdown': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Kettlebell Bottoms Up Clean From The Hang Position': {
    'Primary': {'Trapezius': 40, 'Shoulders': 30},
    'Secondary': {'Core': 20, 'Forearms': 10}
}, 

'Seated Leg Raise': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
}, 

'Dumbbell Standing Single Spider Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Dumbbell Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
}, 

'Cable Shoulder Press': {
    'Primary': {'Shoulders': 80},
    'Secondary': {'Triceps': 20}
}, 

'Dumbbell Incline Close grip Press Variation': {
    'Primary': {'Upper Chest': 60, 'Triceps': 30},
    'Secondary': {'Front Deltoids': 10}
}, 

'Cable Low Fly': {
    'Primary': {'Lower Chest': 80},
    'Secondary': {'Front Deltoids': 20}
}, 

'Weighted one leg hip thrust': {
    'Primary': {'Glutes': 80},
    'Secondary': {'Hamstrings': 20}
}, 

'EZ Barbell Seated Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Dumbbell Seated One Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Dumbbells Seated Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Dumbbell Around Pullover': {
    'Primary': {'Latissimus Dorsi': 50, 'Chest': 30},
    'Secondary': {'Triceps': 20}
}, 

'Cable Triceps Pushdown (V bar) (with arm blaster)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Hack Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Hamstrings': 10}
}, 

'Dumbbell Crunch Up': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
}, 

'Dumbbell Push Press': {
    'Primary': {'Shoulders': 60},
    'Secondary': {'Triceps': 20, 'Quadriceps': 10, 'Core': 10}
}, 

'Smith Chair Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
}, 

'Dumbbell Clean': {
    'Primary': {'Trapezius': 40, 'Shoulders': 30},
    'Secondary': {'Quadriceps': 10, 'Glutes': 10, 'Core': 10}
}, 

'Hand Spring Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
}, 

'Crunch (arms straight)': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
}, 

'Trap Bar Split Stance RDL': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
}, 

'Dumbbell Rear Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Rhomboids': 10}
}, 

'Weighted Kneeling Step with Swing': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Core': 10}
}, 

'Sit (wall)': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 30}
}, 

'Cable Close Grip Front Lat Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
}, 

'Dumbbell Prone Incline Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
}, 

'Dumbbell Seated One Arm Shoulder Press': {
    'Primary': {'Shoulders': 80},
    'Secondary': {'Triceps': 20}
}, 

'Barbell Bent Over Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
}, 

'Barbell Front Raise and Pullover': {
    'Primary': {'Front Deltoids': 40, 'Latissimus Dorsi': 40},
    'Secondary': {'Triceps': 10, 'Chest': 10}
}, 

'Smith Lateral Step Up': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'EZ bar Close Grip Bench Press': {
    'Primary': {'Triceps': 60, 'Chest': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Barbell Wide Reverse Grip Bench Press': {
    'Primary': {'Upper Chest': 60},
    'Secondary': {'Triceps': 30, 'Front Deltoids': 10}
},

'Cable Standing Face Pull (Rope)': {
    'Primary': {'Rear Deltoids': 60, 'Trapezius': 30},
    'Secondary': {'Biceps': 10}
},

'Dumbbell Incline Alternate Bicep Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Rear Delt Row (Rope)': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Dumbbell Incline Y Raise': {
    'Primary': {'Upper Traps': 50, 'Side Delts': 40},
    'Secondary': {'Front Deltoids': 10}
},

'Cable Rope One Arm Hammer Preacher Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Cable Deadlift': {
    'Primary': {'Hamstrings': 40, 'Quadriceps': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Single Leg Platform Slide': {
    'Primary': {'Adductors': 60, 'Glutes': 30},
    'Secondary': {'Quadriceps': 10}
},

'Weighted Seated Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Cable Palm Rotational Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Forearms': 10}
},

'Sled 45 Leg Wide Press': {
    'Primary': {'Quadriceps': 60, 'Glutes': 20, 'Adductors': 20}
},

'Lever Seated Leg Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Calves': 20}
},

'Barbell Front Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
},

'Roll Body Saw': {
    'Primary': {'Core': 60},
    'Secondary': {'Shoulders': 20, 'Triceps': 20}
},

'Cable Seated Rear Lateral Raise': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Decline Bent Leg Reverse Crunch': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Obliques': 30}
},

'Cable Kneeling One Arm Lat Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
},

'Hollow Hold': {
    'Primary': {'Core': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Negative Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
},

'Dumbbell Seated Palms Up Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Barbell Glute Bridge': {
    'Primary': {'Glutes': 80},
    'Secondary': {'Hamstrings': 20}
},

'Cable Pull Through (Rope)': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
},

'Dumbbell One Arm Zottman Preacher Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
},

'Dumbbell Close Grip Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Wall Ball': {
    'Primary': {'Quadriceps': 40, 'Shoulders': 30},
    'Secondary': {'Glutes': 15, 'Hamstrings': 10, 'Core': 5}
},

'Cable Stiff Leg Deadlift from Stepbox': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
},

'Resistance Band Lateral Walk': {
    'Primary': {'Hip Abductors': 60, 'Glutes': 40}
},

'Dumbbell Standing Inner Biceps Curl': {
    'Primary': {'Biceps (short head)': 70},
    'Secondary': {'Biceps (long head)': 20, 'Forearms': 10}
},

'Dumbbell Drag Bicep Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Alternate Side Press': {
    'Primary': {'Shoulders': 80},
    'Secondary': {'Triceps': 20}
},

'Cable Lying Fly': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Barbell Lying Triceps Extension Skull Crusher': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Barbell Deadlift': {
    'Primary': {'Hamstrings': 40, 'Quadriceps': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Handboard Hang with 135 Degree Elbow': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Smith Toe Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Dumbbell One Arm Bench Fly': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'EZ Barbell Standing Wide Grip Biceps Curl': {
    'Primary': {'Biceps (outer head)': 70},
    'Secondary': {'Biceps (inner head)': 20, 'Forearms': 10}
},

'Dumbbell Standing Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Barbell Standing Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Barbell Behind The Back Shrug': {
    'Primary': {'Trapezius': 80},
    'Secondary': {'Upper Back': 20}
},

'Cable Close Grip Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Biceps Leg Concentration Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Calves': 20}
},

'Barbell Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Weighted Seated One Arm Reverse Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Barbell High Bar Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Cable Floor Seated Wide grip Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
},

'Cable Rope Elevated Seated Row': {
    'Primary': {'Upper Back': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 20}
},

'Dumbbell Split Squat Front Foot Elevanted': {
    'Primary': {'Quadriceps': 70, 'Glutes': 20},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell One Arm Incline Chest Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Vertical Leg Raise (on parallel bars)': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Dumbbell Incline Alternate Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Decline Crunch': {
    'Primary': {'Upper Abdominals': 70},
    'Secondary': {'Obliques': 30}
},

'Barbell Low Bar Squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 40},
    'Secondary': {'Hamstrings': 10}
},

'Barbell Floor Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Dumbbell one leg squat w': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Balance': 10}
},

'Bodyweight Standing Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Lever Alternate Biceps Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
},

'Smith Single Leg Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell Standing Alternating Tricep Kickback': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
},

'EZ Barbell Seated Curls': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Cable Standing Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Dumbbell Pullover': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Chest': 20, 'Triceps': 20}
},

'Dumbbell Seated One Arm Rotate': {
    'Primary': {'Obliques': 70},
    'Secondary': {'Core': 30}
},

'Dumbbell Banded Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Push up': {
    'Primary': {'Chest': 60, 'Triceps': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Dumbbell Russian Twist': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Rectus Abdominis': 30, 'Core': 10}
},

'Dumbbell Twisted Fly': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Front Deltoids': 30}
},

'EZ Barbell Decline Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Upper Chest': 20}
},

'Dumbbell Standing One Arm Reverse Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
},

'Cable Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
}, 

'Cable Crossover Variation': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
}, 

'Dumbbell Seated Kickback': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
}, 

'Cable One Arm Bent over Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
}, 

'Dumbbell Incline Two Arm Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
}, 

'Barbell Romanian Deadlift': {
    'Primary': {'Hamstrings': 60},
    'Secondary': {'Glutes': 30, 'Lower Back': 10}
}, 

'Dumbbell Standing Bent Over One Arm Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
}, 

'EZ Bar Lying Close Grip Triceps Extension Behind Head': {
    'Primary': {'Triceps (long head)': 80},
    'Secondary': {'Triceps (lateral & medial heads)': 20}
}, 

'Weighted Standing Hand Squeeze': {
    'Primary': {'Forearms (grip strength)': 100}
}, 

'Lever Decline Chest Press': {
    'Primary': {'Lower Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
}, 

'Dumbbell Seated Shoulder Press': {
    'Primary': {'Shoulders': 80},
    'Secondary': {'Triceps': 20}
}, 

'Bench Dip with legs on bench': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
}, 

'Reverse Dip': {
    'Primary': {'Triceps': 60},
    'Secondary': {'Chest': 30, 'Shoulders': 10}
}, 

'Cable Rope High Pulley Overhead Tricep Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
}, 

'Barbell Sumo Romanian Deadlift': {
    'Primary': {'Hamstrings': 60, 'Adductors': 30},
    'Secondary': {'Glutes': 10}
}, 

'Lever Seated Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
}, 

'Smith Front Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
}, 

'Band standing internal shoulder rotation': {
    'Primary': {'Subscapularis': 70},
    'Secondary': {'Pectoralis Major': 20, 'Latissimus Dorsi': 10}
}, 

'Sled 45 degrees One Leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
}, 

'Dumbbell Decline Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Upper Chest': 20}
}, 

'Smith Split Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
}, 

'Dumbbell Stiff Leg Deadlift': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
}, 

'Smith Seated Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Dumbbell Rotation Reverse Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Rhomboids': 10}
}, 

'Cable Standing Inner Curl': {
    'Primary': {'Biceps (short head)': 70},
    'Secondary': {'Biceps (long head)': 20, 'Forearms': 10}
}, 

'Dumbbell Standing Biceps Curl to Shoulder Press': {
    'Primary': {'Biceps': 50, 'Shoulders': 40},
    'Secondary': {'Forearms': 10}
}, 

'Band kneeling pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
}, 

'Cable Lying Triceps Extension (Rope)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
}, 

'Cable Rope Incline Tricep Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
}, 

'Cable Reverse Grip Triceps Pushdown (SZ bar)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Dumbbell Incline Alternate Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
}, 

'Dumbbell Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
}, 

'Cable Low Seated Row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
}, 

'Dumbbell Front Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
}, 

'EZ Bar Seated Close Grip Concentration Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Lever Triceps Dip (plate loaded)': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
}, 

'Bodyweight Standing Pulse Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Lever Hip Thrust': {
    'Primary': {'Glutes': 80},
    'Secondary': {'Hamstrings': 20}
}, 

'Dumbbell Rear Delt Raise': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
}, 

'Barbell Front Chest Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Core': 10}
}, 

'Barbell Reverse Grip Skullcrusher': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
}, 

'Barbell Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
}, 

'Dumbbell Seated Alternate Front Raise': {
    'Primary': {'Front Deltoids': 70},
    'Secondary': {'Side Delts': 30}
}, 

'Dumbbell Decline Bench Press': {
    'Primary': {'Lower Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
}, 

'Lever Preacher Curl (plate loaded)': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
}, 

'Triceps Dip (bench leg)': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
}, 

'Cable Reverse Wrist Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
}, 

'Dumbbell Decline Fly': {
    'Primary': {'Lower Chest': 80},
    'Secondary': {'Front Deltoids': 20}
}, 

'Squat': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
}, 

'Smith Calf Raise (with block)': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Cable Reverse Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
}, 

'Dumbbell Lying Single Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
}, 

'Dumbbell Lying Hamstring Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Calves': 20}
}, 

'Smith Stiff Legged Deadlift': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 20, 'Lower Back': 10}
}, 

'Cable twisting overhead press': {
    'Primary': {'Shoulders': 70, 'Core': 20},
    'Secondary': {'Triceps': 10}
}, 

'Lever Seated Horizontal Leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
}, 

'Cable Twist': {
    'Primary': {'Obliques': 60},
    'Secondary': {'Rectus Abdominis': 30, 'Core': 10}
}, 

'Cable Kneeling Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
}, 

'Dumbbell Standing Alternate Hammer Curl and Press': {
    'Primary': {'Biceps': 40, 'Brachialis': 30, 'Shoulders': 20},
    'Secondary': {'Forearms': 10}
}, 

'Cable Rear Drive': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 30}
}, 

'Dumbbell Incline Around the World': {
    'Primary': {'Shoulders': 60},
    'Secondary': {'Trapezius': 20, 'Core': 20}
}, 

'Dumbbell Standing Reverse Curl': {
    'Primary': {'Brachialis': 60},
    'Secondary': {'Biceps': 30, 'Forearms': 10}
}, 

'Cable Seated Row with V bar': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
}, 

'Barbell Seated Close grip Concentration Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
}, 

'Cable One Arm Preacher Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Brachialis': 15, 'Forearms': 5}
}, 

'Bridge (straight arm)': {
    'Primary': {'Glutes': 70},
    'Secondary': {'Hamstrings': 20, 'Core': 10}
}, 

'Dumbbell Peacher Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
}, 

'Hack One Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Side Lying Clam': {
    'Primary': {'Hip Abductors': 70},
    'Secondary': {'Glutes': 30}
}, 

'Cable Seated Rear Delt Fly with Chest Support': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 30}
}, 

'Bent Leg Side Kick (kneeling)': {
    'Primary': {'Glutes': 60, 'Hip Abductors': 30},
    'Secondary': {'Core': 10}
}, 

'Bodyweight Standing Row': {
    'Primary': {'Back': 60},
    'Secondary': {'Biceps': 40}
}, 

'Landmine Front Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 30, 'Hamstrings': 10}
}, 

'Plyo Sit Squat (wall)': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
}, 

'Dumbbell Cross Body Hammer Curl': {
    'Primary': {'Biceps': 60, 'Brachialis': 30},
    'Secondary': {'Forearms': 10}
}, 

'Dumbbell Standing Single Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
}, 

'Dumbbell Swing': {
    'Primary': {'Glutes': 50, 'Hamstrings': 30},
    'Secondary': {'Lower Back': 10, 'Core': 10}
}, 

'Hanging Leg Raise': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
}, 

'Sumo Squat m': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
}, 

'Landmine Kneeling Squeeze Press': {
    'Primary': {'Chest': 60},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10, 'Core': 10}
}, 

'Jack Plank': {
    'Primary': {'Core': 60},
    'Secondary': {'Shoulders': 20, 'Obliques': 20}
}, 

'Sled 45 Leg Press (Side POV)': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10}
}, 

'Cable Seated Lats Focused Row': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10}
}, 

'Cable Half Kneeling External Rotation': {
    'Primary': {'Rotator Cuff': 80},
    'Secondary': {'Posterior Deltoids': 20}
}, 

'Dumbbell Standing Bent Over Two Arm Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
}, 

'Roll Reverse Crunch': {
    'Primary': {'Lower Abdominals': 70},
    'Secondary': {'Obliques': 30}
}, 

'Cable seated row': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Posterior Deltoids': 20, 'Biceps': 10, 'Trapezius': 10}
}, 


'Sled Wide Hack Squat': {
    'Primary': {'Quadriceps': 60, 'Adductors': 30},
    'Secondary': {'Glutes': 10}
},

'Otis Up': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Biceps': 30, 'Posterior Deltoids': 10}
},

'Dumbbell Kickback': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Core': 20}
},

'Sled 45 Calf Press': {
    'Primary': {'Calves': 90},
    'Secondary': {'Quadriceps': 10}
},

'Barbell Guillotine Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Barbell sumo squat': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Barbell Decline Wide grip Press': {
    'Primary': {'Lower Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Dumbbell One Arm Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Front Deltoids': 10}
},

'Dumbbell Front Raise': {
    'Primary': {'Front Deltoids': 70},
    'Secondary': {'Side Delts': 30}
},

'Cable Reverse Grip Biceps Curl (SZ bar)': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Dumbbell Lying Elbow Press': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Dumbbell Zottman Curl': {
    'Primary': {'Biceps': 50, 'Brachialis': 40},
    'Secondary': {'Forearms': 10}
},

'Smith One Leg Floor Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance & Stability': 10}
},

'Dumbbell One Arm Concetration Curl (on stability ball)': {
    'Primary': {'Biceps': 70},
    'Secondary': {'Forearms': 20, 'Core': 10}
},

'Dumbbell Press on Exercise Ball': {
    'Primary': {'Chest': 60},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10, 'Core': 10}
},

'Bodyweight Step up on Stepbox': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Dumbbell One arm Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Barbell Biceps Curl (with arm blaster)': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Svend Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 30}
},

'Dumbbell Reverse Spider Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Dumbbell Incline Palm in Press': {
    'Primary': {'Triceps': 60, 'Upper Chest': 30},
    'Secondary': {'Front Deltoids': 10}
},

'Bycicle Twisting Crunch': {
    'Primary': {'Obliques': 60, 'Rectus Abdominis': 40}
},

'Cable One Arm Lateral Raise': {
    'Primary': {'Side Delts': 70},
    'Secondary': {'Trapezius': 20, 'Front Deltoids': 10}
},

'Dumbbell Tate Press': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
},

'Triceps Press': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Smith Standing Leg Calf Raise': {
    'Primary': {'Calves': 90},
    'Secondary': {'Balance': 10}
},

'Air Twisting Crunch': {
    'Primary': {'Obliques': 60, 'Rectus Abdominis': 40}
},

'Cable Neutral Grip Lat Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 20, 'Posterior Deltoids': 10}
},

'Kettlebell Single Leg Glute Bridge Pullover': {
    'Primary': {'Glutes': 50, 'Hamstrings': 30},
    'Secondary': {'Latissimus Dorsi': 10, 'Core': 10}
},

'Single Leg Step up': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Cable Rear Delt Row (stirrups)': {
    'Primary': {'Rear Deltoids': 70},
    'Secondary': {'Trapezius': 20, 'Biceps': 10}
},

'Barbell Standing Overhead Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Latissimus Dorsi': 20}
},

'Dumbbell Fly': {
    'Primary': {'Chest': 80},
    'Secondary': {'Front Deltoids': 20}
},

'Barbell Wide Bench Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Triceps': 20, 'Front Deltoids': 10}
},

'Smith Deadlift': {
    'Primary': {'Hamstrings': 40, 'Quadriceps': 30, 'Glutes': 20},
    'Secondary': {'Lower Back': 10}
},

'Knee Touch Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
},

'Barbell full Zercher Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Core': 10}
},

'V up': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Cable Standing Front Raise Variation': {
    'Primary': {'Front Deltoids': 70},
    'Secondary': {'Side Delts': 30}
},

'Barbell Standing Wide Grip Biceps Curl': {
    'Primary': {'Biceps (outer head)': 70},
    'Secondary': {'Biceps (inner head)': 20, 'Forearms': 10}
},

'Barbell Wide Shrug': {
    'Primary': {'Trapezius': 80},
    'Secondary': {'Upper Back': 20}
},

'Triceps Press (Head Below Bench)': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Squat (with band)': {
    'Primary': {'Quadriceps': 60, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10}
},

'Barbell Rack Pull': {
    'Primary': {'Upper Back': 50, 'Trapezius': 30},
    'Secondary': {'Hamstrings': 10, 'Glutes': 10}
},

'Kettlebell Gobelt Curtsey Lunge': {
    'Primary': {'Quadriceps': 50, 'Glutes': 30, 'Adductors': 20}
},

'Dumbbell Incline Triceps Extension': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Lever Seated Dip': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
},

'Cable One Arm Wrist Curl': {
    'Primary': {'Forearms (flexors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Barbell One Leg Squat': {
    'Primary': {'Quadriceps': 60},
    'Secondary': {'Glutes': 20, 'Hamstrings': 10, 'Balance': 10}
},

'Cable Standing Wrist Reverse Curl': {
    'Primary': {'Forearms (extensors)': 90},
    'Secondary': {'Grip Strength': 10}
},

'Hanging Straight Leg Raise': {
    'Primary': {'Rectus Abdominis': 60},
    'Secondary': {'Hip Flexors': 40}
},

'Dumbbell Standing Biceps Curl': {
    'Primary': {'Biceps': 80},
    'Secondary': {'Forearms': 20}
},

'Body Up': {
    'Primary': {'Triceps': 60},
    'Secondary': {'Chest': 30, 'Shoulders': 10}
},

'Nordic Hamstring Curl': {
    'Primary': {'Hamstrings': 80},
    'Secondary': {'Glutes': 10, 'Lower Back': 10}
},

'Barbell Front Raise': {
    'Primary': {'Front Deltoids': 70},
    'Secondary': {'Side Delts': 30}
},

'Cable Standing Cross over High Reverse Fly': {
    'Primary': {'Posterior Deltoids': 70},
    'Secondary': {'Trapezius': 30}
},

'Dumbbell Tricep Kickback With Stork Stance': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Core': 20, 'Balance': 10}
},

'Weighted Tricep Dips': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
},

'EZ Barbell Reverse grip Preacher Curl': {
    'Primary': {'Biceps': 70, 'Brachialis': 30}
},

'Cable Standing Lift': {
    'Primary': {'Trapezius': 50, 'Side Delts': 40},
    'Secondary': {'Biceps': 10}
},

'Landmine Squat and Press': {
    'Primary': {'Quadriceps': 40, 'Shoulders': 40},
    'Secondary': {'Glutes': 10, 'Hamstrings': 5, 'Core': 5}
},

'Dumbbell Seated Biceps Curl to Shoulder Press': {
    'Primary': {'Biceps': 50, 'Shoulders': 40},
    'Secondary': {'Forearms': 10}
},
'Lever Overhand Triceps Dip': {
    'Primary': {'Triceps': 80},
    'Secondary': {'Chest': 20}
},

'Cable Bent Over Row': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Rhomboids': 15, 'Trapezius': 15}
},

'Smith Hip Thrust': {
    'Primary': {'Glutes': 80},
    'Secondary': {'Hamstrings': 20}
},

'Hanging Oblique Knee Raise': {
    'Primary': {'Obliques': 80},
    'Secondary': {'Rectus Abdominis': 20}
},

'Weighted Standing Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Incline Push Up Depth Jump': {
    'Primary': {'Chest': 30, 'Triceps': 30},
    'Secondary': {'Shoulders': 20, 'Core': 20}
},

'Lever seated one leg calf raise': {
    'Primary': {'Calves': 100}
},


'Alternate Oblique Crunch': {
    'Primary': {'Obliques': 80},
    'Secondary': {'Rectus Abdominis': 20}
},

'Cable Standing Pulldown (Rope)': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 15, 'Forearms': 15}
},

'Barbell Seated Calf Raise': {
    'Primary': {'Calves': 100}
},

'Cable Leaning Lateral Raise': {
    'Primary': {'Side Delts': 80},
    'Secondary': {'Front Deltoid': 10, 'Trapezius': 10}
},

'Crunch (straight leg up)': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Hip Flexors': 20}
},

'Ring Dip': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 15, 'Shoulders': 15}
},

'Diamond Push up (on knees)': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 30}
},

'Smith Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 15, 'Hamstrings': 15}
},

'Dumbbell Seated Calf Raise': {
    'Primary': {'Calves': 100}
},

'Chest Dip on Straight Bar': {
    'Primary': {'Chest': 60},
    'Secondary': {'Triceps': 20, 'Shoulders': 20}
},

'Weighted Counterbalanced Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 15, 'Hamstrings': 15}
},

'Cable pull through': {
    'Primary': {'Glutes': 35, 'Hamstrings': 35},
    'Secondary': {'Erector Spinae': 30}
},

'Kettlebell Farmers Carry': {
    'Primary': {'Forearms': 25, 'Grip Strength': 25},
    'Secondary': {'Trapezius': 25, 'Core': 25}
},

'Cable Seated Row (Bent bar)': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Rhomboids': 10, 'Trapezius': 10, 'Biceps': 10}
},

'Cable Incline Bench Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Front Deltoid': 15, 'Triceps': 15}
},

'Sled Closer Hack Squat': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 10, 'Hamstrings': 10, 'Calves': 10}
},

'Standing Calf Raise (On a staircase)': {
    'Primary': {'Calves': 100}
},

'Cable Pulldown (pro lat bar)': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 15, 'Forearms': 15}
},

'Seated In Out Leg Raise on Floor': {
    'Primary': {'Hip Adductors': 35, 'Abductors': 35},
    'Secondary': {'Core': 30}
},

'Incline Twisting Situp': {
    'Primary': {'Rectus Abdominis': 35, 'Obliques': 35},
    'Secondary': {'Hip Flexors': 30}
},

'Cable Bar Lateral Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 15, 'Forearms': 15}
},

'Dumbbell One Arm Triceps Extension (on bench)': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Latissimus Dorsi': 10}
},

'Plate Pinch': {
    'Primary': {'Forearms': 100
    }
},

'Bodyweight Frog Pump': {
    'Primary': {'Glutes': 35, 'Adductors': 35},
    'Secondary': {'Hamstrings': 30}
},

'Barbell Jefferson Squat': {
    'Primary': {'Quadriceps': 30, 'Glutes': 30},
    'Secondary': {'Hamstrings': 15, 'Core': 15, 'Adductors': 10}
},

'Russian Twist (with medicine ball)': {
    'Primary': {'Obliques': 70},
    'Secondary': {'Rectus Abdominis': 15, 'Core': 15}
},

'Single Leg Heel Touch Squat': {
    'Primary': {'Quadriceps': 30, 'Glutes': 30},
    'Secondary': {'Hamstrings': 15, 'Balance': 15, 'Core': 10}
},
'Dead Bug': {
    'Primary': {'Core': 100}
},
'Hand Opposite Knee Crunch': {
        'Primary': {'Obliques': 70},
        'Secondary': {'Rectus Abdominis': 30}
    },

'Squat side kick': {
    'Primary': {'Quadriceps': 30, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Adductors': 10, 'Core': 10, 'Balance': 10}
},

'Single Leg Calf Raise (on a dumbbell)': {
    'Primary': {'Calves': 100}
},

'Bent over Row with Towel': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 10, 'Forearms': 10, 'Grip Strength': 10}
},

'Cable Seated Floor One Arm Concentration Curl': {
    'Primary': {'Biceps Brachii': 90},
    'Secondary': {'Brachialis': 5, 'Forearm Flexors': 5}
},

'Dumbbell Seated Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Cable twisting standing one arm chest press': {
    'Primary': {'Chest': 80},
    'Secondary': {'Triceps': 10, 'Shoulders': 5, 'Core': 5}
},

'Lying Leg Raise': {
    'Primary': {'Rectus Abdominis': 70},
    'Secondary': {'Hip Flexors': 30}
},
    


'Split Squats': {
    'Primary': {'Quadriceps': 35, 'Glutes': 35},
    'Secondary': {'Hamstrings': 15, 'Balance': 15}
},

'Sit up': {
    'Primary': {'Rectus Abdominis': 70},
    'Secondary': {'Hip Flexors': 30}
},

'Cable Elevated Row': {
    'Primary': {'Upper Back': 35, 'Traps': 35},
    'Secondary': {'Posterior Deltoids': 15, 'Biceps': 15}
},

    'Crunch (leg raise)': {
        'Primary': {'Rectus Abdominis': 70},
        'Secondary': {'Hip Flexors': 30}
    },

'Cable Lying Bicep Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

    'Lever Calf Press (plate loaded)': {
        'Primary': {'Calves': 100}
    },

    'Lunge with Jump': {
        'Primary': {'Quadriceps, Glutes, Hamstrings': 60},
        'Secondary': {'Calves, Core, Balance': 40}
    },

'Barbell Curtsey Lunge': {
    'Primary': {'Quadriceps': 20, 'Glutes': 20, 'Adductors': 20},
    'Secondary': {'Hamstrings': 13, 'Balance': 13, 'Core': 14}  
},

'Sled Forward Angled Calf Raise': {
    'Primary': {'Calves': 100}
},

'Barbell Upright Row': {
    'Primary': {'Trapezius': 30, 'Side Delts': 30},
    'Secondary': {'Biceps': 20, 'Forearms': 20}
},

'Dumbbell Incline Hammer Press': {
    'Primary': {'Chest': 70},
    'Secondary': {'Front Deltoid': 15, 'Triceps': 15}
},

'Dumbbell Lying Triceps Extension': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Chest': 5, 'Shoulders': 5}
},

 'Barbell Drag Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Weighted Seated Tuck Crunch on Floor': {
    'Primary': {'Rectus Abdominis': 70},
    'Secondary': {'Hip Flexors': 15, 'Obliques': 15}
},

'Kettlebell Lunge Pass Through': {
    'Primary': {'Quadriceps': 30, 'Glutes': 30},
    'Secondary': {'Hamstrings': 10, 'Shoulders': 10, 'Core': 10, 'Balance': 10}
},

'Bird Dog': {
    'Primary': {'Core': 25, 'Erector Spinae': 25},
    'Secondary': {'Glutes': 25, 'Hamstrings': 25}
},

'Dumbbell Incline Biceps Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Barbell Thruster': {
    'Primary': {'Quadriceps': 25, 'Shoulders': 25},
    'Secondary': {'Glutes': 25, 'Hamstrings': 12.5, 'Triceps': 12.5} 
},

'Cable Rope Seated Row': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Rhomboids': 10, 'Trapezius': 10, 'Biceps': 10}
},

'Barbell Incline Bench Press': {
    'Primary': {'Upper Chest': 70},
    'Secondary': {'Front Deltoid': 15, 'Triceps': 15}
},

'Wrist Roller': {
    'Primary': {'Forearms': 50, 'Grip Strength': 50}
},

'Kettlebell Plyo Pushup': {
    'Primary': {'Chest': 20, 'Triceps': 20, 'Shoulders': 20},
    'Secondary': {'Core': 20, 'Power': 20}
},

'Butt Bridge': {
    'Primary': {'Glutes': 35, 'Hamstrings': 35},
    'Secondary': {'Core': 15, 'Erector Spinae': 15}
},

'Barbell Decline Bent Arm Pullover': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Chest': 15, 'Triceps': 15}
},

'Smith Leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 10, 'Hamstrings': 10, 'Calves': 10}
},

'Kettlebell Lunge Clean and Press': {
    'Primary': {'Quadriceps': 17, 'Shoulders': 17, 'Core': 16},
    'Secondary': {'Glutes': 12, 'Hamstrings': 13, 'Triceps': 12, 'Balance': 13} 
},

'Dumbbell Standing Triceps Extension': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Core': 5, 'Shoulders': 5}
},

'Cable Pulldown Bicep Curl': {
    'Primary': {'Latissimus Dorsi': 25, 'Biceps': 25},
    'Secondary': {'Forearms': 50}
},

'Bodyweight Standing Row (with towel)': {
    'Primary': {'Latissimus Dorsi': 60},
    'Secondary': {'Biceps': 10, 'Posterior Deltoids': 10, 'Forearms': 10, 'Grip Strength': 10}
},

'Kettlebell deadlift': {
    'Primary': {'Hamstrings': 20, 'Glutes': 20, 'Back': 20},
    'Secondary': {'Forearms': 15, 'Grip Strength': 15, 'Core': 10}
},

'Lever Biceps Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},
'Bridge Hip Abduction': {
    'Primary': {'Glutes': 35, 'Hip Abductors': 35},
    'Secondary': {'Hamstrings': 15, 'Core': 15}
},

'Cable Seated Face Pull (Rope)': {
    'Primary': {'Posterior Deltoids': 35, 'Traps': 35},
    'Secondary': {'Rhomboids': 15, 'Rotator Cuff': 15}
},

'Cable Cross over Lateral Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Posterior Deltoids': 15, 'Biceps': 15}
},

'Sled 45 Leg Press': {
    'Primary': {'Quadriceps': 70},
    'Secondary': {'Glutes': 10, 'Hamstrings': 10, 'Calves': 10}
},

'Dumbbell Step up': {
    'Primary': {'Quadriceps': 35, 'Glutes': 35},
    'Secondary': {'Hamstrings': 10, 'Calves': 10, 'Balance': 10}
},

'Frog Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Hip Flexors': 10, 'Obliques': 10}
},

'Tuck Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Hip Flexors': 10, 'Obliques': 10}
},

'Kettlebell Alternating Hang Clean': {
    'Primary': {'Traps': 15, 'Shoulders': 15, 'Core': 15, 'Hamstrings': 15},
    'Secondary': {'Quadriceps': 20, 'Glutes': 10, 'Power': 10}
},

'Dumbbell Close Grip Press': {
    'Primary': {'Triceps': 70},
    'Secondary': {'Chest': 15, 'Front Deltoid': 15}
},

'Dumbbell Standing One Arm Extension': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Core': 5, 'Shoulders': 5}
},

'Cable Pulldown': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps, Forearms': 30}
},

'Barbell Standing Back Wrist Curl': {
    'Primary': {'Forearm Extensors': 100}
},

'Dumbbell Standing One Arm Curl Over Incline Bench': {
    'Primary': {'Biceps Brachii': 90},
    'Secondary': {'Brachialis, Forearm Flexors': 10}
},

'Cable Reverse Preacher Curl': {
    'Primary': {'Brachialis': 70},
    'Secondary': {'Biceps Brachii': 15, 'Forearm Flexors': 15}
},

'Bodyweight Shrug': {
    'Primary': {'Trapezius': 100}
},

'EZ bar Drag Bicep Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Smith Machine Decline Close Grip Bench Press': {
    'Primary': {'Lower Chest': 35, 'Triceps': 35},
    'Secondary': {'Front Deltoid': 30}
},

'Barbell Stiff Leg Good Morning': {
    'Primary': {'Hamstrings': 70},
    'Secondary': {'Glutes': 10, 'Lower Back': 10, 'Erector Spinae': 10}
},

'Dumbbell Standing Zottman Preacher Curl': {
    'Primary': {'Biceps Brachii': 25, 'Brachialis': 25},
    'Secondary': {'Forearm Flexors': 25, 'Forearm Extensors': 25}
},

'Cable Seated Crunch': {
    'Primary': {'Rectus Abdominis': 80},
    'Secondary': {'Obliques': 20}
},

'Cable Rope Crossover Seated Row': {
    'Primary': {'Latissimus Dorsi': 30, 'Rhomboids': 30},
    'Secondary': {'Posterior Deltoids': 15, 'Biceps': 15, 'Traps': 10}  
},

'Barbell Curl': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Cable Biceps Curl (SZ bar)': {
    'Primary': {'Biceps Brachii': 80},
    'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
},

'Dumbbell Incline Hammer Curl': {
    'Primary': {'Brachialis': 25, 'Biceps Brachii': 25},
    'Secondary': {'Forearm Flexors': 50}
},

'Dumbbell Standing Kickback': {
    'Primary': {'Triceps': 90},
    'Secondary': {'Core': 5, 'Shoulders': 5}
},

'Cable Parallel Grip Lat Pulldown on Floor': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Biceps': 15, 'Forearms': 15}
},

'Elbow Up and Down Dynamic Plank': {
    'Primary': {'Core': 25, 'Triceps': 25},
    'Secondary': {'Chest': 25, 'Shoulders': 25}
},

'Side Push up': {
    'Primary': {'Chest': 20, 'Obliques': 20, 'Shoulders': 20},
    'Secondary': {'Triceps': 20, 'Core': 20}
},

'Cable Seated One Arm Alternate Row': {
    'Primary': {'Latissimus Dorsi': 70},
    'Secondary': {'Rhomboids': 10, 'Trapezius': 10, 'Biceps': 5, 'Core': 5}
},

'EZ Barbell Standing Wrist Reverse Curl': {
    'Primary': {'Forearm Extensors': 100}
},

    'Lever Total Abdominal Crunch': {
        'Primary': {'Rectus Abdominis': 70},
        'Secondary': {'Hip Flexors': 15, 'Obliques': 15}
    },

    'Cable Incline Bench Row': {
        'Primary': {'Latissimus Dorsi': 60, 'Upper Back': 20},
        'Secondary': {'Posterior Deltoids': 10, 'Biceps': 10}
    },

    'Dumbbell Side Bend': {
        'Primary': {'Obliques': 70},
        'Secondary': {'Latissimus Dorsi': 15, 'Erector Spinae': 15}
    },

    'EZ Barbell JM Bench Press': {
        'Primary': {'Chest': 70},
        'Secondary': {'Triceps': 20, 'Front Deltoid': 10}
    },

    'Cable Standing Fly': {
        'Primary': {'Chest': 80},
        'Secondary': {'Front Deltoid': 20}
    },

    'Oblique Crunches Floor': {
        'Primary': {'Obliques': 70},
        'Secondary': {'Rectus Abdominis': 30}
    },

    'EZ Barbell Close Grip Preacher Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 20}
    },

    'Side Plank m': {
        'Primary': {'Obliques': 50},
        'Secondary': {'Core': 25, 'Shoulders': 25}
    },

    'Dumbbell Incline One Arm Lateral Raise': {
        'Primary': {'Side Delts': 80},
        'Secondary': {'Front Deltoid': 10, 'Trapezius': 10}
    },

    'Cable Single Arm Neutral Grip Front Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 10, 'Upper Chest': 10}
    },

    'Cable Standing Face Pull': {
        'Primary': {'Posterior Deltoids': 60, 'Traps': 20},
        'Secondary': {'Rhomboids': 10, 'Rotator Cuff': 10}
    },

    'Dumbbell Hammer Curls (with arm blaster)': {
        'Primary': {'Brachialis': 50, 'Biceps Brachii': 50}
    },

    'Kettlebell Goblet Squat': {
        'Primary': {'Quadriceps': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 10, 'Core': 10}
    },

    'Cable Front Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 20}
    },

    'Jump Squat': {
        'Primary': {'Quadriceps': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 10, 'Calves': 10}
    },

    'Bulgarian Split Squat with Chair': {
        'Primary': {'Quadriceps': 60, 'Glutes': 30},
        'Secondary': {'Hamstrings': 10}
    },

    'Roll Seated Shoulder Flexor Depresor Retractor FIX': {
        'Primary': {'Shoulders': 35, 'Upper Back': 35},
        'Secondary': {'Chest': 30}
    },

    'Diamond Push up': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Chest': 30}
    },

    'Olympic Barbell Hammer Curl': {
        'Primary': {'Brachialis': 50, 'Biceps Brachii': 50}
    },

    'Dumbbell Plyo Squat': {
        'Primary': {'Quadriceps': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 10, 'Calves': 10}
    },

    'Dumbbell Lying Rear Lateral Raise': {
        'Primary': {'Posterior Deltoids': 80},
        'Secondary': {'Traps': 10, 'Rhomboids': 10}
    },

    'Cable Reverse One Arm Curl': {
        'Primary': {'Brachialis': 70},
        'Secondary': {'Biceps Brachii': 30}
    },

    'Barbell One Arm Bent over Row': {
        'Primary': {'Latissimus Dorsi': 70},
        'Secondary': {'Posterior Deltoids': 15, 'Biceps': 15}
    },

    'Dumbbell Arnold Press': {
        'Primary': {'Shoulders': 70},
        'Secondary': {'Triceps': 20, 'Upper Chest': 10}
    },

    'Barbell Incline Lying Rear Delt Raise': {
        'Primary': {'Posterior Deltoids': 80},
        'Secondary': {'Traps': 10, 'Rhomboids': 10}
    },

    'Sissy Squat Bodyweight': {
        'Primary': {'Quadriceps': 90},
        'Secondary': {'Calves': 10}
    },

    'Kettlebell Double Alternating Hang Clean': {
        'Primary': {'Traps': 20, 'Shoulders': 20, 'Core': 20, 'Hamstrings': 20},
        'Secondary': {'Quadriceps': 10, 'Glutes': 10}
    },

    'EZ Barbell Standing Preacher Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 20}
    },

    'Lever Hammer Grip Preacher Curl': {
        'Primary': {'Brachialis': 50, 'Biceps Brachii': 50}
    },
    
    'Dumbbell Goblet Split Squat Front Foot Elevanted': {
        'Primary': {'Quadriceps': 60, 'Glutes': 30},
        'Secondary': {'Hamstrings': 5, 'Core': 5}
    },

    'Cross Body Crunch': {
        'Primary': {'Obliques': 70},
        'Secondary': {'Rectus Abdominis': 30}
    },

    'Cable one arm twisting seated row': {
        'Primary': {'Latissimus Dorsi': 60, 'Obliques': 20},
        'Secondary': {'Rhomboids': 10, 'Biceps': 10}
    },

    'Resistance Band Side Walk': {
        'Primary': {'Hip Abductors': 70},
        'Secondary': {'Glutes': 30}
    },
    'EZ Barbell Spider Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 20}
    },

    'Dumbbell Incline Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 10, 'Upper Chest': 10}
    },

    'Dumbbell Lateral to Front Raise': {
        'Primary': {'Side Delts': 50, 'Front Deltoid': 50}
    },

    'Barbell Clean grip Front Squat': {
        'Primary': {'Quadriceps': 60, 'Core': 20},
        'Secondary': {'Glutes': 10, 'Hamstrings': 10}
    },

    'Barbell Lying Close grip Triceps Extension': {
        'Primary': {'Triceps': 90},
        'Secondary': {'Chest': 5, 'Shoulders': 5}
    },

    'Cable Rear Pulldown': {
        'Primary': {'Latissimus Dorsi': 70},
        'Secondary': {'Posterior Deltoids': 15, 'Biceps': 15}
    },

    'Dumbbell finger curls': {
        'Primary': {'Forearm Flexors': 100}
    },

    'Cable Y raise': {
        'Primary': {'Front Deltoid': 50, 'Side Delts': 50}
    },

    'Front Plank': {
        'Primary': {'Core': 60},
        'Secondary': {'Shoulders': 20, 'Back': 20}
    },

    'Dumbbell Single Leg Split Squat': {
        'Primary': {'Quadriceps': 60, 'Glutes': 30},
        'Secondary': {'Hamstrings': 10}
    },

    'Cable Incline Triceps Extension': {
        'Primary': {'Triceps': 90},
        'Secondary': {'Chest': 5, 'Shoulders': 5}
    },

    'Dumbbell Lying Supine Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
    },

    'Cable Standing Up Straight Crossovers': {
        'Primary': {'Chest': 80},
        'Secondary': {'Front Deltoid': 20}
    },

    'Glute Ham Raise': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 15, 'Calves': 15}
    },

    'Sumo Squat': {
        'Primary': {'Quadriceps': 40, 'Glutes': 30, 'Adductors': 20},
        'Secondary': {'Hamstrings': 10}
    },

    'Handboard Slope Hang': {
        'Primary': {'Forearms': 50, 'Grip Strength': 50}
    },

    'Dumbbell Bent Over Alternate Rear Delt Fly': {
        'Primary': {'Posterior Deltoids': 80},
        'Secondary': {'Traps': 10, 'Rhomboids': 10}
    },

    'Barbell Pendlay Row': {
        'Primary': {'Latissimus Dorsi': 60, 'Traps': 20},
        'Secondary': {'Rhomboids': 10, 'Biceps': 10}
    },

    'Groin Crunch': {
        'Primary': {'Adductors': 70},
        'Secondary': {'Obliques': 30}
    },

    'Dumbbell Single Leg Step Up': {
        'Primary': {'Quadriceps': 50, 'Glutes': 40},
        'Secondary': {'Hamstrings': 5, 'Balance': 5}
    },

    'Barbell Lying Triceps Extension': {
        'Primary': {'Triceps': 90},
        'Secondary': {'Chest': 5, 'Shoulders': 5}
    },

    'Hip Thrusts': {
        'Primary': {'Glutes': 70},
        'Secondary': {'Hamstrings': 30}
    },

    'Bear Plank': {
        'Primary': {'Core': 50, 'Shoulders': 50}
    },

    'Resistance Band Triceps Pushdown': {
        'Primary': {'Triceps': 100}
    },

    'Dumbbell One Arm Hammer Preacher Curl': {
        'Primary': {'Brachialis': 50, 'Biceps Brachii': 50}
    },

    'Dumbbell Incline Front Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 20}
    },

    'Dumbbell One Arm Standing Hammer Curl': {
        'Primary': {'Brachialis': 50, 'Biceps Brachii': 50}
    },

    'Dumbbell Straight Arm Pullover': {
        'Primary': {'Latissimus Dorsi': 70},
        'Secondary': {'Chest': 15, 'Triceps': 15}
    },

    'Barbell Narrow Row': {
        'Primary': {'Latissimus Dorsi': 60, 'Traps': 20},
        'Secondary': {'Rhomboids': 10, 'Biceps': 10}
    },

    'Calf Raise from Deficit with Chair Supported': {
        'Primary': {'Calves': 100}
    },

    'Dumbbell Seated Upright Alternate Squeeze Press': {
        'Primary': {'Shoulders': 70},
        'Secondary': {'Triceps': 20, 'Upper Chest': 10}
    },

    'Barbell Lying Close grip Press': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Chest': 30}
    },

    'Captains Chair Straight Leg Raise': {
        'Primary': {'Rectus Abdominis': 70},
        'Secondary': {'Hip Flexors': 30}
    },

    'Cable Unilateral Bicep Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
    },

    'Dumbbell Lying Floor Skullcrusher': {
        'Primary': {'Triceps': 90},
        'Secondary': {'Chest': 5, 'Shoulders': 5}
    },

    'Dumbbell Revers grip Biceps Curl': {
        'Primary': {'Brachialis': 60, 'Biceps Brachii': 40}
    },

    'Cable Forward Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 20}
    },

    'Elevanted Push Up': {
        'Primary': {'Chest': 50, 'Triceps': 30},
        'Secondary': {'Shoulders': 20}
    },

    'Dumbbell Incline Two Front Raise with Chest Support': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 20}
    },

    'Dumbbell Reverse Bench Press': {
        'Primary': {'Chest': 60},
        'Secondary': {'Triceps': 20, 'Front Deltoid': 20}
    },

    'Dumbbell High Curl': {
        'Primary': {'Side Delts': 50, 'Trapezius': 30},
        'Secondary': {'Biceps': 20}
    },

    'Dumbbell Lying Femoral': {
        'Primary': {'Hamstrings': 100}
    },

    'Close Grip Push up': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Chest': 30}
    },

    'Dumbbell One Arm Front Raise': {
        'Primary': {'Front Deltoid': 80},
        'Secondary': {'Side Delts': 20}
    },

    'Bench dip on floor': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Chest': 30}
    },

    'Dumbbell Lying One Arm Pronated Triceps Extension': {
        'Primary': {'Triceps': 90},
        'Secondary': {'Chest': 5, 'Shoulders': 5}
    },

    'Dumbbell Biceps Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 10, 'Forearm Flexors': 10}
    },

    'Cable Seated Chest Fly': {
        'Primary': {'Chest': 80},
        'Secondary': {'Front Deltoid': 20}
    },

    'Bench Reverse Crunch Circle': {
        'Primary': {'Rectus Abdominis': 60},
        'Secondary': {'Hip Flexors': 20, 'Obliques': 20}
    },

    'Dumbbell Preacher Curl': {
        'Primary': {'Biceps Brachii': 80},
        'Secondary': {'Brachialis': 20}
    },

    'Dumbbell Bent Over Bench Row': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Posterior Deltoids': 15, 'Biceps': 20, 'Trapezius': 15}
    },
    'Lying T-Bar Row': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Posterior Deltoids': 10, 'Biceps': 20, 'Trapezius': 20}
    },
    'Rear Delt Fly (Machine)': {
      'Primary': {'Posterior Deltoids': 80},
      'Secondary': {'Trapezius': 20}
    },
    'Chest Dips': {
      'Primary': {'Pectoralis Major': 60},
      'Secondary': {'Triceps': 30, 'Front Deltoid': 10}
    },
    'Tricep Dips': {
      'Primary': {'Triceps': 70},
      'Secondary': {'Pectoralis Major': 20, 'Front Deltoid': 10}
    },
    'Assisted Chest Dips': {
      'Primary': {'Pectoralis Major': 60},
      'Secondary': {'Triceps': 30, 'Front Deltoid': 10}
    },
    'Assisted Tricep Dips': {
      'Primary': {'Triceps': 70},
      'Secondary': {'Pectoralis Major': 20, 'Front Deltoid': 10}
    },
    'Weighted Neutral Grip Pull Up': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Assisted Neutral Grip Pull Ups': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Neutral Grip Pull Up': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Commando Pull Up': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 5}
    },
    'Band Assisted One Arm Chin Up': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 5}
    },
    'Weighted One Handed Pull Up': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 5}
    },
    'Close Grip Pull Up': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Archer Pull Up': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 10}
    },
    'Chin Up': {
      'Primary': {'Latissimus Dorsi': 45},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Close Grip Chin Up': {
      'Primary': {'Latissimus Dorsi': 45},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Band Assisted Chin Up': {
      'Primary': {'Latissimus Dorsi': 45},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Assisted Close Grip Chin Up': {
      'Primary': {'Latissimus Dorsi': 45},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Pull Up': {
      'Primary': {'Latissimus Dorsi': 50},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10}
    },
    'Single Arm Pull Up': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 5}
    },
    'L-Pull Ups': {
      'Primary': {'Latissimus Dorsi': 40},
      'Secondary': {'Biceps': 25, 'Rhomboids': 15, 'Trapezius': 10, 'Core': 10}
    },
    'Weighted Chin Up': {
      'Primary': {'Latissimus Dorsi': 45},
      'Secondary': {'Biceps': 30, 'Rhomboids': 15, 'Trapezius': 10}
    },
        'Assisted Chin up': {
        'Primary': {'Lats': 50, 'Biceps': 40},
        'Secondary': {'Forearms': 10}
    },
    'Assisted Pullup (Neutral grip)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Shoulders': 10, 'Forearms': 10}
    },
    'Assisted Triceps Dip': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Back Extensions': {
        'Primary': {'Lower Back': 70},
        'Secondary': {'Glutes': 20, 'Hamstrings': 10}
    },
    'Back Lever': {
        'Primary': {'Lats': 50, 'Core': 30},
        'Secondary': {'Shoulders': 20}
    },
    'Band Assisted Dips': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Band Assisted Muscle up': {
        'Primary': {'Lats': 40, 'Biceps': 30},
        'Secondary': {'Triceps': 20, 'Shoulders': 10}
    },
    'Bar Shoulder Press': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Upper Chest': 10}
    },
    'Barbell Bench Squat': {
        'Primary': {'Quads': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Barbell Bent Over Wide Grip Row': {
        'Primary': {'Upper Back': 60, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 10}
    },
    'Barbell Close Grip Bench Press': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Barbell Deadstop Row': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Lower Back': 20}
    },
    'Barbell Decline Close Grip To Skull Press': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Barbell Full Squat': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Lower Back': 10}
    },
    'Barbell Incline Close Grip Bench Press': {
        'Primary': {'Upper Chest': 50, 'Triceps': 40},
        'Secondary': {'Shoulders': 10}
    },
    'Barbell JM Bench Press': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Barbell Rear Lunge': {
        'Primary': {'Glutes': 50, 'Quads': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Barbell Reverse Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
    'Battling Ropes': {
        'Primary': {'Shoulders': 40, 'Arms': 30},
        'Secondary': {'Core': 30}
    },
    'Biceps Curl with Bed Sheet': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Bodyweight Kneeling Triceps Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Bodyweight Standing Biceps Curl': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Bodyweight Standing Military Press': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Upper Chest': 10}
    },
    'Cable Assisted Inverse Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 20, 'Lower Back': 10}
    },
    'Cable Bent Over Row (Rope)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 20}
    },
    'Cable Concentration Extension (on knee)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Decline Fly': {
        'Primary': {'Chest': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Hip Abduction': {
        'Primary': {'Glutes': 80},
        'Secondary': {'Outer Thighs': 20}
    },
    'Cable Kneeling High Row (Rope)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 20}
    },
    'Cable Lateral Pulldown (Rope)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Shoulders': 20}
    },
    'Cable Lateral Pulldown (V Bar)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Shoulders': 20}
    },
    'Cable Low Row with (Rope)': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 20}
    },
    'Cable Lying Biceps Curl': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Cable Lying Extension Pullover (Rope)': {
        'Primary': {'Lats': 50, 'Triceps': 30},
        'Secondary': {'Shoulders': 20}
    },
    'Cable One Arm Biceps Curl': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Cable One Arm Lateral Bent Over': {
        'Primary': {'Rear Deltoids': 60},
        'Secondary': {'Traps': 30, 'Biceps': 10}
    },
    'Cable Overhead Single Arm Triceps Extension (Rope)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Overhead Triceps Extension (Rope)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Pushdown (Rope)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Reverse Grip Pulldown': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Forearms': 20}
    },

    'Cable Single Arm Triceps Pushdown (Rope)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Standing High Cross Triceps Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Standing One Arm Triceps Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Triceps Pushdown (SZ Bar)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Triceps Pushdown (V Bar)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Cable Two Arm Lateral Raise': {
        'Primary': {'Shoulders': 70},
        'Secondary': {'Traps': 30}
    },
    'Chest Dip': {
        'Primary': {'Chest': 60, 'Triceps': 30},
        'Secondary': {'Shoulders': 10}
    },
    'Cobra Push Up': {
        'Primary': {'Triceps': 60, 'Chest': 30},
        'Secondary': {'Shoulders': 10}
    },
    'Dips between Chairs': {
        'Primary': {'Triceps': 60},
        'Secondary': {'Chest': 30, 'Shoulders': 10}
    },
    'Dumbbell Bent Arm Pullover Hold': {
        'Primary': {'Chest': 50, 'Lats': 30},
        'Secondary': {'Triceps': 20}
    },
    'Dumbbell Cuban Press': {
        'Primary': {'Shoulders': 60, 'Upper Back': 30},
        'Secondary': {'Triceps': 10}
    },
    'Dumbbell Devils Press': {
        'Primary': {'Chest': 40, 'Shoulders': 30},
        'Secondary': {'Triceps': 20, 'Legs': 10}
    },
    'Dumbbell Flat Flye Hold': {
        'Primary': {'Chest': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Dumbbell Half Kneeling Military Press': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Core': 10}
    },
    'Dumbbell Incline Press on Exercise Ball': {
        'Primary': {'Chest': 50, 'Shoulders': 30},
        'Secondary': {'Triceps': 20}
    },

    'Dumbbell Lying One Arm Press': {
        'Primary': {'Chest': 50, 'Triceps': 30},
        'Secondary': {'Shoulders': 20}
    },
    'Dumbbell One Arm Reverse Fly (with support)': {
        'Primary': {'Rear Deltoids': 60},
        'Secondary': {'Traps': 30, 'Biceps': 10}
    },
    'Dumbbell Reverse Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
    'Dumbbell Seated Bench Tricep Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Dumbbell Seated Preacher Curl': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Dumbbell Seated Reverse Grip One Arm Overhead Tricep Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Dumbbell Side Lunge': {
        'Primary': {'Quads': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Dumbbell Two Arm Seated Hammer Curl on Exercise Ball': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Dumbbell Walking Lunges': {
        'Primary': {'Quads': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Finger Curls': {
        'Primary': {'Forearms': 80},
        'Secondary': {'Grip': 20}
    },
    'Full Squat Mobility': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Core': 10}
    },
    'Kettlebell Step Up': {
        'Primary': {'Quads': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Kneeling Push Up Row': {
        'Primary': {'Chest': 50, 'Lats': 30},
        'Secondary': {'Triceps': 20}
    },
    'Landmine Rear Lunge': {
        'Primary': {'Glutes': 50, 'Quads': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Lever Hip Extension': {
        'Primary': {'Glutes': 60},
        'Secondary': {'Lower Back': 30, 'Hamstrings': 10}
    },
    'Lever Incline Chest Press': {
        'Primary': {'Chest': 60, 'Triceps': 30},
        'Secondary': {'Shoulders': 10}
    },
    'Lever Leg Extension': {
        'Primary': {'Quads': 80},
        'Secondary': {'Knees': 20}
    },
    'Lever Lying Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Lever Lying Single Leg Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Lever Seated Crunch': {
        'Primary': {'Abs': 80},
        'Secondary': {'Core': 20}
    },
    'Lever Seated Hip Adduction': {
        'Primary': {'Inner Thighs': 80},
        'Secondary': {'Glutes': 20}
    },
    'Lever Seated Leg Extension': {
        'Primary': {'Quads': 80},
        'Secondary': {'Knees': 20}
    },
    'Lever Seated One Leg Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Lying Leg Raise and Hold': {
        'Primary': {'Abs': 70},
        'Secondary': {'Hip Flexors': 30}
    },
    'Machine Back Extension': {
        'Primary': {'Lower Back': 70},
        'Secondary': {'Glutes': 20, 'Hamstrings': 10}
    },
    'Machine Shoulder Press': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Upper Chest': 10}
    },
    'Narrow Squat from Deficit': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Hamstrings': 10}
    },
    'One Leg Floor Calf Raise': {
        'Primary': {'Calves': 80},
        'Secondary': {'Ankles': 20}
    },
    'One Leg Leg Extension': {
        'Primary': {'Quads': 80},
        'Secondary': {'Knees': 20}
    },
    'Resistance Band Bent Leg Kickback (Kneeling)': {
        'Primary': {'Glutes': 60},
        'Secondary': {'Hamstrings': 30, 'Lower Back': 10}
    },

    'Resistance Band Full Squat': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Core': 10}
    },
    'Resistance Band Leg Extension': {
        'Primary': {'Quads': 70},
        'Secondary': {'Hip Flexors': 30}
    },
    'Resistance Band Leg Lift': {
        'Primary': {'Glutes': 60, 'Quads': 30},
        'Secondary': {'Hamstrings': 10}
    },
    'Resistance Band Seated Single Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Seated Lever Machine Row': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 20}
    },
    'Seated Machine Row': {
        'Primary': {'Lats': 50, 'Biceps': 30},
        'Secondary': {'Rear Deltoids': 20}
    },
    'Seated Overhead Press (Barbell)': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Upper Chest': 10}
    },

    'Self Assisted Inverse Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Side Bridge': {
        'Primary': {'Obliques': 70},
        'Secondary': {'Core': 30}
    },
    'Single Leg Hip Thrust': {
        'Primary': {'Glutes': 60},
        'Secondary': {'Hamstrings': 30, 'Lower Back': 10}
    },
    'Pistol Squat': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Hamstrings': 10}
    },
    'Sit Up': {
        'Primary': {'Abs': 70},
        'Secondary': {'Hip Flexors': 30}
    },
    'Smith Calf Raise': {
        'Primary': {'Calves': 80},
        'Secondary': {'Ankles': 20}
    },
    'Smith Full Squat': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Core': 10}
    },
    'Smith Machine Standing Overhead Press': {
        'Primary': {'Shoulders': 60},
        'Secondary': {'Triceps': 30, 'Upper Chest': 10}
    },
    'Smith Rear Lunge': {
        'Primary': {'Glutes': 50, 'Quads': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Squat Hold Calf Raise': {
        'Primary': {'Calves': 70},
        'Secondary': {'Quads': 30}
    },
    'Suspender Arm Curl': {
        'Primary': {'Biceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Suspender Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Suspender Squat': {
        'Primary': {'Quads': 60},
        'Secondary': {'Glutes': 30, 'Core': 10}
    },
    'Suspender Straight Hip Leg Curl': {
        'Primary': {'Hamstrings': 70},
        'Secondary': {'Glutes': 30}
    },
    'Suspender Triceps Extension': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Shoulders': 30}
    },
    'Walking Lunge': {
        'Primary': {'Quads': 50, 'Glutes': 30},
        'Secondary': {'Hamstrings': 20}
    },
    'Weighted Crunch': {
        'Primary': {'Abs': 70},
        'Secondary': {'Hip Flexors': 30}
    },
    'Weighted Push Up': {
        'Primary': {'Chest': 50, 'Shoulders': 30},
        'Secondary': {'Triceps': 20}
    },
       'Cable Seated Horizontal Shrug': {
        'Primary': {'Traps': 70},
        'Secondary': {'Rear Deltoids': 20, 'Biceps': 10}
    },
    'Cable Standing Pulldown (Rope)': {
        'Primary': {'Lats': 60},
        'Secondary': {'Biceps': 30, 'Rear Deltoids': 10}
    },
    'Cable Triceps Pushdown (SZ bar)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Cable Triceps Pushdown (V bar)': {
        'Primary': {'Triceps': 70},
        'Secondary': {'Forearms': 30}
    },
    'Dumbbell Over Bench Neutral Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
    'Dumbbell Over Bench Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
    'Dumbbell Over Bench Reverse Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
        'Dumbbell Over Bench One Arm Wrist Curl': {
        'Primary': {'Forearms': 70},
        'Secondary': {'Biceps': 30}
    },
};

filesSet = set()

def iterate_through_folders(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            try:
                exerciseMuscles[file.split('.')[0]]
            except Exception as e:
                print(file)
print("############# Images that don't have dictionary ###############")
root_dir = "Exercises/"  # replace with the directory you want to iterate through
iterate_through_folders(root_dir)

print("############# Dictionary that don't have images ###############")

for exercise in exerciseMuscles:
    try:
        open(f'Exercises/{exercise}.png')
    except Exception as e:
        print(exercise)

def rename_files_with_extension_word(directory):
    # Loop through all files in the directory
    for filename in os.listdir(directory):
        # Check if 'extension' exists in the filename
        if 'with Rope' in filename:
            # Replace 'extension' with 'Extension'
            new_filename = filename.replace('with Rope', 'Rope')
            old_file = os.path.join(directory, filename)
            new_file = os.path.join(directory, new_filename)
            
            # Rename the file
            os.rename(old_file, new_file)
            print(f"Renamed: {filename} -> {new_filename}")

# Example usage
directory_path = "Exercises/"

rename_files_with_extension_word(directory_path)