import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/file_handling.dart';
import 'package:exercise_app/Providers/exercise_information_provider.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final StorageService _storage;
  SyncService(this._storage);

  static const _boxFields = ['output', 'settings', 'routines', 'customExercises'];

  final _subs = <String, StreamSubscription>{};
  final _timers = <String, Timer>{};

  // workout ids waiting to be pushed / deleted
  final _dirty = <String>{};
  final _deleted = <String>{};
  bool _restoring = false;

  CollectionReference<Map<String, dynamic>> _workoutsCol(String uid) =>
      FirebaseFirestore.instance.collection('User Data').doc(uid).collection('workouts');

  Future<void> startAutoSync() async {
    for (final path in _boxFields) {
      if (_subs.containsKey(path)) continue;
      final box = await _storage.getBox(path);
      _subs[path] = box.watch().listen((event) {
        if (_restoring) return; // ignore writes caused by restore
        if (path == 'output') {
          final id = event.key.toString();
          if (event.deleted) {
            _dirty.remove(id);
            _deleted.add(id);
          } else {
            _deleted.remove(id);
            _dirty.add(id);
          }
        }
        _schedule(path);
      });
    }
  }

  void _schedule(String path) {
    _timers[path]?.cancel();
    _timers[path] = Timer(const Duration(seconds: 1), () => syncBox(path));
  }

  Future<void> syncBox(String path, {String? user}) async {
    user ??= FirebaseAuth.instance.currentUser?.uid;
    if (user == null) return;
    if (path == 'output') return _syncWorkouts(user);
    try {
      final data = await _storage.readData(path: path);
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user)
          .set({path: data}, SetOptions(mergeFields: [path]));
    } catch (e) {
      debugPrint('Failed to sync $path: $e');
    }
  }

  /// Pushes only changed workouts, deletes removed ones.
  Future<void> _syncWorkouts(String user) async {
    final toPush = {..._dirty};
    final toDelete = {..._deleted};
    _dirty.clear();
    _deleted.clear();
    if (toPush.isEmpty && toDelete.isEmpty) return;

    try {
      final box = await _storage.getBox('output');
      final col = _workoutsCol(user);
      final ops = <void Function(WriteBatch)>[];

      for (final id in toPush) {
        final value = box.get(id);
        if (value == null) continue;
        ops.add((b) => b.set(col.doc(id), Map<String, dynamic>.from(value as Map)));
      }
      for (final id in toDelete) {
        ops.add((b) => b.delete(col.doc(id)));
      }
      await _commitInChunks(ops);
    } catch (e) {
      debugPrint('Failed to sync workouts: $e');
      // put them back so the next change retries them
      _dirty.addAll(toPush);
      _deleted.addAll(toDelete);
    }
  }

  Future<void> _commitInChunks(List<void Function(WriteBatch)> ops) async {
    final db = FirebaseFirestore.instance;
    for (var i = 0; i < ops.length; i += 450) {
      final batch = db.batch();
      for (final op in ops.skip(i).take(450)) {
        op(batch);
      }
      await batch.commit();
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

  Future<void> syncAllData({String? user, bool merge = true}) async {
    user ??= FirebaseAuth.instance.currentUser?.uid;
    if (user == null) return;

    for (final entry in _boxFields) {
      try {
        if (entry == 'output') {
          final box = await _storage.getBox('output');
          final col = _workoutsCol(user);
          final ops = <void Function(WriteBatch)>[
            for (final key in box.keys)
              (b) => b.set(col.doc(key.toString()),
                  Map<String, dynamic>.from(box.get(key) as Map)),
          ];
          await _commitInChunks(ops);
        } else {
          final dataMap = await _storage.readData(path: entry.toLowerCase());
          await FirebaseFirestore.instance
              .collection('User Data')
              .doc(user)
              .set({entry: dataMap}, SetOptions(merge: merge));
        }
        debugPrint('Successfully synced $entry for user $user');
      } catch (e) {
        debugPrint('Failed to sync $entry: $e');
      }
    }
  }

  Future<bool> restoreDataFromCloud(WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final userDoc = FirebaseFirestore.instance.collection('User Data').doc(user.uid);
      final results = await Future.wait([userDoc.get(), _workoutsCol(user.uid).get()]);
      final data = (results[0] as DocumentSnapshot<Map<String, dynamic>>).data();
      final workoutSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

      Map<String, dynamic>? workouts;
      if (workoutSnap.docs.isNotEmpty) {
        workouts = {for (final d in workoutSnap.docs) d.id: d.data()};
      }

      _restoring = true;
      try {
        await Future.wait([
          if (workouts != null) ref.read(workoutDataProvider.notifier).writeState(workouts),
          if (data?['settings'] != null) ref.read(settingsProvider.notifier).writeState(data!['settings']),
          if (data?['routines'] != null) ref.read(routineDataProvider.notifier).writeState(data!['routines']),
          if (data?['customExercises'] != null) ref.read(customExercisesAsyncProvider.notifier).writeState(data!['customExercises']),
        ]);
        // watch events arrive asynchronously, so keep suppressing briefly
        await Future.delayed(const Duration(milliseconds: 300));
      } finally {
        _restoring = false;
      }
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }
}

final syncServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SyncService(storage);
});
