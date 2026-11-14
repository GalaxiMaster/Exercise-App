import 'dart:async';
import 'package:exercise_app/Pages/Account/username_popup.dart';
import 'package:exercise_app/Functions/Cloud/social_services.dart';
import 'package:exercise_app/Pages/Social_Pages/compare_page.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen_providers.dart';
import 'package:exercise_app/models/social_models.dart';
import 'package:exercise_app/theme_colors.dart';
import 'package:exercise_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'workout_card.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});
  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _social = SocialService();

  Set<String> _friends = {}, _incoming = {}, _outgoing = {};
  Map<String, dynamic>? _myProfile;
  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
    _subs.add(_social.friendIds().listen((v) => setState(() => _friends = v)));
    _subs.add(_social.incomingRequestUids().listen((v) => setState(() => _incoming = v)));
    _subs.add(_social.outgoingRequestUids().listen((v) => setState(() => _outgoing = v)));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> _loadMyProfile() async {
    if (_social.me == null) return;
    final p = await _social.getProfile(_social.me!);
    if (mounted) setState(() => _myProfile = p);
  }

  void _snack(Object e) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));

  Future<void> _confirmRemove(String uid, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove $name?'),
        content: const Text('You will no longer see each other\'s workouts.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) _social.removeFriend(uid).catchError(_snack);
  }

  Future<void> _editUsername() async {
    final changed = await showUsernameDialog(
      context,
      currentUsername: _myProfile?['username'] as String?,
    );
    if (changed != null) _loadMyProfile();
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 4, left: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    final username = _myProfile?['username'] as String?;
    final feed = ref.read(feedServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Your username
          Card(
            child: ListTile(
              leading: const Icon(Icons.alternate_email),
              title: Text(username != null ? '@$username' : 'Set a username'),
              subtitle: const Text('Friends find you by this name'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editUsername,
              ),
            ),
          ),

          if (_incoming.isNotEmpty) ...[
            _header('Requests (${_incoming.length})'),
            for (final uid in _incoming)
              _PersonTile(
                uid: uid,
                feed: feed,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Accept',
                    icon: const Icon(Icons.check_circle),
                    onPressed: () => _social.acceptRequest(uid).catchError(_snack),
                  ),
                  IconButton(
                    tooltip: 'Decline',
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () => _social.declineRequest(uid).catchError(_snack),
                  ),
                ]),
              ),
          ],

          if (_outgoing.isNotEmpty) ...[
            _header('Sent requests'),
            for (final uid in _outgoing)
              _PersonTile(
                uid: uid,
                feed: feed,
                trailing: TextButton(
                  onPressed: () => _social.cancelRequest(uid).catchError(_snack),
                  child: const Text('Cancel'),
                ),
              ),
          ],

          _header('Your friends (${_friends.length})'),
          if (_friends.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No friends yet. Use the search icon on the feed to find people.'),
            ),
          for (final uid in _friends)
            _PersonTile(
              uid: uid,
              feed: feed,
              onTap: (name) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendWorkoutsScreen(uid: uid, name: name),
                ),
              ),
              trailing: _RemoveMenu(onRemove: (name) => _confirmRemove(uid, name), feed: feed, uid: uid),
            ),
        ],
      ),
    );
  }
}

class _RemoveMenu extends StatelessWidget {
  final String uid;
  final FeedService feed;
  final void Function(String name) onRemove;
  const _RemoveMenu({required this.uid, required this.feed, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (_) async {
        final p = await feed.profile(uid);
        onRemove((p?['displayName'] ?? p?['username'] ?? 'this friend') as String);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'remove', child: Text('Remove friend')),
      ],
    );
  }
}

