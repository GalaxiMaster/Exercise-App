import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_providers.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/models/exercise_screen_models.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every past workout that included these exercises, newest first.
class ExerciseLeaderboardTab extends ConsumerWidget {
  const ExerciseLeaderboardTab({super.key, required this.exercises});

  final List<String> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(exerciseLeaderboardProvider(ExerciseKey(exercises)));
    return leaderboard.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data.entries.elementAt(index);
          final friend = ref.watch(userProfileProvider(item.key));
          return ListTile(
           leading: friend.maybeWhen(
              data: (profile) => CircleAvatar(backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,), 
              orElse: ()=> CircleAvatar(backgroundColor: Colors.grey,)
            ),
            title: friend.maybeWhen(
              data: (profile) => Text(profile.displayName), 
              orElse: ()=> bar(100, 10)
            ),
          );
        }
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}