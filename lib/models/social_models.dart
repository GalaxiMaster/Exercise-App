import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseUser {
  final String uid;
  final String? photoUrl;
  final String username;
  final String? _displayName;

  ExerciseUser({
    required this.uid,
    required this.photoUrl,
    required this.username,
    required String? displayName,
  }) : _displayName = displayName;

  String get displayName => _displayName ?? username;

  /// [uid] field required to be passed in if not in the json
  factory ExerciseUser.fromMap(Map<String, dynamic> json, {String? uid}) {
    if (json['uid'] == null && uid == null) {
      throw Exception('uid not found in user');
    }
    
    return ExerciseUser(
      uid: uid ?? json['uid'],
      photoUrl: json['photoUrl'] as String?,
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
    );
  }
}

class FeedWorkout {
  final String id, authorId, startKey;
  final DateTime? start, end;
  final List<String> exercises;
  final double volume;
  final int setCount, prCount;

  FeedWorkout({
    required this.id,
    required this.authorId,
    required this.startKey,
    required this.exercises,
    required this.volume,
    required this.setCount,
    required this.prCount,
    this.start,
    this.end,
  });

  Duration? get duration => (start != null && end != null) ? end!.difference(start!) : null;

  static String _pretty(String key) => key
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

  factory FeedWorkout.fromFeedDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final ts = (m['startTime'] as Timestamp?)?.toDate().toUtc();
    // Stored as UTC for ordering; rebuild as local so it matches what the user logged
    final start = ts == null ? null : DateTime(ts.year, ts.month, ts.day, ts.hour, ts.minute);
    final mins = m['durationMin'] as num?;
    return FeedWorkout(
      id: (m['workoutId'] ?? d.id) as String,
      authorId: (m['authorId'] ?? '') as String,
      startKey: '',
      start: start,
      end: (start != null && mins != null) ? start.add(Duration(minutes: mins.round())) : null,
      exercises: List<String>.from(m['exercises'] ?? const []),
      volume: ((m['volume'] ?? 0) as num).toDouble(),
      setCount: ((m['setCount'] ?? 0) as num).toInt(),
      prCount: ((m['prCount'] ?? 0) as num).toInt(),
    );
  }

  factory FeedWorkout.fromDoc(
    String authorId, DocumentSnapshot<Map<String, dynamic>> d
  ) {
    final data = d.data() ?? {};
    final stats = (data['stats'] as Map?) ?? {};
    final sets = (data['sets'] as Map?) ?? {};

    double volume = 0;
    int setCount = 0, prs = 0;
    sets.forEach((_, list) {
      for (final s in (list as List)) {
        final m = s as Map;
        setCount++;
        if (m['PR'] == 'yes') prs++;
        if (m['type'] == 'Warmup') continue;
        volume += ((double.tryParse(m['weight']) ?? 0) as num) * ((double.tryParse(m['reps']) ?? 0) as num);
      }
    });

    final startStr = stats['startTime'] as String? ?? '';
    final endStr = stats['endTime'] as String?;

    return FeedWorkout(
      id: d.id,
      authorId: authorId,
      startKey: startStr,
      start: DateTime.tryParse(startStr),
      end: endStr != null ? DateTime.tryParse(endStr) : null,
      exercises: sets.keys.map((k) => _pretty(k as String)).toList(),
      volume: volume,
      setCount: setCount,
      prCount: prs,
    );
  }
}

class UserFriendVals<T> {
  final T userVal;
  final T friendVal;

  const UserFriendVals({
    required this.userVal,
    required this.friendVal,
  });
}

class UserExerciseStats {
  final double? best1RM;
  final DateTime best1RMDate;
  final int? best1RMReps;
  final double? best1RMWeight;
  final String? best1RMWorkoutId;
  final int bestReps;
  final DateTime bestRepsDate;
  final String bestRepsWorkoutId;
  final double bestSessionVolume;
  final DateTime bestSessionVolumeDate;
  final String? bestSessionVolumeWorkoutId;
  final double bestSetVolume;
  final DateTime bestSetVolumeDate;
  final int bestSetVolumeReps;
  final double bestSetVolumeWeight;
  final String? bestSetVolumeWorkoutId;
  final double bestWeight;
  final DateTime bestWeightDate;
  final int bestWeightReps;
  final String bestWeightWorkoutId;
  final String exerciseKey;
  final DateTime firstPerformed;
  final DateTime lastPerformed;
  final String lastWorkoutId;
  final int totalSessions;
  final int totalSets;
  final double totalVolume;
  final DateTime updatedAt;

