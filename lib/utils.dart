import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Options {
  Map<String, int> timeOptions = {
    'Past Week': 7,
    'Past Month': 30,
    'Past 8 weeks': 56,
    'Past 3 months': 90,
    'Past 6 months': 180,
    'Past year': 365,
    'All Time': -1,
  };
  Map<String, String> muscleOptions = {
    'Chest': 'Chest',
    'Back': 'Back',
    'Legs': 'Legs',
    'Core': 'Core',
    'Shoulders': 'Shoulders',
    'All Muscles': 'All Muscles',
  };
}

Color getColor(String key) {
  var colors = {
    'Chest': Colors.red,
    'Upper Chest': Colors.pinkAccent,
    'Lower Chest': Colors.deepOrange,
    'Triceps': Colors.orange,
    'Biceps': Colors.purpleAccent.shade700,
    'Front Delts': Colors.blue,
    'Side Delts': Colors.cyan,
    'Rear Delts': Colors.teal,
    'Traps': Colors.deepPurple,
    'Forearms': Colors.brown,
    'Lats': Colors.indigo, // unchanged
    'Erectors': Colors.green,
    'Rhomboids': Colors.greenAccent,
    'Glutes': Colors.deepOrangeAccent,
    'Quads': Colors.yellow,
    'Hamstrings': Colors.amber,
    'Calves': Colors.lime,
    'Abdominals': Colors.lightBlueAccent,
    'Obliques': Colors.blueGrey,
    'Hip Flexors': Colors.lightGreen
  };

  return colors[key] ?? Colors.grey;
}


class ComparisonStatTile{
  final String title;
  num value;
  num change;
  String unit;

  ComparisonStatTile({
    required this.title,
    required this.value,
    required this.change,
    required this.unit,
  });
}

extension ColorExtension on Color {
  int get redVal   => (r * 255).round().clamp(0, 255);
  int get greenVal => (g * 255).round().clamp(0, 255);
  int get blueVal  => (b * 255).round().clamp(0, 255);
  int get alphaVal  => (a * 255).round().clamp(0, 255);

  String toHex() => '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}
extension HexColor on Color {
  static Color fromHex(String hex) {
    final buffer = StringBuffer();

    String cleanHex = hex.replaceFirst('#', '');

    // If RGB, assume fully opaque
    if (cleanHex.length == 6) {
      buffer.write('FF');
    }

    buffer.write(cleanHex);

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class WorkoutMetaData {
  final String? routineId;
  final Color? color;
  WorkoutMetaData({this.routineId, this.color});
  
  Map toMap(){
    Map res = {};
    if (routineId != null) res['routineId'] = routineId;
    if (color != null) res['color'] = color!.toHex();

    return res;
  }
}

// Used for calculating differences between current and previous values in chart pages
num calculateDifference(num current, num? previous) {
  if (previous == null) {
    return 0;
  }
  return current - previous;
}

int getNormalSetNumber(String exercise, int currentIndex, List sets) {
  int normalSetCount = 0;
  
  for (int j = 0; j <= currentIndex; j++) {
    if (sets[j]['type'] != 'Warmup') {
      normalSetCount++;
    }
  }     

  return normalSetCount;
}

enum PRType { none, weight, reps, first }

class PRResult {
  final bool isPR;
  final PRType type;

  PRResult(this.isPR, this.type);
}

class Lift {
  final double weight;
  final double reps;

  Lift(this.weight, this.reps);
}

Lift? liftFromSet(Map set) {
  if (set['weight'] == '' || set['reps'] == '') return null;
  return Lift(
    double.tryParse(set['weight'].toString()) ?? 0,
    double.tryParse(set['reps'].toString()) ?? 0,
  );
}

bool isBetter(Lift a, Lift b) {
  if (a.weight != b.weight) return a.weight > b.weight;
  return a.reps > b.reps;
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int weekNumber = (dayOfYear - date.weekday + 10) ~/ 7;
  return weekNumber;
}

class ButtonDetails {
  final String title;
  final IconData icon;
  final Widget destination;

  ButtonDetails({
    required this.title,
    required this.icon,
    required this.destination,
  });
}

dynamic deepCopy(dynamic value) {
  if (value is Map) return value.map((k, v) => MapEntry(k, deepCopy(v)));
  if (value is List) return value.map(deepCopy).toList();
  return value;
}

String capitalise(String value) {
  final String fl = value[0];
  return '${fl.toUpperCase()}${value.substring(1, value.length)}';
}