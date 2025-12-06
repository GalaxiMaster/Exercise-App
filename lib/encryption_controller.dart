import 'package:encrypt/encrypt.dart' as encrypts;
import 'package:exercise_app/file_handling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionService {
  // Private constructor for the singleton pattern
  EncryptionService._internal();

  // The single, static instance of the class
  static final EncryptionService _instance = EncryptionService._internal();

  // Getter to access the single instance
  static EncryptionService get instance => _instance;

  // Class properties
  late final encrypts.Encrypter _encrypter;
  final _iv = encrypts.IV.allZerosOfLength(16);
  final _storage = const FlutterSecureStorage();

  /// Initializes the encryption service by loading the key from environment variables.
  Future<void> initialize() async {
    final keyString = dotenv.env['ENCRYPTION_KEY'];
    if (keyString == null) {
      throw Exception('ENCRYPTION_KEY not found in .env file');
    }
    final key = encrypts.Key.fromUtf8(keyString);
    _encrypter = encrypts.Encrypter(encrypts.AES(key));
  }

  /// Encrypts a given plaintext string.
  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a given Base64 encrypted string.
  String decrypt(String encryptedText) {
    final encrypted = encrypts.Encrypted.fromBase64(encryptedText);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return decrypted;
  }

  /// Writes a key-value pair to secure storage.
  Future<void> writeToSecureStorage({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a value from secure storage for a given key.
  /// Returns null if the key is not found.
  Future<String?> readFromSecureStorage({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Deletes a specific key-value pair from secure storage.
  Future<void> deleteFromSecureStorage({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Deletes all data from secure storage.
  Future<void> clearAllSecureStorage() async {
    await _storage.deleteAll();
  }
}

Future<void> syncData({String? user, data = false, records = false, settings = false}) async {
  user ??= FirebaseAuth.instance.currentUser?.uid;
  if (user == null) return;
  if (!data && !records && !settings) {
    data = true;
    records = true;
    settings = true;
  }
  Map respectiveData = {
    'Output': data,
    'Records': records,
    'Settings': settings,
  };
  for (var entry in respectiveData.entries) {
    if (entry.value) {
      try {
        Map<String, dynamic> dataMap = (await readData(path: entry.key.toLowerCase())).cast<String, dynamic>();
        await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user)
          .set({entry.key: dataMap}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to sync ${entry.key}: $e');
      }
    }
  }
}

void restoreDataFromCloud() async{
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null){
    String uuid = user.uid;
    Map? data = (await FirebaseFirestore.instance
        .collection('User Data')
        .doc(uuid).get()).data();
    if (data != null){
      writeData(data['Data']);
      writeData(data['Settings'], path: 'settings');
      writeData(data['Records'], path: 'records');
    }
  }
}