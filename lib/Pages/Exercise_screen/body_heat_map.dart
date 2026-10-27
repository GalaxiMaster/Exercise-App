import 'package:exercise_app/utils.dart'; // Color.toHex(), redVal, greenVal, blueVal
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart' as xml;

class BodyHeatMap extends StatefulWidget {
  const BodyHeatMap({
    super.key,
    required this.assetPath,
    required this.muscleMap,
    this.width = 500,
  });

  final String assetPath;

  /// Muscle name (an SVG class) to percentage
  final Map muscleMap;
  final double width;

  @override
  State<BodyHeatMap> createState() => _BodyHeatMapState();
}

class _BodyHeatMapState extends State<BodyHeatMap> {
  late Future<String> _svg = _load();

  Future<String> _load() async => applyHeatMap(await rootBundle.loadString(widget.assetPath), widget.muscleMap);

  @override
  void didUpdateWidget(BodyHeatMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        !mapEquals(oldWidget.muscleMap, widget.muscleMap)) {
      _svg = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svg,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Could not load the body map');
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return SvgPicture.string(snapshot.data!, width: widget.width);
      },
    );
  }
}

/// Fills every SVG path whose class contains a muscle name with a red shade
/// (darker for higher percentages), then the body outline with grey.
String applyHeatMap(String svgSource, Map muscleMap) {
  final document = xml.XmlDocument.parse(svgSource);

  void paint(String className, Color color) {
    final hex = color.toHex();
    for (final path in document.findAllElements('path')) {
      if (path.getAttribute('class')?.contains(className) ?? false) {
        path.setAttribute('fill', hex);
      }
    }
  }

  for (final entry in muscleMap.entries) {
    final value = entry.value;
    if (value is! num) continue;
    paint(entry.key.toString(), redShade(value / 100));
  }
  paint('Body', Colors.grey);

  return document.toXmlString(pretty: true);
}

/// A shade from light red (0) to dark red (1).
Color redShade(
  double intensity, {
  Color lightShade = const Color.fromARGB(255, 240, 111, 109),
  Color darkShade = const Color(0xFF8B0000),
}) {
  final t = intensity.clamp(0.0, 1.0).toDouble();
  int mix(int start, int end) => (start + (end - start) * t).round().clamp(0, 255);

  return Color.fromARGB(
    255,
    mix(lightShade.redVal, darkShade.redVal),
    mix(lightShade.greenVal, darkShade.greenVal),
    mix(lightShade.blueVal, darkShade.blueVal),
  );
}