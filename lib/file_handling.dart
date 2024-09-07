import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<Map<dynamic, dynamic>> readData({String path = 'output'}) async{
  Map jsonData= {};
  final dir = await getApplicationDocumentsDirectory();
  String filepath = '${dir.path}/$path.json';
  debugPrint(filepath);
  var file = File(filepath);

  // Read the file as a string
  if (await file.exists()) {
    String contents = await file.readAsString();
    if (contents.isNotEmpty){
      jsonData = jsonDecode(contents);
    }    
    debugPrint("${jsonData}json data");
  }
  return jsonData;
}

void writeData(Map newData, {String path = 'output', bool append = true}) async {  
  final dir = await getApplicationDocumentsDirectory();
  if (append){
    Map data = await readData();
    newData.addAll(data);
  }

  if (path.split('/').length > 1){
    String directoryPath = '${dir.path}/${(path.split('/').sublist(0, path.split('/').length - 1)).join('/')}';
    // Create the directory if it doesn't exist
    Directory routineDir = Directory(directoryPath);
    if (!routineDir.existsSync()) {
      await routineDir.create(recursive: true);  // Create directory recursively
    }
  }

  String jsonString = jsonEncode(newData);
  // debugPrint(jsonString);
  String  filepath = '${dir.path}/$path.json';
  debugPrint(filepath);
  File file = File(filepath);

  await file.writeAsString(jsonString);
  readData(path: 'routines/test');
  debugPrint('JSON data has been written to the file.');
} 

Future<void> resetData(bool output, bool current) async {
  if (output){
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/output.json';
      final file = File(path);
      await file.writeAsString('');
      debugPrint('json reset at: $path');
    } catch (e) {
      debugPrint('Error saving json file: $e');
    }
  }
  if (current){
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/current.json';
      final file = File(path);
      await file.writeAsString('');
      debugPrint('json reset at: $path');
    } catch (e) {
      debugPrint('Error saving json file: $e');
    }
  }
}

void deleteFile(String fileName) async{
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$fileName.json';
  final file = File(path);
  if (await file.exists()) {
    await file.delete();   
  }
}