import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/Functions/file_handling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final StorageService _storage;
  SyncService(this._storage);

  static const _boxFields = ['output', 'settings', 'routines', 'customExercises'];

  final _subs = <String, StreamSubscription>{};
  final _timers = <String, Timer>{};

  Future<void> startAutoSync() async {
    for (final path in _boxFields) {
      if (_subs.containsKey(path)) continue;
      final box = await _storage.getBox(path);
      _subs[path] = box.watch().listen((_) => _schedule(path));
    }
  }

  void _schedule(String path) {
    _timers[path]?.cancel();
    _timers[path] = Timer(const Duration(seconds: 3), () => syncBox(path));
  }

  Future<void> syncBox(String path, {String? user}) async {
    user ??= FirebaseAuth.instance.currentUser?.uid;
    if (user == null) return;
    try {
      final data = await _storage.readData(path: path);
      await FirebaseFirestore.instance
        .collection('User Data')
        .doc(user)
        .set(
          {path: data},
          SetOptions(mergeFields: [path]),
        );
    } catch (e) {
      debugPrint('Failed to sync $path: $e');
    }
  }

  void stopAutoSync() {
    for (final t in _timers.values) {
      t.cancel();
    }
    for (final s in _subs.values) {
      s.cancel();
    }
    _timers.clear();
    _subs.clear();
  }

  Future<void> syncAllData({
    String? user,
    bool merge = true
  }) async { 
    user ??= FirebaseAuth.instance.currentUser?.uid;
    if (user == null) return;

    for (var entry in _boxFields) {
      try {
        final dataMap = await _storage.readData(path: entry.toLowerCase());
        
        await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user)
          .set({entry: dataMap}, SetOptions(merge: merge));
            
        debugPrint('Successfully synced $entry for user $user');
      } catch (e) {
        debugPrint('Failed to sync $entry: $e');
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
          ref.read(workoutDataProvider.notifier).writeState(data['output']),
          ref.read(settingsProvider.notifier).writeState(data['settings'])
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
