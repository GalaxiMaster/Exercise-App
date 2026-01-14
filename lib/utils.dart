import 'dart:ui';

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