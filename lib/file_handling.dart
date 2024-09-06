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

void writeData(Map newData, {String path = 'output', bool append = true, String appendPos = ''}) async {
  if (append){
    if (appendPos != ''){
      Map data = await readData();
      newData.addAll(data);
    } else {
      debugPrint("Need a position to append data to");
    }
  }
  debugPrint('${newData}daaattaa ${path}' );
  String jsonString = jsonEncode(newData);
  debugPrint(jsonString);
  final dir = await getApplicationDocumentsDirectory();
  String  filepath = '${dir.path}/$path.json';
  debugPrint(filepath);
  File file = File(filepath);

  await file.writeAsString(jsonString);
  readData(path: 'current');
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