/// Loads a profile from a uid and shows it as a list tile.
class _PersonTile extends ConsumerWidget {
  final String uid;
  final FeedService feed;
  final Widget? trailing;
  final void Function(String name)? onTap;
  const _PersonTile({required this.uid, required this.feed, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendProfileAsync = ref.watch(userProfileProvider(uid));

    return friendProfileAsync.when(
      data: (profile) => _friendTile(profile: profile),
      loading: () => _friendTile(loading: true),
      error: (_, __) => _friendTile(), // shows '?' avatar and the time, same height
    );
  }
  Widget _friendTile({ExerciseUser? profile, bool loading = false}) {
    final name = profile?.displayName ?? '';
    final photo = profile?.photoUrl;
    final username = profile?.username;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photo != null ? NetworkImage(photo) : null,
        backgroundColor: loading ? ThemeColors.text.withAlpha(50) : null,
        child: photo == null
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
          : null,
      ),
      title: loading ? bar(50, 14) : Text(name),
      subtitle: username != null ? Text('@$username') : null,
      trailing: trailing,
      onTap: onTap == null ? null : () => onTap!(name),
    );
  }
}

/// A single friend's recent workouts.
class FriendWorkoutsScreen extends ConsumerWidget {
  final String uid, name;
  const FriendWorkoutsScreen(
      {super.key, required this.uid, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWorkouts = ref.watch(friendWorkoutFeedProvider(uid));
    final routines = ref.watch(friendRoutinesProvider(uid));
    final friendProfile = ref.watch(userProfileProvider(uid));
    final myProfile = ref.watch(myProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: userWorkouts.when(data: (workouts) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _buildPersonHeader(friendProfile.value, workouts),
                _buildComparisonSection(friendProfile.value, myProfile.value, context), // todo figure out the best way to not need to pass in context
                _buildRoutineList(routines),
                _buildWorkoutsList(workouts),
              ],
            ),
          ),
        );
      }, error: (error, stackTrace) {
        return Center(child: Text('Could not load workouts\n$error'));
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      })
    );
  }
  Widget _buildPersonHeader(ExerciseUser? p, List<FeedWorkout> workouts) {
    final name = p?.displayName ?? this.name;
    final photo = p?.photoUrl;
    return  Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: photo != null ? NetworkImage(photo) : null,
            child: photo == null
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
              : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                Row(
                  spacing: 20,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Workouts', style: TextStyle(color: ThemeColors.text.withAlpha(125), fontSize: 12)),
                        Text('${0}', style: const TextStyle(fontWeight: FontWeight.w600)), // todo add values in
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sets', style: TextStyle(color: ThemeColors.text.withAlpha(125), fontSize: 12)),
                        Text('${0}', style: const TextStyle(fontWeight: FontWeight.w600)), // todo add values in
                      ],
                    )
                  ]
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildComparisonSection(ExerciseUser? friendProfileData, ExerciseUser? myProfileData, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparison',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ThemeColors.text.withAlpha(150)
          )
        ),
        GestureDetector(
          onTap: ()=> Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComparePage(friendId: uid,))
          ),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ThemeColors.container,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OverlappingAvatars(
                    photo: friendProfileData?.photoUrl != null ? NetworkImage(friendProfileData!.photoUrl!) : null, 
                    secondaryPhoto: myProfileData?.photoUrl != null ? NetworkImage(myProfileData!.photoUrl!) : null, 
                    radius: 15,
                  ),
                  SizedBox(width: 5),
                  Text('Compare'),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            )
          ),
        )
      ]
    );
  }

  Widget _buildRoutineList(AsyncValue<Map<String, dynamic>?> routines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Text(
          'Routines',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ThemeColors.text.withAlpha(150)
          )
        ),
        routines.when(
          data: (data) {
            if (data == null || data.isEmpty) {
              return const Center(child: Text('No routines found'));
            }
            return SizedBox(
              height: 75,
              child: ListView.builder(
                itemCount: data.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final routine = data.values.toList()[index];
                  return Container(
                    width: 200,
                    height: 75,
                    decoration: BoxDecoration(
                      color: ThemeColors.container,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(routine['data']['name']),
                          Text(routine['slots'].map((slot) => slot['title']).join(', '), style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }
              ),
            );
          }, error: (error, stackTrace) {
            return Center(child: Text('Could not load routines\n$error'));
          }, loading: () {
            return const SizedBox.shrink();
          }
        ),
      ],
    );
  }

  Widget _buildWorkoutsList(List<FeedWorkout> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Workouts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ThemeColors.text.withAlpha(150)
          )
        ),
        ListView.builder(
          itemCount: workouts.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, i) =>
              WorkoutCard(post: workouts[i], showAuthor: false),
        ),
      ],
    );
  }
}