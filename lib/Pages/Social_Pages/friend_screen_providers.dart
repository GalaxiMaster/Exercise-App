import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendWorkoutFeedProvider = FutureProvider.family<List<FeedWorkout>, String>((ref, uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('User Data')
      .doc(uid)
      .collection('workouts')
      .orderBy('stats.startTime', descending: true)
      .limit(50)
      .get();
  return snap.docs.map((d) => FeedWorkout.fromDoc(uid, d)).toList();
});

final friendWorkoutHistoryProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('User Data')
      .doc(uid)
      .collection('workouts')
      .orderBy('stats.startTime', descending: true)
      .limit(50)
      .get();

  return {
    for (final doc in snap.docs) doc.id: doc.data(),
  };
});

final userExerciseStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('User Data')
      .doc(uid)
      .collection('exerciseStats')
      .orderBy('lastPerformed', descending: true)
      .limit(50)
      .get();

  return {
    for (final doc in snap.docs) doc.id: ExerciseStats.fromMap(doc.data()),
  };
});

final friendRoutinesProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  return SocialService().friendRoutines(uid);
});

final userProfileProvider = FutureProvider.family<ExerciseUser, String>((ref, uid) async {
  final feed = ref.read(feedServiceProvider);
  final profile = await feed.profile(uid);
  return ExerciseUser.fromMap(profile ?? const <String, dynamic>{}, uid: uid);
});

final myProfileProvider = FutureProvider<ExerciseUser?>((ref) async { // move elsewhere perhaps
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  final profile = await ref.watch(feedServiceProvider).profile(uid);
  return ExerciseUser.fromMap(profile ?? const <String, dynamic>{}, uid: uid);
});

final comparisonProvider = Provider.family<Map<String, UserFriendVals<ExerciseStats>>, String>((ref, friendId) {
final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return {};

  final user = ref.watch(userExerciseStatsProvider(currentUser.uid)).value;
  final friend = ref.watch(userExerciseStatsProvider(friendId)).value;

  if (user == null || friend == null) return {};

  return {
    for (final exercise in user.keys.where(friend.containsKey))
      exercise: UserFriendVals(
        userVal: user[exercise]!,
        friendVal: friend[exercise]!,
      ),
  };
});