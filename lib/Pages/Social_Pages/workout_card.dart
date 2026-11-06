import 'package:exercise_app/Pages/Day_Screen_Individual/friend_workout_screen.dart';
import 'package:exercise_app/Functions/Cloud/socail_services.dart';
import 'package:exercise_app/Pages/Social_Pages/social_models.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget { // todo disable click from friend profile
  final FeedWorkout post;
  final FeedService feed;
  final bool showAuthor;

  const WorkoutCard({
    super.key,
    required this.post,
    required this.feed,
    this.showAuthor = true,
  });

  String _ago(DateTime? t) {
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mins = post.duration?.inMinutes;
    final stats = [
      if (mins != null) '$mins min',
      if (post.volume > 0) '${post.volume.round()} kg',
      '${post.setCount} sets',
      if (post.prCount > 0) '${post.prCount} PRs',
    ].join('  ·  ');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FriendWorkoutScreen(
            friendUid: post.authorId,
            friendName: post.authorId, // will be replaced with name in FriendWorkoutScreen?
            dayKey: post.id,
            preview: post,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showAuthor)
              FutureBuilder<Map<String, dynamic>?>(
                future: feed.profile(post.authorId),
                builder: (_, snap) {
                  final p = snap.data;
                  final name = (p?['displayName'] ?? p?['username'] ?? '') as String;
                  final photo = p?['photoUrl'] as String?;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundImage: photo != null ? NetworkImage(photo) : null,
                        child: photo == null
                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(_ago(post.start), style: theme.textTheme.bodySmall),
                            ]),
                      ),
                    ]),
                  );
                },
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(_ago(post.start), style: theme.textTheme.bodySmall),
              ),
            Text(stats, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(post.exercises.take(5).join('\n'), style: theme.textTheme.bodySmall),
            if (post.exercises.length > 5)
              Text('+ ${post.exercises.length - 5} more',
                  style: theme.textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}