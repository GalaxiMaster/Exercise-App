import 'package:exercise_app/Pages/Day_Screen_Individual/friend_workout_screen.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutCard extends ConsumerWidget { // todo disable click from friend profile
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mins = post.duration?.inMinutes;
    final stats = [
      if (mins != null) '$mins min',
      if (post.volume > 0) '${post.volume.round()} kg',
      '${post.setCount} sets',
      if (post.prCount > 0) '${post.prCount} PRs',
    ].join('  ·  ');

    final friendProfileAsync = ref.watch(friendProfileProvider(post.authorId));
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
              friendProfileAsync.when(
                data: (profile) => _authorHeader(theme, profile: profile),
                loading: () => _authorHeader(theme, loading: true),
                error: (_, __) => _authorHeader(theme), // shows '?' avatar and the time, same height
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
  Widget _authorHeader(ThemeData theme, {Map<String, dynamic>? profile, bool loading = false}) {
    final placeholder = ThemeColors.text.withAlpha(50);
    final name = (profile?['displayName'] ?? profile?['username'] ?? '') as String;
    final photo = profile?['photoUrl'] as String?;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholder,
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: loading ? placeholder : null,
            backgroundImage: (!loading && photo != null) ? NetworkImage(photo) : null,
            child: (!loading && photo == null)
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: loading
                ? [
                    bar(110, 14),
                    const SizedBox(height: 6),
                    bar(60, 10),
                  ]
                : [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(_ago(post.start), style: theme.textTheme.bodySmall),
                  ],
            ),
          ),
        ],
      ),
    );
  }
}