  const UserExerciseStats({
    required this.best1RM,
    required this.best1RMDate,
    required this.best1RMReps,
    required this.best1RMWeight,
    required this.best1RMWorkoutId,
    required this.bestReps,
    required this.bestRepsDate,
    required this.bestRepsWorkoutId,
    required this.bestSessionVolume,
    required this.bestSessionVolumeDate,
    required this.bestSessionVolumeWorkoutId,
    required this.bestSetVolume,
    required this.bestSetVolumeDate,
    required this.bestSetVolumeReps,
    required this.bestSetVolumeWeight,
    required this.bestSetVolumeWorkoutId,
    required this.bestWeight,
    required this.bestWeightDate,
    required this.bestWeightReps,
    required this.bestWeightWorkoutId,
    required this.exerciseKey,
    required this.firstPerformed,
    required this.lastPerformed,
    required this.lastWorkoutId,
    required this.totalSessions,
    required this.totalSets,
    required this.totalVolume,
    required this.updatedAt,
  });

  factory UserExerciseStats.fromMap(Map<String, dynamic> map) {
    return UserExerciseStats(
      best1RM: (map['best1RM'] as num).toDouble(),
      best1RMDate: _parseTimestamp(map['best1RMDate']),
      best1RMReps: (map['best1RMReps'] as num).toInt(),
      best1RMWeight: (map['best1RMWeight'] as num).toDouble(),
      best1RMWorkoutId: map['best1RMWorkoutId'] as String?,
      bestReps: (map['bestReps'] as num).toInt(),
      bestRepsDate: _parseTimestamp(map['bestRepsDate']),
      bestRepsWorkoutId: map['bestRepsWorkoutId'] as String,
      bestSessionVolume: (map['bestSessionVolume'] as num).toDouble(),
      bestSessionVolumeDate: _parseTimestamp(map['bestSessionVolumeDate']),
      bestSessionVolumeWorkoutId: map['bestSessionVolumeWorkoutId'] as String?,
      bestSetVolume: (map['bestSetVolume'] as num).toDouble(),
      bestSetVolumeDate: _parseTimestamp(map['bestSetVolumeDate']),
      bestSetVolumeReps: (map['bestSetVolumeReps'] as num).toInt(),
      bestSetVolumeWeight: (map['bestSetVolumeWeight'] as num).toDouble(),
      bestSetVolumeWorkoutId: map['bestSetVolumeWorkoutId'] as String?,
      bestWeight: (map['bestWeight'] as num).toDouble(),
      bestWeightDate: _parseTimestamp(map['bestWeightDate']),
      bestWeightReps: (map['bestWeightReps'] as num).toInt(),
      bestWeightWorkoutId: map['bestWeightWorkoutId'] as String,
      exerciseKey: map['exerciseKey'] as String,
      firstPerformed: _parseTimestamp(map['firstPerformed']),
      lastPerformed: _parseTimestamp(map['lastPerformed']),
      lastWorkoutId: map['lastWorkoutId'] as String,
      totalSessions: (map['totalSessions'] as num).toInt(),
      totalSets: (map['totalSets'] as num).toInt(),
      totalVolume: (map['totalVolume'] as num).toDouble(),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'best1RM': best1RM,
      'best1RMDate': Timestamp.fromDate(best1RMDate),
      'best1RMReps': best1RMReps,
      'best1RMWeight': best1RMWeight,
      'best1RMWorkoutId': best1RMWorkoutId,
      'bestReps': bestReps,
      'bestRepsDate': Timestamp.fromDate(bestRepsDate),
      'bestRepsWorkoutId': bestRepsWorkoutId,
      'bestSessionVolume': bestSessionVolume,
      'bestSessionVolumeDate': Timestamp.fromDate(bestSessionVolumeDate),
      'bestSessionVolumeWorkoutId': bestSessionVolumeWorkoutId,
      'bestSetVolume': bestSetVolume,
      'bestSetVolumeDate': Timestamp.fromDate(bestSetVolumeDate),
      'bestSetVolumeReps': bestSetVolumeReps,
      'bestSetVolumeWeight': bestSetVolumeWeight,
      'bestSetVolumeWorkoutId': bestSetVolumeWorkoutId,
      'bestWeight': bestWeight,
      'bestWeightDate': Timestamp.fromDate(bestWeightDate),
      'bestWeightReps': bestWeightReps,
      'bestWeightWorkoutId': bestWeightWorkoutId,
      'exerciseKey': exerciseKey,
      'firstPerformed': Timestamp.fromDate(firstPerformed),
      'lastPerformed': Timestamp.fromDate(lastPerformed),
      'lastWorkoutId': lastWorkoutId,
      'totalSessions': totalSessions,
      'totalSets': totalSets,
      'totalVolume': totalVolume,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    throw ArgumentError('Unsupported timestamp format: $value');
  }
}