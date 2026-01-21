import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ColorExtension on Color {
  int get redVal   => (r * 255).round().clamp(0, 255);
  int get greenVal => (g * 255).round().clamp(0, 255);
  int get blueVal  => (b * 255).round().clamp(0, 255);

  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
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