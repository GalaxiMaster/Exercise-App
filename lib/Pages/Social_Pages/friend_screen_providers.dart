import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/Pages/Add_Workout/add_workout_models.dart';
import 'package:exercise_app/Pages/StatScreens/radar_chart.dart';
import 'package:exercise_app/Providers/providers.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
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

final friendWorkoutHistoryProvider = FutureProvider.family<WorkoutHistory, String>((ref, uid) async {
  final snap = await FirebaseFirestore.instance
      .collection('User Data')
      .doc(uid)
      .collection('workouts')
      .orderBy('stats.startTime', descending: true)
      .limit(50)
      .get();

  return WorkoutHistory({
    for (final doc in snap.docs) doc.id: doc.data(),
  });
});

final friendRoutinesProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  return SocialService().friendRoutines(uid);
});

final userProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, uid) async {
  final feed = ref.read(feedServiceProvider);
  return feed.profile(uid);
});

final myProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async { // move elsewhere perhaps
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  return ref.watch(feedServiceProvider).profile(uid);
});

// Comparison notifier + provider
class UserFriendVals {
  final double userVal;
  final double friendVal;

  UserFriendVals({required this.userVal, required this.friendVal});
}

class ComparisonData {
  final Map<String, UserFriendVals> exerciseComparisons;
  final List<List<RadarEntry>> radarVals;
  const ComparisonData({required this.exerciseComparisons, required this.radarVals});

  factory ComparisonData.fromRaw(Map<String, dynamic> userData, Map<String, dynamic> friendData, Ref ref) { // todo remove widget ref pass in
    final comparisons = <String, UserFriendVals>{};
    // flattenMaps

    // getPercentageData(userData, '', range, ref)
    // getPercentageData(friendData, target, range, ref)

    final radar = <List<RadarEntry>>[];

    return ComparisonData(exerciseComparisons: comparisons, radarVals: radar);
  }
}

final comparisonProvider = Provider.family<ComparisonData, String>((ref, friendId) {
  final user = ref.watch(workoutDataProvider).value;
  final friend = ref.watch(friendWorkoutHistoryProvider(friendId)).value;

  final userData = user ?? const <String, dynamic>{};
  final friendData = (friend as Map<String, dynamic>?) ?? const <String, dynamic>{};

  return ComparisonData.fromRaw(userData, friendData, ref);
});