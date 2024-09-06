import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<Map<dynamic, dynamic>> readData({String path = 'output'}) async{
  Map<dynamic, dynamic> jsonData= {};
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

void writeData(Map data, {String path = 'output', bool append = true}) async {
  debugPrint('${data}daaattaa ${path}' );
  String jsonString = jsonEncode(data);
  debugPrint(jsonString);
  final dir = await getApplicationDocumentsDirectory();
  String  filepath = '${dir.path}/$path.json';
  debugPrint(filepath);
  File file = File(filepath);

  await file.writeAsString(jsonString, mode: append ? FileMode.append : FileMode.write);
  readData(path: 'current');
  debugPrint('JSON data has been written to the file.');
} 