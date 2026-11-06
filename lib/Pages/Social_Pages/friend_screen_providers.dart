import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/socail_services.dart';
import 'package:exercise_app/models/social_models.dart';
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