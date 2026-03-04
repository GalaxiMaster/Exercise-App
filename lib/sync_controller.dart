import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/file_handling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final StorageService _storage;
  
  SyncService(this._storage);

  Future<void> syncData({String? user, bool data = false, bool settings = false}) async {
    user ??= FirebaseAuth.instance.currentUser?.uid;
    if (user == null) return;

    if (!data && !settings) {
      data = true;
      settings = true;
    }

    final Map<String, bool> respectiveData = {
      'Output': data,
      'Settings': settings,
    };

    for (var entry in respectiveData.entries) {
      if (entry.value) {
        try {
          final dataMap = await _storage.readData(path: entry.key.toLowerCase());
          
          await FirebaseFirestore.instance
              .collection('User Data')
              .doc(user)
              .set({entry.key: dataMap}, SetOptions(merge: true));
              
          debugPrint('Successfully synced ${entry.key} for user $user');
        } catch (e) {
          debugPrint('Failed to sync ${entry.key}: $e');
        }
      }
    }
  }
  Future<bool?> restoreDataFromCloud(WidgetRef ref) async{
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null){
      String uuid = user.uid;
      Map? data = (await FirebaseFirestore.instance
          .collection('User Data')
          .doc(uuid).get()).data();
      if (data != null){
        await Future.wait([
          ref.read(workoutDataProvider.notifier).writeState(data['Output']),
          ref.read(settingsProvider.notifier).writeState(data['Settings'])
        ]);
      }
    }
    return true;
  }
}

final syncServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SyncService(storage);
});
