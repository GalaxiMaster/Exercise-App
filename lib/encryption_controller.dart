import 'package:encrypt/encrypt.dart' as encrypts;
import 'package:exercise_app/file_handling.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final key = encrypts.Key.fromUtf8('7uIiZfQbCdjJnDIeTNXvwo7FJgTS/8g5'); // move key to secure location later
final encrypter = encrypts.Encrypter(encrypts.AES(key));
final iv = encrypts.IV.allZerosOfLength(16);
const storage = FlutterSecureStorage();

String encrypt(plainText){
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64; // encrypted text
}

String decrypt(encrypted){
  final encryptedE = encrypts.Encrypted.fromBase64(encrypted);
  final decrypted = encrypter.decrypt(encryptedE, iv: iv);
  return decrypted; // decrypted
}

void writeToSecureStorage(key, value) async{
  await storage.write(key: key, value: value);
}
readFromSecureStorage(key) async{
  final value = await storage.read(key: key);
  return value;
}

void clearStorage() async{
  await storage.deleteAll();
}
void deleteSecureStorageKey(key) async{
  await storage.delete(key: key);
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