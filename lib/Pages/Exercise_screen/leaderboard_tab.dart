import 'package:exercise_app/Pages/Exercise_screen/exercise_screen_providers.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/models/exercise_screen_models.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Leaderboard for friends on this exercise
/// todo need to expand to more than one exercise
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
            leading: Container(
              height: 20, 
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: switch (index) {
                  0 => Color(0xFFFFD700),
                  1 => Color(0xFFC0C0C0),
                  2 => Color(0xFFCD7F32),
                  _ => Color(0xFF121212)
                }
              ),
              child: Center(child: Text((index + 1).toString())),
            ),
            title: Row(
              spacing: 12,
              children: [
                friend.maybeWhen(
                  data: (profile) => CircleAvatar(backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,), 
                  orElse: ()=> CircleAvatar(backgroundColor: Colors.grey,)
                ),
                friend.maybeWhen(
                  data: (profile) => Text(profile.displayName), 
                  orElse: ()=> bar(100, 10)
                ),
              ],
            ),
            trailing: Text(
              '${item.value.bestWeight}kg',
              style: TextStyle(fontSize: 14),
            ),
          );
        }
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
