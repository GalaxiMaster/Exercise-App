from datetime import datetime, timedelta
import json
import random
from thefuzz import fuzz
import csv
import pandas as pd

balls = {'Flat dumbbell chests press': 'Dumbbell Bench Press', 'Lat pull downs (neutral)': 'Cable Neutral Grip Lat Pulldown', 'Lat pull downs': 'Cable Neutral Grip Lat Pulldown', 'Barbell curls': 'Barbell Curl', 'Cable rows': 'Cable seated row', 'Dumbbell shoulder press': 'Dumbbell Seated Shoulder Press', 'Lat raise (cable)': 'Cable One Arm Lateral Raise', 'Leg raise': 'Lying Leg Raise', 'Flat dumbell chests press': 'Dumbbell Bench Press', 'External rotations': 'Cable Half Kneeling External Rotation', 'Internal rotations': 'Cable Seated Shoulder Internal Rotation', 'Pullup': 'Pull Up', 'Chinups': 'Chin Up', 'Neutral grip pullups': 'Neutral Grip Pull Up', 'Incline dumbell chest press': 'Dumbbell Incline Bench Press', 'Tricep pushdowns': 'Cable Pushdown (Rope)', 'Overhead tricep extensions (edge)': 'Cable Overhead Triceps Extension (Rope)', 'Flat dumbell chest press': 'Dumbbell Bench Press', 'Seated bicep curls': 'Dumbbell Seated Bicep Curl', 'Flat dumbbell chest press': 'Dumbbell Bench Press', 'Cable Lat raises': 'Cable One Arm Lateral Raise', 'Shoulder press': 'Dumbbell Seated Shoulder Press', 'Rear felt flies': 'Rear Delt Fly (Machine)', 'Cable Rows': 'Cable seated row', 'Dumbell lat raises': 'Cable One Arm Lateral Raise', 'Flat Dumbbell chest press': 'Dumbbell Bench Press', 'tricep pushdowns': 'Cable Pushdown (Rope)', 'Rear delt flies': 'Rear Delt Fly (Machine)', 'Overhead prsss': 'Seated Overhead Press (Barbell)', 'Lat raise': 'Cable One Arm Lateral Raise', 'Overhead tricep extention': 'Cable Overhead Triceps Extension (Rope)', 'Assisted dips': 'Assisted Triceps Dip', 'Rows': 'Seated cable row', 'Preacher curls': 'Barbell Preacher Curl', 'Machine lat pull downs': 'Machine Lat Pulldowns', 'Machine rows': 'Seated Lever Machine Row', 'dumbbell lat raises': 'Dumbbell Lateral Raise', 'shoulder press': 'Dumbbell Seated Shoulder Press', 'Incline dumbbell chest preds': 'Dumbbell Incline Bench Press', 'Overhead tricep extention (edge)': 'Cable Overhead Triceps Extension (Rope)', 'Barbell bicep curl': 'Barbell Curl', 'Neutral Lat pull downs': 'Cable Neutral Grip Lat Pulldown', 'Cable lat raises': 'Cable One Arm Lateral Raise', 'Pullups': 'Pull Up', 'Tricep pushdowns (edge one)': 'Cable Pushdown (Rope)', 'Tricep pushdowns (edge)': 'Cable Pushdown (Rope)', 'Overhead press': 'Standing Overhead Press (Barbell)', 'Back extentions': 'Back Extensions', 'Assisted neutral Pullups': 'Assisted Neutral Grip Pull Ups', 'Flat Barbell bench': 'Barbell Bench Press', 'Band assisted dips': 'Band Assisted Dips', 'Dumbbell preacher curls': 'Dumbbell Preacher Curl', 'Tricep pushdowns edge': 'Cable Pushdown (Rope)', 'Incline chest press': 'Dumbbell Incline Bench Press', 'Lat raises': 'Cable Single Arm Lateral Raise', 'Cable curls': 'Cable One Arm Biceps Curl', 'Behind curls': 'Finger Curls', 'Lat pullovers': 'Cable Pullover', 'Incline Barbell bench press': 'Barbell Incline Bench Press', 'Banded dips': 'Band Assisted Dips', 'Flat Barbell chests press': 'Barbell Bench Press', 'Tricep pushdowns kirrawee': 'Cable Pushdown (Rope)', 'Concentration curls': 'Dumbbell Concentration Curl', 'Assisted neutral grip pullups': 'Assisted Neutral Grip Pull Ups', 'Tricep push downs': 'Cable Pushdown (Rope)', 'Chests flies': 'Machine Chest Fly', 'Incline dumbbell chest press': 'Dumbbell Incline Bench Press', 'Chest flies': 'Machine Chest Fly', 'Bicep curl': 'Dumbbell Biceps Curl', 'Bicep curls supported': 'Dumbbell Preacher Curl', 'incline dumbbell chest press': 'Dumbbell Incline Bench Press', 'Close grip Cable rows': 'Cable seated row', 'Isolated bicep curls': 'Dumbbell Preacher Curl', 'Incline Barbell chests press': 'Barbell Incline Bench Press', 'Single arm overhead tricep extention': 'Cable Overhead Tricep Single Arm Triceps Extension (Rope)', 'Dumbbell rows': 'Dumbbell Bent Over Bench Row', 'Over head tricep': 'Cable Overhead Single Arm Triceps Extension (Rope)'}
exerciseMuscles = exerciseMuscles = {
"Cable Pushdown": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Squat (arms overhead)": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10,
            "Front Delts": 10
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
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "bodyweight"
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
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 15,
            "Front Delts": 15
        },
        "type": "bodyweight"
    },
    "Chest Dip on Straight Bar": {
        "Primary": {
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 20
        },
        "type": "bodyweight"
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
    "Dumbbell Seated Upright Alternate Squeeze Press": {
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
        "type": "bodyweight"
    },
    "Dumbbell Lying One Arm Pronated Triceps Extension": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Chest": 5,
            "Front Delts": 5
        },
        "type": "Weighted"
    },
    "Assisted Triceps Dip": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
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
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "banded"
    },
    "Band Assisted Muscle Up": {
        "Primary": {
            "Lats": 40,
            "Biceps": 30
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "banded"
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
    "Battling Ropes": {
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
        "type": "bodyweight"
    },
    "Bodyweight Standing Military Press": {
        "Primary": {
            "Front Delts": 50,
            "Side Delts": 10
        },
        "Secondary": {
            "Triceps": 30,
            "Upper Chest": 10
        },
        "type": "bodyweight"
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
    "Barbell Wide Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
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
    "Dip on Floor with Chair": {
        "Primary": {
            "Triceps": 60,
            "Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "bodyweight"
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
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Dumbbell Single Leg Deadlift": {
        "Primary": {
            "Hamstrings": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10,
            "Balance & Stability": 10
        },
        "type": "Weighted"
    },
    "Lever Seated Squat": {
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
    "Lever Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
        },
        "type": "Weighted"
    },
    "Cable One Arm High Pulley Overhead Tricep Extension": {
        "Primary": {
            "Triceps (long head)": 80
        },
        "Secondary": {
            "Triceps (lateral & medial heads)": 20
        },
        "type": "Weighted"
    },
    "Self assisted Inverse Leg Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Calves": 20
        },
        "type": "Weighted"
    },
    "Cross Body Twisting Crunch": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Abdominals": 40
        },
        "type": "bodyweight"
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
    "Weighted Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
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
    "Smith Front Squat (Clean Grip)": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
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
    "Cable Curl with Multipurpose V bar": {
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
    "Reverse Crunch m": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "bodyweight"
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
    "Assisted Hanging Knee Raise": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
        },
        "type": "Weighted"
    },
    "Leg Raise Hip Lift": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
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
    "Kettlebell One Legged Deadlift": {
        "Primary": {
            "Hamstrings": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10,
            "Balance": 10
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
    "Bodyweight Wall Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "bodyweight"
    },
    "Resistance Band Seated Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "banded"
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
    "Dumbbell Curtsey lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Dumbbell Step Up Single Leg Balance with Bicep Curl": {
        "Primary": {
            "Quads": 40,
            "Glutes": 30,
            "Biceps": 20
        },
        "Secondary": {
            "Hamstrings": 5,
            "Balance": 5
        },
        "type": "Weighted"
    },
    "Kettlebell Kickstand One Leg Deadlift": {
        "Primary": {
            "Hamstrings": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10,
            "Balance": 10
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
    "Lying Double Legs Biceps Curl with Towel": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Barbell Standing Rocking Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
    "Cable Overhead Tricep Extension Straight Bar": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Crunch (hands overhead)": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "bodyweight"
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
    "Bodyweight Bent Over Rear Delt Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "bodyweight"
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
    "Dumbbell Goblet Box Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Split Lateral Squat with Roll": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10,
            "Adductors": 10
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
        "type": "bodyweight"
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
    "Cable Standing One Arm Tricep Pushdown (Overhand Grip)": {
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
    "Cable One Arm Straight Back High Row (kneeling)": {
        "Primary": {
            "Rhomboids": 30,
            "Trapezius": 30
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Traps": 10
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
        "type": "banded"
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
    "Dumbbell Gobelt Curtsey Lunge": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Safety Bar Front Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
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
        "type": "bodyweight"
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
    "Resistance Band Assisted Nordic Hamstring Curl": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Glutes": 10,
            "Erectors": 10
        },
        "type": "banded"
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
    "Assisted Prone Hamstring": {
        "Primary": {
            "Hamstrings": 80
        },
        "Secondary": {
            "Glutes": 20
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
    "Dumbbell Biceps Curl Reverse": {
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
    "Barbell Standing Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
    "Barbell Single Leg Split Squat": {
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
    "Kettlebell Sumo Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
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
    "Lever Chair Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
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
    "Superman Row with Towel": {
        "Primary": {
            "Trapezius": 30,
            "Rear Delts": 30
        },
        "Secondary": {
            "Rhomboids": 20,
            "Erectors": 20
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
    "Cable Hammer Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
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
        "type": "banded"
    },
    "Superman": {
        "Primary": {
            "Erectors": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 20
        },
        "type": "Weighted"
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
    "Cable Reverse Grip Triceps Pushdown (with arm blaster)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Dumbbell Fly (knees at 90 degrees)": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Lever Deadlift (plate loaded)": {
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
    "Bodyweight Squatting Row (with towel)": {
        "Primary": {
            "Back": 50
        },
        "Secondary": {
            "Biceps": 30,
            "Quads": 20
        },
        "type": "bodyweight"
    },
    "Bodyweight Pulse Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10
        },
        "type": "bodyweight"
    },
    "Curtsey Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 20
        },
        "type": "Weighted"
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
            "Glutes": 20,
            "Hamstrings": 10,
            "Balance": 10
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
    "Step up on Chair": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
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
    "Dumbbell Lying One Arm Supinated Triceps Extension": {
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
    "Barbell Lying Back of the Head Tricep Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Lats": 20
        },
        "type": "Weighted"
    },
    "Barbell Lying Close Grip Underhand Row on Rack": {
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
    "Cable Fly with Chest Supported": {
        "Primary": {
            "Chest": 80
        },
        "Secondary": {
            "Front Delts": 20
        },
        "type": "Weighted"
    },
    "Cable one arm Lateral pulldown": {
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
        "type": "banded"
    },
    "Cable Kneeling Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "bodyweight"
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
    "Smith Low Bar Squat": {
        "Primary": {
            "Quads": 50,
            "Glutes": 40
        },
        "Secondary": {
            "Hamstrings": 10
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
    "Cable High Pulley Overhead Tricep Extension": {
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
    "Cable Hammer Curl (Rope) m": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Single Leg Deadlift with Knee Lift": {
        "Primary": {
            "Hamstrings": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Erectors": 10,
            "Balance": 10
        },
        "type": "Weighted"
    },
    "Cable Squatting Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Dumbbell Bar Grip Sumo Squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
        },
        "type": "Weighted"
    },
    "Lever Standing Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
    "Barbell Lying Row on Rack": {
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
    "Squat m": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
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
        "type": "bodyweight"
    },
    "Dumbbell Incline Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "Weighted"
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
    "Sled One Leg Calf Press on Leg Press": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
    "One Leg Quarter Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Balance": 10
        },
        "type": "Weighted"
    },
    "Butt ups": {
        "Primary": {
            "Glutes": 70
        },
        "Secondary": {
            "Hamstrings": 20,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Smith Machine Incline Tricep Extension": {
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
    "Kettlebell Front Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
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
    "Bodyweight Side Lying Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
        },
        "type": "bodyweight"
    },
    "Decline Push Up m": {
        "Primary": {
            "Upper Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "bodyweight"
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
    "Cable One Arm Tricep Pushdown": {
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
    "Dumbbell Standing Single Spider Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Weighted one leg hip thrust": {
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
    "Dumbbell Seated One Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Dumbbell Crunch Up": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "bodyweight"
    },
    "Smith Chair Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
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
    "Crunch (arms straight)": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Obliques": 20
        },
        "type": "bodyweight"
    },
    "Trap Bar Split Stance RDL": {
        "Primary": {
            "Hamstrings": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
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
    "Cable Rope One Arm Hammer Preacher Curl": {
        "Primary": {
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
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
    "Single Leg Platform Slide": {
        "Primary": {
            "Adductors": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Quads": 10
        },
        "type": "Weighted"
    },
    "Weighted Seated Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "Weighted"
    },
    "Cable Palm Rotational Row": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Rear Delts": 20,
            "Biceps": 10,
            "Forearms": 10
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
            "Biceps": 60,
            "Brachialis": 30
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Dumbbell Close Grip Curl": {
        "Primary": {
            "Biceps": 80
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
    "Smith Toe Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "Weighted"
    },
    "Barbell Standing Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
    "Cable Close Grip Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
    "Dumbbell Split Squat Front Foot Elevanted": {
        "Primary": {
            "Quads": 70,
            "Glutes": 20
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
    "Vertical Leg Raise (on parallel bars)": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
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
        "type": "bodyweight"
    },
    "Barbell Low Bar Squat": {
        "Primary": {
            "Quads": 50,
            "Glutes": 40
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Barbell Floor Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "Weighted"
    },
    "Dumbbell one leg squat w": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10,
            "Balance": 10
        },
        "type": "Weighted"
    },
    "Bodyweight Standing Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "bodyweight"
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
    "Smith Single Leg Split Squat": {
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
    "Dumbbell Banded Bench Press": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Triceps": 20,
            "Front Delts": 10
        },
        "type": "banded"
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
    "Dumbbell Incline Two Arm Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
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
    "Bench Dip with legs on bench": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "bodyweight"
    },
    "Cable Rope High Pulley Overhead Tricep Extension": {
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
        "type": "bodyweight"
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
    "Sled 45 degrees One Leg Press": {
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
    "Smith Seated Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Cable Rope Incline Tricep Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
        },
        "type": "Weighted"
    },
    "Cable Reverse Grip Triceps Pushdown (SZ bar)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Forearms": 20
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
        "type": "bodyweight"
    },
    "Bodyweight Standing Pulse Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "bodyweight"
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
    "Barbell Front Chest Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 25,
            "Hamstrings": 15
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
    "Triceps Dip (bench leg)": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "bodyweight"
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
    "Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "Weighted"
    },
    "Smith Calf Raise (with block)": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Dumbbell Lying Single Extension": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
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
    "Cable One Arm Preacher Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 15,
            "Forearms": 5
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
    "Hack One Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Bodyweight Standing Row": {
        "Primary": {
            "Back": 60
        },
        "Secondary": {
            "Biceps": 40
        },
        "type": "bodyweight"
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
    "Plyo Sit Squat (wall)": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
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
    "Dumbbell Standing Single Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
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
    "Cable Half Kneeling External Rotation": {
        "Primary": {
            "Rotator Cuff": 80
        },
        "Secondary": {
            "Rear Delts": 20
        },
        "type": "Weighted"
    },
    "Roll Reverse Crunch": {
        "Primary": {
            "Lower Abdominals": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "bodyweight"
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
    "Sled Hack Squat": {
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
    "Sled 45 Calf Press": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Quads": 10
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
    "Barbell sumo squat": {
        "Primary": {
            "Quads": 50
        },
        "Secondary": {
            "Glutes": 30,
            "Adductors": 20
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
    "Dumbbell Zottman Curl": {
        "Primary": {
            "Biceps": 50,
            "Brachialis": 40
        },
        "Secondary": {
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Smith One Leg Floor Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance & Stability": 10
        },
        "type": "Weighted"
    },
    "Bodyweight Step up on Stepbox": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "bodyweight"
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
    "Cable One Arm Lateral Raise": {
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
    "Smith Standing Leg Calf Raise": {
        "Primary": {
            "Calves": 90
        },
        "Secondary": {
            "Balance": 10
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
        "type": "bodyweight"
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
    "Triceps Press (Head Below Bench)": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
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
    "Kettlebell Gobelt Curtsey Lunge": {
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
    "Cable One Arm Wrist Curl": {
        "Primary": {
            "Forearms (flexors)": 90
        },
        "Secondary": {
            "Grip Strength": 10
        },
        "type": "Weighted"
    },
    "Barbell One Leg Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 20,
            "Hamstrings": 10,
            "Balance": 10
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
    "Hanging Straight Leg Raise": {
        "Primary": {
            "Abdominals": 60
        },
        "Secondary": {
            "Hip Flexors": 40
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
    "Cable Standing Cross over High Reverse Fly": {
        "Primary": {
            "Rear Delts": 70
        },
        "Secondary": {
            "Traps": 30
        },
        "type": "Weighted"
    },
    "Weighted Tricep Dips": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
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
    "Cable Standing Lift": {
        "Primary": {
            "Traps": 50,
            "Side Delts": 40
        },
        "Secondary": {
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Lever Overhand Triceps Dip": {
        "Primary": {
            "Triceps": 80
        },
        "Secondary": {
            "Chest": 20
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
    "Lever seated one leg calf raise": {
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
        "type": "bodyweight"
    },
    "Barbell Seated Calf Raise": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Cable Leaning Lateral Raise": {
        "Primary": {
            "Side Delts": 80
        },
        "Secondary": {
            "Front Delts": 10,
            "Traps": 10
        },
        "type": "Weighted"
    },
    "Crunch (straight leg up)": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Hip Flexors": 20
        },
        "type": "bodyweight"
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
    "Weighted Counterbalanced Squat": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Glutes": 15,
            "Hamstrings": 15
        },
        "type": "Weighted"
    },
    "Cable pull through": {
        "Primary": {
            "Glutes": 35,
            "Hamstrings": 35
        },
        "Secondary": {
            "Erectors": 30
        },
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
    "Standing Calf Raise (On a staircase)": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
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
    "Dumbbell One Arm Triceps Extension (on bench)": {
        "Primary": {
            "Triceps": 90
        },
        "Secondary": {
            "Lats": 10
        },
        "type": "Weighted"
    },
    "Bodyweight Frog Pump": {
        "Primary": {
            "Glutes": 35,
            "Adductors": 35
        },
        "Secondary": {
            "Hamstrings": 30
        },
        "type": "bodyweight"
    },
    "Hand Opposite Knee Crunch": {
        "Primary": {
            "Obliques": 70
        },
        "Secondary": {
            "Abdominals": 30
        },
        "type": "bodyweight"
    },
    "Single Leg Calf Raise (on a dumbbell)": {
        "Primary": {
            "Calves": 100
        },
        "Secondary": {},
        "type": "Weighted"
    },
    "Bent over Row with Towel": {
        "Primary": {
            "Lats": 70
        },
        "Secondary": {
            "Biceps": 10,
            "Forearms": 10,
            "Grip Strength": 10
        },
        "type": "Weighted"
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
    "Split Squats": {
        "Primary": {
            "Quads": 35,
            "Glutes": 35
        },
        "Secondary": {
            "Hamstrings": 15,
            "Balance": 15
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
    "Crunch (leg raise)": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "bodyweight"
    },
    "Cable Lying Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Lever Calf Press (plate loaded)": {
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
        "type": "bodyweight"
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
    "Cable Rope Seated Row": {
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
    "Bodyweight Standing Row (with towel)": {
        "Primary": {
            "Lats": 60
        },
        "Secondary": {
            "Biceps": 10,
            "Rear Delts": 10,
            "Forearms": 10,
            "Grip Strength": 10
        },
        "type": "bodyweight"
    },
    "Lever Biceps Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
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
    "Sled 45 Leg Press": {
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
            "Quads": 35,
            "Glutes": 35
        },
        "Secondary": {
            "Hamstrings": 10,
            "Calves": 10,
            "Balance": 10
        },
        "type": "Weighted"
    },
    "Frog Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Hip Flexors": 10,
            "Obliques": 10
        },
        "type": "bodyweight"
    },
    "Tuck Crunch": {
        "Primary": {
            "Abdominals": 80
        },
        "Secondary": {
            "Hip Flexors": 10,
            "Obliques": 10
        },
        "type": "bodyweight"
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
    "Dumbbell Standing One Arm Curl Over Incline Bench": {
        "Primary": {
            "Biceps": 90
        },
        "Secondary": {
            "Brachialis, Forearms": 10
        },
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
            "Biceps": 25,
            "Brachialis": 25
        },
        "Secondary": {
            "Forearms": 50,
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
        "type": "bodyweight"
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
    "Cable Biceps Curl (SZ bar)": {
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
        "type": "bodyweight"
    },
    "Cable Incline Bench Row": {
        "Primary": {
            "Lats": 60,
            "Rhomboids": 10,
            "Trapezius": 10
        },
        "Secondary": {
            "Rear Delts (Posterior Deltoids)": 10,
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
        "type": "bodyweight"
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
    "Dumbbell Incline One Arm Lateral Raise": {
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
    "Cable Standing Face Pull": {
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
    "Bulgarian Split Squat with Chair": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
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
    "Dumbbell Plyo Squat": {
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
        "type": "bodyweight"
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
        "type": "bodyweight"
    },
    "Cable one arm twisting seated row": {
        "Primary": {
            "Lats": 60,
            "Obliques": 20
        },
        "Secondary": {
            "Rhomboids": 10,
            "Biceps": 10
        },
        "type": "Weighted"
    },
    "Resistance Band Side Walk": {
        "Primary": {
            "Hip Abductors": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "banded"
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
    "Dumbbell Single Leg Split Squat": {
        "Primary": {
            "Quads": 60,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
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
    "Groin Crunch": {
        "Primary": {
            "Adductors": 70
        },
        "Secondary": {
            "Obliques": 30
        },
        "type": "bodyweight"
    },
    "Dumbbell Single Leg Step Up": {
        "Primary": {
            "Quads": 50,
            "Glutes": 40
        },
        "Secondary": {
            "Hamstrings": 5,
            "Balance": 5
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
    "Captains Chair Straight Leg Raise": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "Weighted"
    },
    "Cable Unilateral Bicep Curl": {
        "Primary": {
            "Biceps": 80
        },
        "Secondary": {
            "Brachialis": 10,
            "Forearms": 10
        },
        "type": "Weighted"
    },
    "Cable Forward Raise": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 20
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
        "type": "bodyweight"
    },
    "Dumbbell Incline Two Front Raise with Chest Support": {
        "Primary": {
            "Front Delts": 80
        },
        "Secondary": {
            "Side Delts": 20
        },
        "type": "Weighted"
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
    "Dumbbell High Curl": {
        "Primary": {
            "Side Delts": 50,
            "Traps": 30
        },
        "Secondary": {
            "Biceps": 20
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
    "Bench dip on floor": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 30
        },
        "type": "Bodyweight"
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
        "type": "bodyweight"
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
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Front Delts": 10
        },
        "type": "bodyweight"
    },
    "Tricep Dips": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 20,
            "Front Delts": 10
        },
        "type": "bodyweight"
    },
    "Assisted Chest Dips": {
        "Primary": {
            "Chest": 60
        },
        "Secondary": {
            "Triceps": 30,
            "Front Delts": 10
        },
        "type": "Weighted"
    },
    "Assisted Tricep Dips": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Chest": 20,
            "Front Delts": 10
        },
        "type": "Weighted"
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
        "type": "Weighted"
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
        "type": "banded"
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
        "type": "banded"
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
        "type": "Weighted"
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
        "type": "bodyweight"
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
        "type": "bodyweight"
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
        "type": "Weighted"
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

    "Barbell Bench Squat": {
        "Primary": {
            "Quads": 50,
            "Glutes": 30
        },
        "Secondary": {
            "Hamstrings": 20
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
            "Rear Delts (Posterior Deltoids)": 10
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
    "Barbell Full Squat": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Erectors": 10
        },
        "type": "Weighted"
    },
    "Barbell Rear Lunge": {
        "Primary": {
            "Glutes": 50,
            "Quads": 30
        },
        "Secondary": {
            "Hamstrings": 20
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
    "Biceps Curl with Bed Sheet": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "Weighted"
    },
    "Bodyweight Standing Biceps Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
        },
        "type": "bodyweight"
    },
    "Cable Assisted Inverse Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 20,
            "Erectors": 10
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
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
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
    "Cable One Arm Lateral Bent Over": {
        "Primary": {
            "Rear Delts": 60
        },
        "Secondary": {
            "Traps": 30,
            "Biceps": 10
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
    "Cable Pushdown (Rope)": {
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
    "Cable Standing One Arm Triceps Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Cable Triceps Pushdown (SZ Bar)": {
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
    "Cable Two Arm Lateral Raise": {
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
            "Chest": 60,
            "Triceps": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "bodyweight"
    },
    "Cobra Push Up": {
        "Primary": {
            "Triceps": 60,
            "Chest": 30
        },
        "Secondary": {
            "Front Delts": 10
        },
        "type": "bodyweight"
    },
    "Dips between Chairs": {
        "Primary": {
            "Triceps": 60
        },
        "Secondary": {
            "Chest": 30,
            "Front Delts": 10
        },
        "type": "bodyweight"
    },
    "Dumbbell Bent Arm Pullover Hold": {
        "Primary": {
            "Chest": 50,
            "Lats": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "Weighted"
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
    "Dumbbell Flat Flye Hold": {
        "Primary": {
            "Chest": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Incline Press on Exercise Ball": {
        "Primary": {
            "Chest": 50,
            "Front Delts": 30
        },
        "Secondary": {
            "Triceps": 20
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
    "Dumbbell Seated Bench Tricep Extension": {
        "Primary": {
            "Triceps": 70
        },
        "Secondary": {
            "Front Delts": 30
        },
        "type": "Weighted"
    },
    "Dumbbell Seated Preacher Curl": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
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
    "Dumbbell Two Arm Seated Hammer Curl on Exercise Ball": {
        "Primary": {
            "Biceps": 70
        },
        "Secondary": {
            "Forearms": 30
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
            "Forearms": 80
        },
        "Secondary": {
            "Grip": 20
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
    "Kneeling Push Up Row": {
        "Primary": {
            "Chest": 50,
            "Lats": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "bodyweight"
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
            "Quads": 80
        },
        "Secondary": {
            "Knees": 20
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
            "Inner Thighs": 80
        },
        "Secondary": {
            "Glutes": 20
        },
        "type": "Weighted"
    },
    "Lever Seated Leg Extension": {
        "Primary": {
            "Quads": 80
        },
        "Secondary": {
            "Knees": 20
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
    "Lying Leg Raise and Hold": {
        "Primary": {
            "Abdominals": 70
        },
        "Secondary": {
            "Hip Flexors": 30
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
    "Narrow Squat from Deficit": {
        "Primary": {
            "Quads": 60
        },
        "Secondary": {
            "Glutes": 30,
            "Hamstrings": 10
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
    "One Leg Leg Extension": {
        "Primary": {
            "Quads": 80
        },
        "Secondary": {
            "Knees": 20
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
        "type": "banded"
    },
    "Resistance Band Leg Extension": {
        "Primary": {
            "Quads": 70
        },
        "Secondary": {
            "Hip Flexors": 30
        },
        "type": "banded"
    },
    "Resistance Band Leg Lift": {
        "Primary": {
            "Glutes": 60,
            "Quads": 30
        },
        "Secondary": {
            "Hamstrings": 10
        },
        "type": "banded"
    },
    "Resistance Band Seated Single Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
        },
        "type": "banded"
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
    "Self Assisted Inverse Leg Curl": {
        "Primary": {
            "Hamstrings": 70
        },
        "Secondary": {
            "Glutes": 30
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
    "Smith Rear Lunge": {
        "Primary": {
            "Glutes": 50,
            "Quads": 30
        },
        "Secondary": {
            "Hamstrings": 20
        },
        "type": "Weighted"
    },
    "Squat Hold Calf Raise": {
        "Primary": {
            "Calves": 70
        },
        "Secondary": {
            "Quads": 30
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
        "type": "bodyweight"
    },
    "Weighted Push Up": {
        "Primary": {
            "Chest": 50,
            "Front Delts": 30
        },
        "Secondary": {
            "Triceps": 20
        },
        "type": "bodyweight"
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
    "Cable Triceps Pushdown (SZ bar)": {
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
        "type": "Cardio"
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
        "type": "bodyweight"
    },
    "Dead Hang": {
        "Primary": {
            "Forearms": 60,
        },
        "Secondary": {
            "Lats": 30,
            "Shoulders": 15
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
        "type": "Cardio"
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
        "type": "Cardio"
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
    "Jumping Jack": {
        "Primary": {
            "Glutes": 30,
            "Quads": 30
        },
        "Secondary": {
            "Calves": 20,
            "Shoulders": 20
        },
        "type": "Cardio"
    },
    "Plank": {
        "Primary": {
            "Abdominis": 60,
        },
        "Secondary": {
            "Obliques": 20,
            "Shoulders": 15,
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
            "Shoulders": 10,
            "Triceps": 5
        },
        "type": "Bodyweight"
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
        "type": "Cardio"
    },
    "Side Plank": {
        "Primary": {
            "Obliques": 60
        },
        "Secondary": {
            "Glutes": 20,
            "Shoulders": 20
        },
        "type": "Bodyweight"
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
        "type": "Cardio"
    }
}
# with open('thomasdata.csv', 'r') as f:
    # data = csv.reader(f)
    
df = pd.read_csv('ROMEFERNLY.csv', sep=';')
exercises = []
for exercise in df['Exercise Name']:
    if (exercise not in exercises):
        exercises.append(exercise)

print(len(exercises))
# with open("sample.json", "w") as outfile: 
#     json.dump(data, outfile)

matches = {}
needed = []
corrections = {'Pull Up (Weighted)': 'Weighted Pull Up', 'Iso-Lateral Row (Machine)': 'Seated Lever Machine Row', 'Straight Arm Lat Pulldown (Cable)': 'Cable Pullover', 'Seated Cable Row - V Grip (Cable)': 'Cable seated row', 'Single Arm Curl (Cable)': 'Cable One Arm Biceps Curl', 'Bench Press (Barbell)': 'Barbell Bench Press', 'Triceps Dip (Weighted)': 'Weighted Tricep Dips', 'Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Triceps Rope Pushdown': 'Cable Pushdown (Rope)', 'Incline Bench Press (Dumbbell)': 'Dumbbell Incline Bench Press', 'Cable Wrist Curl (Single)': 'Cable One Arm Wrist Curl', 'Seated Palms Up Wrist Curl': 'Dumbbell Seated Palms Up Wrist Curl', 'Bent Over Row (Barbell)': 'Barbell Bent Over Row', 'Bench Press (Dumbbell)': 'Dumbbell Bench Press', 'Bicep Curl (Dumbbell)': 'Dumbbell Biceps Curl', 'Triceps Dip': 'Tricep Dips', 'Triceps Extension (Cable)': 'Cable Overhead Triceps Extension', 'T Bar Row': 'Lying T-Bar Row', 'Lat Pulldown (Machine)': 'Machine Lat Pulldowns', 'Lateral Raise (Dumbbell)': 'Dumbbell Lateral Raise', 'Standing Calf Raise (Smith)': 'Smith Calf Raise', 'Hip Thrust (Barbell)': 'Barbell Hip Thrust', 'Leg Extension (Machine)': 'Lever Leg Extension', 'Deadlift (Barbell)': 'Barbell Deadlift', 'Back Extension (Weighted Hyperextension)': 'Back Extensions', 'Incline Bench Press (Barbell)': 'Barbell Incline Bench Press', 'Chin Up': 'Chin Up', 'Overhead Press (Barbell)': 'Barbell Overhead press', 'Bicep Curl (Cable)': 'Cable Curl', 'Bicep Curl (Barbell)': 'Barbell Curl', 'Chest Fly (Machine)': 'Machine Chest Fly', 'Pull Up': 'Pull Up', 'Rear Delt Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Hammer Curl (Dumbbell)': 'Dumbell Hammer Curl', 'Leg Press (Machine)': 'Sled 45 Leg Press', 'Shoulder Press (Dumbbell)': 'Dumbbell Seated Shoulder Press', 'Cable Pull Through': 'Cable pull through', 'Cable Fly Crossovers': 'Cable Standing Up Straight Crossovers', 'Preacher Curl (Barbell)': 'Barbell Preacher Curl', 'Single Arm Lateral Raise (Cable)': 'Cable One Arm Lateral Raise', 'Hammer Curl (Cable)': 'Cable Hammer Curl', 'Hack Squat': 'Sled Closer Hack Squat', 'Dead Hang': 'Dead Hang', 'Seated Cable Row - Bar Grip': 'Cable Low Seated Row', 'Seated Cable Row - Bar Wide Grip': 'Wide Grip Overhand Row', 'Single Arm Cable Row': 'Cable One Arm Row', 'Lat Pulldown (Cable)': 'Cable Neutral rip Lat Pulldown', 'Leg Raise Parallel Bars': 'Captain Seat Leg Raise', 'Hack Squat (Machine)': 'Sled Hack Squat', 'Farmers Walk': 'Farmer Walk', 'Incline Bench Press (Smith Machine)': 'Smith Machine Incline Bench Press', 'Chin Up (Weighted)': 'Weighted Chin Up', 'Low Cable Fly Crossovers': 'Low Cable Fly', 'Behind the Back Bicep Wrist Curl (Barbell)': 'Barbell Behind the Back Wrist Curls', 'Push Up - Close Grip': 'Push Up', 'Push Up': 'Push up', 'Flat Leg Raise': 'Seated Leg Raise', 'Overhead Press (Dumbbell)': 'Standing Overhead Press (Barbell)', 'Sit Up': 'Sit Up', 'Concentration Curl (Dumbbell)': 'Dumbbell Concentration Curl', 'Front Raise (Dumbbell)': 'Dumbbell Front Raise', 'Triceps Pushdown (Cable - Straight Bar)': 'Cable Pushdown', 'Shoulder Press (Machine)': 'Machine Shoulder Press', 'Chest Dip': 'Chest Dip', 'Incline Curl (Dumbbell)': 'Dumbbell Incline Curl', 'Chest Fly': 'Machine Chest Fly', 'Seated Row (Cable)': 'Seated cable row', 'Triceps Extension (Dumbbell)': 'o', 'Triceps Dip (Assisted)': 'Assisted Tricep Dips', 'Reverse Curl (Barbell)': 'Barbell Reverse Curl', 'Seated Calf Raise (Plate Loaded)': 'Lever Calf Press (plate loaded)', 'Leg Press': 'Sled 45 Leg Press', 'Reverse Fly (Machine)': 'Rear Delt Fly (Machine)', 'Bulgarian Split Squat': 'Bulgarian Split Squat', 'Seated Leg Press (Machine)': 'Lever Seated Leg Press', 'Seated Leg Curl (Machine)': 'Lever Seated Leg Curl', 'Preacher Curl (Machine)': 'Lever Preacher Curl', 'Seated Palms Up Wrist Curl (Dumbbell)': 'Dumbbell Seated Palms Up Wrist Curl', 'flutter kicks': 'Seated Flutter Kick', 'scissors': 'Scissors (advanced)', 'Flutter kicks': 'Seated Flutter Kick', 'Bent Over One Arm Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Bent Over Row (Dumbbell)': 'Dumbbell Bent Over Bench Row', 'Skullcrusher (Dumbbell)': 'Dumbbell Lying Floor Skullcrusher', 'Pullover (Dumbbell)': 'Dumbbell Pullover', 'Reverse Curl (Dumbbell)': 'Dumbbell Bicep Curl Reverse', 'lever Row': 'Seated Lever Machine Row', 'Triceps Extension (Barbell)': 'Barbell Standing Overhead Triceps Extension', 'Skullcrusher (Barbell)': 'Barbell Lying Tricep Extension Skull Crusher', 'Plank': 'Plank', 'Jumping Jack': 'Jumping Jack', 'Crunch': 'Crunch', 'Running': 'Running', 'Reverse Grip Concentration Curl (Dumbbell)': 'Dumbbell Seated Reverse Concentration Curl', 'Arnold Press (Dumbbell)': 'Dumbbell Arnold Press', 'Walking': 'Walking', 'Pull Up (Assisted)': 'Assisted Pull Up', 'Iso-Lateral Chest Press (Machine)': 'Lever Chest Press (plate loaded)', 'Incline Chest Press (Machine)': 'Incline Lever Chest Press', 'Hip Abductor (Machine)': 'Hip Abductor', 'Side Plank': 'Side Plank'}
i = 1
for exercise in exercises:
    matches[exercise] = {}
    for matchingexercise in exerciseMuscles:
        similarity = fuzz.ratio(exercise, matchingexercise)
        if  similarity > 50:
            matches[exercise][matchingexercise] = similarity
    matches[exercise] = dict(sorted(matches[exercise].items(), key=lambda item: item[1], reverse=True))
    if exercise in corrections: continue
    print(f'{exercise} : {matches[exercise]}\n\n')
    correct = input(f'Correct exercise for {exercise} ({i}): ')
    if correct != '':
        corrections[exercise] = correct
    else:
        needed.append(exercise)
    i+=1


print(corrections)
print(needed)