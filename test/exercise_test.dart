// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Future<void> writeJsonFile(String path, dynamic data) async {
  final file = File(path);
  final encoder = JsonEncoder.withIndent('  '); // 2-space indent
  final jsonString = encoder.convert(data);
  await file.writeAsString(jsonString);
}

Future<Map<String, dynamic>> readJsonFile(String path) async {
  final file = File(path);
  final jsonString = await file.readAsString();
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

String stripJsonComments(String input) {
  final buffer = StringBuffer();
  bool inString = false;
  bool inSingleLineComment = false;
  bool inMultiLineComment = false;

  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    final next = i + 1 < input.length ? input[i + 1] : '';

    if (inSingleLineComment) {
      if (char == '\n') {
        inSingleLineComment = false;
        buffer.write(char);
      }
      continue;
    }

    if (inMultiLineComment) {
      if (char == '*' && next == '/') {
        inMultiLineComment = false;
        i++;
      }
      continue;
    }

    if (inString) {
      buffer.write(char);
      if (char == r'\') {
        // preserve escaped char
        if (i + 1 < input.length) {
          buffer.write(input[i + 1]);
          i++;
        }
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }

    if (char == '"') {
      inString = true;
      buffer.write(char);
    } else if (char == '/' && next == '/') {
      inSingleLineComment = true;
      i++;
    } else if (char == '/' && next == '*') {
      inMultiLineComment = true;
      i++;
    } else {
      buffer.write(char);
    }
  }

  return buffer.toString();
}

String removeTrailingCommas(String input) {
  return input.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
}

Future<Map<String, dynamic>> readJsoncFile(String path) async {
  final raw = await File(path).readAsString();
  final noComments = stripJsonComments(raw);
  final cleaned = removeTrailingCommas(noComments);
  return jsonDecode(cleaned) as Map<String, dynamic>;
}

String scriptRelativePath(String relativePath) {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return File('${scriptDir.path}/$relativePath').path;
}

void main() {
  test('All ids correctly formatted', () async {
    Map muscleInfo = await readJsoncFile(scriptRelativePath('data/exercise_muscles.json'));
    
    for (var entry in muscleInfo.entries) {
      final id = entry.key;

      expect(id, matches(RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$')), reason: 'Invalid id format for $id');
    }
  });
  test('Format all ids', () async {
    Map<String, dynamic> muscleInfo = await readJsoncFile(scriptRelativePath('data/exercise_muscles.json'));
    Map<String, dynamic> fixMap = {};
    for (var entry in muscleInfo.entries) {
      final id = entry.key;
      if (RegExp(r'^[a-z0-9]+(_[a-z0-9]+)*$').hasMatch(id)) {
        continue;
      } else {
        fixMap[id] = entry.value;
      }
    }
    for (var entry in fixMap.entries) {
      final id = entry.key;
      final newId = id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
      muscleInfo.remove(id);
      muscleInfo[newId] = entry.value;
    }
    await writeJsonFile(scriptRelativePath('data/exercise_muscles.json'), muscleInfo);
    print('Fixed ids: ${fixMap.keys.join(', ')}');
  });
  test('All exercises exist', () async {
    Map<String, dynamic> muscleInfo = await readJsoncFile(scriptRelativePath('data/exercise_muscles.json'));

    Map<String, dynamic> groupedExercises = await readJsoncFile(scriptRelativePath('data/grouped_exercises.jsonc'));
    List<String> flattenedGroups = groupedExercises.values.cast<Map<String, dynamic>>().expand((variants) => variants.values.cast<String>()).toList();
    
    List<String> notExistsInMuscleInfo = [];
    for (var id in muscleInfo.keys) {
      if (!flattenedGroups.contains(id)) {
        notExistsInMuscleInfo.add(id);
      }
    }
    List<String> notExistsInGrouped = [];
    for (var id in flattenedGroups) {
      if (!muscleInfo.containsKey(id)) {
        notExistsInGrouped.add(id);
      }
    }
    
    expect(notExistsInMuscleInfo, [], reason: 'The following exercises do not exist in grouped_exercises.jsonc: ${notExistsInMuscleInfo.join('\n - ')}');
    expect(notExistsInGrouped, [], reason: 'The following exercises do not exist in exercise_muscles.jsonc: ${notExistsInGrouped.join('\n - ')}');
  });

  test('All images exist', () async {
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
            // entity.deleteSync();p
          }
        }
      });
    }
    final scriptDir = File(Platform.script.toFilePath()).parent;
    final basePath = Directory('${scriptDir.path}/assets/exercises');
    final Map<String, dynamic> exerciseMuscles = await readJsoncFile(scriptRelativePath('data/exercise_muscles.json'));

    print('########################################### Images that don\'t have dictionary #############################################');
    iterateThroughFolders(basePath, exerciseMuscles);

    print('########################################### Dictionary that don\'t have images #############################################');
    for (var exercise in exerciseMuscles.entries) {
      final key = exercise.key;
      final value = exercise.value;
      final filePath = '${basePath.path}/$key.png';
      final file = File(filePath);
      if (!file.existsSync()) {
        print(value['name']);
      }
    }
  });


  test('Rename Images', () async {
    final scriptDir = File(Platform.script.toFilePath()).parent;
    final basePath = Directory('${scriptDir.path}/assets/exercises');
    final Map<String, dynamic> exerciseMuscles = await readJsoncFile(scriptRelativePath('data/exercise_muscles.json'));

    for (var exercise in exerciseMuscles.entries) {
      final key = exercise.key;
      final value = exercise.value;
      final filePath = '${basePath.path}/${value['name']}.png';
      final file = File(filePath);
      if (file.existsSync()) {
        print(value['name']);
        file.renameSync('${basePath.path}/$key.png');
      }
    }
  });
  
  // Add tests to verify json files for correct data structure
}