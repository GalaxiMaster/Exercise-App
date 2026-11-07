import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendWorkoutsProvider = FutureProvider.family<List<FeedWorkout>, String>((ref, uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('User Data')
      .doc(uid)
      .collection('workouts')
      .orderBy('stats.startTime', descending: true)
      .limit(50)
      .get();
  return snap.docs.map((d) => FeedWorkout.fromDoc(uid, d)).toList();
});

final friendRoutinesProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  return SocialService().friendRoutines(uid);
});

final friendProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  final feed = ref.read(feedServiceProvider);
  return feed.profile(uid);
});

final myProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async { // move elsewhere perhaps
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  return ref.watch(feedServiceProvider).profile(uid);
});