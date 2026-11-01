import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/Pages/Social_Pages/friend_screen.dart';
import 'package:exercise_app/Pages/Social_Pages/socail_services.dart';
import 'package:exercise_app/Pages/Social_Pages/social_models.dart';
import 'package:flutter/material.dart';
import 'workout_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _social = SocialService();
  final _feed = FeedService();
  final _scroll = ScrollController();
  final _searchController = TextEditingController();

  // Feed state
  final _posts = <FeedWorkout>[];
  bool _loading = false, _done = false, _initialLoaded = false;
  int _gen = 0; // discards results from outdated loads

  // Relationship state
  Set<String> _friends = {}, _incoming = {}, _outgoing = {};
  bool _friendsLoaded = false;
  final _subs = <StreamSubscription>[];

  // Search state
  bool _searching = false;
  List<Map<String, dynamic>> _results = [];
  Timer? _debounce;

  DocumentSnapshot<Map<String, dynamic>>? _last;

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        _load();
      }
    });

    // Reload the feed whenever the friend list changes (including first load)
    _subs.add(_social.friendIds().listen((v) {
      final changed =
          !_friendsLoaded || v.length != _friends.length || !v.containsAll(_friends);
      setState(() {
        _friends = v;
        _friendsLoaded = true;
      });
      if (changed) _load(refresh: true);
    }));
    _subs.add(_social.incomingRequestUids().listen((v) => setState(() => _incoming = v)));
    _subs.add(_social.outgoingRequestUids().listen((v) => setState(() => _outgoing = v)));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }


Future<void> _load({bool refresh = false}) async {
  if (refresh) {
    _gen++;
    _loading = false;
    _done = false;
    _last = null;
  }
  if (_loading || _done) return;

  final gen = _gen;
  final first = _last == null;
  _loading = true;
  if (mounted) setState(() {});

  try {
    final snap = await _feed.page(_social.me, after: _last);
    if (!mounted || gen != _gen) return;
    setState(() {
      if (first) _posts.clear();
      _posts.addAll(snap.docs.map(FeedWorkout.fromFeedDoc));
      if (snap.docs.isNotEmpty) _last = snap.docs.last;
      if (snap.docs.length < FeedService.pageSize) _done = true;
      _initialLoaded = true;
    });
  } catch (e) {
    if (mounted && gen == _gen) {
      setState(() => _initialLoaded = true);
      _snack('Could not load feed: $e');
    }
  } finally {
    if (gen == _gen) {
      _loading = false;
      if (mounted) setState(() {});
    }
  }
}

  // ---------- Search ----------

  void _onSearchChanged(String term) {
    _debounce?.cancel();
    if (term.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final r = await _social.searchUsers(term);
      if (mounted) setState(() => _results = r);
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searching = false;
      _results = [];
    });
  }

  void _snack(Object e) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));

  void _openFriends() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const FriendsScreen()));

  Widget _actionFor(String uid) {
    if (_friends.contains(uid)) return const Text('Friends');
    if (_outgoing.contains(uid)) {
      return TextButton(
        onPressed: () => _social.cancelRequest(uid).catchError(_snack),
        child: const Text('Requested'),
      );
    }
    if (_incoming.contains(uid)) {
      return FilledButton(
        onPressed: () => _social.acceptRequest(uid).catchError(_snack),
        child: const Text('Accept'),
      );
    }
    return FilledButton(
      onPressed: () => _social.sendRequest(uid).catchError(_snack),
      child: const Text('Add'),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by username',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('Feed'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed:
                _searching ? _closeSearch : () => setState(() => _searching = true),
          ),
          if (!_searching)
            IconButton(
              tooltip: 'Friends',
              onPressed: _openFriends,
              icon: Badge(
                isLabelVisible: _incoming.isNotEmpty,
                label: Text('${_incoming.length}'),
                child: const Icon(Icons.people),
              ),
            ),
        ],
      ),
      body: _searching ? _buildSearchResults() : _buildFeed(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text('Type a username to find friends'));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final p = _results[i];
        final name = (p['displayName'] ?? p['username'] ?? '') as String;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: p['photoUrl'] != null ? NetworkImage(p['photoUrl']) : null,
            child: p['photoUrl'] == null
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(name),
          subtitle: Text('@${p['username'] ?? ''}'),
          trailing: _actionFor(p['uid']),
        );
      },
    );
  }

  Widget _buildFeed() {
    return Column(children: [
      if (_incoming.isNotEmpty)
        Card(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ListTile(
            leading: const Icon(Icons.person_add),
            title: Text(_incoming.length == 1
                ? '1 friend request'
                : '${_incoming.length} friend requests'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openFriends,
          ),
        ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => _load(refresh: true),
          child: _feedList(),
        ),
      ),
    ]);
  }

  Widget _feedList() {
    const physics = AlwaysScrollableScrollPhysics();

    if (!_initialLoaded) {
      return ListView(physics: physics, children: const [
        SizedBox(height: 160),
        Center(child: CircularProgressIndicator()),
      ]);
    }

    if (_posts.isEmpty) {
      return ListView(physics: physics, children: [
        const SizedBox(height: 120),
        Center(
          child: Text(
            _friends.isEmpty
                ? 'No friends yet.\nTap the search icon to find people.'
                : 'No workouts from your friends yet.',
            textAlign: TextAlign.center,
          ),
        ),
        if (_friends.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: () => setState(() => _searching = true),
                child: const Text('Find friends'),
              ),
            ),
          ),
      ]);
    }

    return ListView.builder(
      controller: _scroll,
      physics: physics,
      itemCount: _posts.length + 1,
      itemBuilder: (_, i) {
        if (i == _posts.length) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: _done
                  ? const Text('You\'re all caught up')
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        return WorkoutCard(post: _posts[i], feed: _feed);
      },
    );
  }
}