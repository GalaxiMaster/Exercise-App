import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Pages/Account/username_popup.dart';
import 'package:exercise_app/Pages/Social_Pages/socail_services.dart';
import 'package:exercise_app/Pages/Social_Pages/social_models.dart';
import 'package:flutter/material.dart';
import 'workout_card.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _social = SocialService();
  final _feed = FeedService();

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
                feed: _feed,
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
                feed: _feed,
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
              feed: _feed,
              onTap: (name) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendWorkoutsScreen(uid: uid, name: name, feed: _feed),
                ),
              ),
              trailing: _RemoveMenu(onRemove: (name) => _confirmRemove(uid, name), feed: _feed, uid: uid),
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
class _PersonTile extends StatelessWidget {
  final String uid;
  final FeedService feed;
  final Widget? trailing;
  final void Function(String name)? onTap;
  const _PersonTile({required this.uid, required this.feed, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: feed.profile(uid),
      builder: (_, snap) {
        final p = snap.data;
        final name = (p?['displayName'] ?? p?['username'] ?? '...') as String;
        final photo = p?['photoUrl'] as String?;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: photo != null ? NetworkImage(photo) : null,
            child: photo == null
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
              : null,
          ),
          title: Text(name),
          subtitle: p?['username'] != null ? Text('@${p!['username']}') : null,
          trailing: trailing,
          onTap: onTap == null ? null : () => onTap!(name),
        );
      },
    );
  }
}

/// A single friend's recent workouts.
class FriendWorkoutsScreen extends StatelessWidget {
  final String uid, name;
  final FeedService feed;
  const FriendWorkoutsScreen(
      {super.key, required this.uid, required this.name, required this.feed});

  Future<List<FeedWorkout>> _load() async {
    final snap = await FirebaseFirestore.instance
        .collection('User Data')
        .doc(uid)
        .collection('workouts')
        .orderBy('stats.startTime', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => FeedWorkout.fromDoc(uid, d)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<FeedWorkout>>(
        future: _load(),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load workouts\n${snap.error}'));
          }
          final workouts = snap.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Text('No workouts yet'));
          }
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (_, i) =>
                WorkoutCard(post: workouts[i], feed: feed, showAuthor: false),
          );
        },
      ),
    );
  }
}