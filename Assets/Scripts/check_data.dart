// ignore_for_file: avoid_print

import 'dart:io';
import 'package:exercise_app/muscleinformation.dart';

void main() {
 final scriptDir = File(Platform.script.toFilePath()).parent;

  final basePath = Directory('${scriptDir.parent.parent.path}/assets/exercises');

  print('############# Images that don\'t have dictionary ###############');
  iterateThroughFolders(basePath, exerciseMuscles);

  print('############# Dictionary that don\'t have images ###############');
  for (var exercise in exerciseMuscles.keys) {
    final filePath = '${basePath.path}/$exercise.png';
    final file = File(filePath);
    if (!file.existsSync()) {
      print(exercise);
    }
  }
}

void iterateThroughFolders(Directory rootDir, Map<String, dynamic> exerciseMuscles) {
  if (!rootDir.existsSync()) {
    print('Directory does not exist: ${rootDir.path}');
    return;
  }

  rootDir.listSync(recursive: true).forEach((entity) {
    if (entity is File) {
      final fileName = entity.uri.pathSegments.last.split('.').first;
      if (!exerciseMuscles.containsKey(fileName)) {
        print(fileName);
        // Uncomment the line below to delete the file if it's not in the dictionary
        // entity.deleteSync();
      }
    }
  });
}
