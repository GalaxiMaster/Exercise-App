import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedService {
  static const pageSize = 20;
  final _db = FirebaseFirestore.instance;

  final _profiles = <String, Future<Map<String, dynamic>?>>{};

  Future<Map<String, dynamic>?> profile(String uid) => _profiles.putIfAbsent(
    uid,
    () => _db.collection('profiles').doc(uid).get().then((s) => s.data()),
  );

  Future<QuerySnapshot<Map<String, dynamic>>> page(
      String me, {DocumentSnapshot? after}) {
    Query<Map<String, dynamic>> q = _db
      .collection('feeds').doc(me).collection('items')
      .orderBy('startTime', descending: true)
      .limit(pageSize);
    if (after != null) q = q.startAfterDocument(after);
    return q.get();
  }
}

class SocialService {
  final _db = FirebaseFirestore.instance;
  String? get me => FirebaseAuth.instance.currentUser?.uid;

  static String pairId(String a, String b) =>
    a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';


  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snap = await _db.collection('profiles').doc(uid).get();
    return snap.data();
  }

  /// Creates or updates your public profile and claims the username.
  Future<void> setUsernameAndProfile(
    String username, {
    String? displayName,
    String? photoUrl,
  }) async {
    final lower = username.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(lower)) {
      throw Exception('Use 3-20 letters, numbers or underscores');
    }

    final profileRef = _db.collection('profiles').doc(me);
    final nameRef = _db.collection('usernames').doc(lower);

    await _db.runTransaction((tx) async {
      final nameSnap = await tx.get(nameRef);
      final profileSnap = await tx.get(profileRef);

      if (nameSnap.exists && nameSnap.data()?['uid'] != me) {
        throw Exception('That username is taken');
      }

      // Release the old username if it changed
      final oldLower = profileSnap.data()?['usernameLower'] as String?;
      if (oldLower != null && oldLower != lower) {
        tx.delete(_db.collection('usernames').doc(oldLower));
      }
      if (!nameSnap.exists) tx.set(nameRef, {'uid': me});

      tx.set(
        profileRef,
        {
          'username': username.trim(),
          'usernameLower': lower,
          'displayName': displayName ?? username.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl,
        },
        SetOptions(merge: true),
      );
    });
  }


  Future<List<Map<String, dynamic>>> searchUsers(String term) async {
    final t = term.trim().toLowerCase();
    if (t.isEmpty) return [];
    final snap = await _db
      .collection('profiles')
      .where('usernameLower', isGreaterThanOrEqualTo: t)
      .where('usernameLower', isLessThan: '$t\uf8ff')
      .limit(10)
      .get();
    return snap.docs
      .where((d) => d.id != me)
      .map((d) => {...d.data(), 'uid': d.id})
      .toList();
  }

  // Requests and friendships
  Future<void> sendRequest(String toUid) =>
    _db.collection('friendRequests').doc('${me}_$toUid').set({
      'from': me,
      'to': toUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

  /// Also used to cancel an outgoing request.
  Future<void> cancelRequest(String toUid) =>
    _db.collection('friendRequests').doc('${me}_$toUid').delete();

  Future<void> declineRequest(String fromUid) =>
    _db.collection('friendRequests').doc('${fromUid}_$me').delete();

  Future<void> acceptRequest(String fromUid) async {
    final batch = _db.batch();
    batch.set(_db.collection('friendships').doc(pairId(me!, fromUid)), {
      'members': [me, fromUid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_db.collection('friendRequests').doc('${fromUid}_$me'));
    await batch.commit();
  }

  Future<void> removeFriend(String uid) =>
    _db.collection('friendships').doc(pairId(me!, uid)).delete();

  // Streams

  Stream<Set<String>> friendIds() => _db
    .collection('friendships')
    .where('members', arrayContains: me)
    .snapshots()
    .map((s) => s.docs
      .map((d) =>
          (d.data()['members'] as List).cast<String>().firstWhere((m) => m != me))
      .toSet());

  Stream<Set<String>> incomingRequestUids() => _db
    .collection('friendRequests')
    .where('to', isEqualTo: me)
    .snapshots()
    .map((s) => s.docs.map((d) => d.data()['from'] as String).toSet());

  Stream<Set<String>> outgoingRequestUids() => _db
    .collection('friendRequests')
    .where('from', isEqualTo: me)
    .snapshots()
    .map((s) => s.docs.map((d) => d.data()['to'] as String).toSet());

  // Feed
  Future<QuerySnapshot<Map<String, dynamic>>> feedPage({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> q = _db
      .collection('feeds')
      .doc(me)
      .collection('items')
      .orderBy('createdAt', descending: true)
      .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.get();
  }

  /// A friend's full workouts
  Query<Map<String, dynamic>> friendWorkouts(String friendUid) => _db
    .collection('User Data')
    .doc(friendUid)
    .collection('workouts')
    .orderBy('startTime', descending: true);

  Future<Map<String, dynamic>?> friendRoutines(String friendUid) => _db
    .collection('User Data')
    .doc(friendUid)
    .get().then((data)=>data['routines']);
}