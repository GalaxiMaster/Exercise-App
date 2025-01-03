import 'package:encrypt/encrypt.dart' as encrypts;
import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String encrypt(plainText){
  final key = encrypts.Key.fromUtf8('7uIiZfQbCdjJnDIeTNXvwo7FJgTS/8g5'); // move key to secure location later
  final iv = encrypts.IV.fromLength(16);

  final encrypter = encrypts.Encrypter(encrypts.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  // final decrypted = encrypter.decrypt(encrypted, iv: iv);

  // debugPrint(decrypted); // decrypted text
  return encrypted.base64; // encrypted text
}

Future<void> syncData(user, {data = false, records = false, settings = false}) async {
  if (!data && !records && !settings) {
    data = true;
    records = true;
    settings = true;
  }
  if (data) {
    try {
      Map<String, dynamic> dataMap = (await readData()).cast<String, dynamic>();
      await FirebaseFirestore.instance
        .collection('User Data')
        .doc(user)
        .set({'Data': dataMap}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to sync data: $e');
    }
  }

  if (records) {
    try {
      Map<String, dynamic> recordsMap = (await readData(path: 'records')).cast<String, dynamic>();
      await FirebaseFirestore.instance
        .collection('User Data')
        .doc(user)
        .set({'Records': recordsMap}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to sync records: $e');
    }
  }

  if (settings) {
    try {
      Map<String, dynamic> settingsMap = (await readData(path: 'settings')).cast<String, dynamic>();
      await FirebaseFirestore.instance
        .collection('User Data')
        .doc(user)
        .set({'Settings': settingsMap}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to sync records: $e');
    }
  }
}