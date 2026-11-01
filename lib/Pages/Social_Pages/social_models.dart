import 'package:cloud_firestore/cloud_firestore.dart';

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