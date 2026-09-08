class WorkoutDetails {
  final String startTime;
  final String? endTime;
  final Map <String, List<Map<String, dynamic>>> sets;
  final Map<String, String>? notes;

  const WorkoutDetails({
    required this.startTime,
    this.endTime, 
    required this.sets,
    this.notes,
  });
  WorkoutDetails copyWith({
    String? startTime,
    String? endTime,
    Map<String, List<Map<String, dynamic>>>? sets,
    Map<String, String>? notes,
  }) {
    return WorkoutDetails(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }
  factory WorkoutDetails.fromJson(Map<String, dynamic> json) {
    return WorkoutDetails(
      startTime: json['stats']?['startTime'] as String,
      endTime: json['stats']?['endTime'] as String?,
      sets: (Map<String, dynamic>.from(json['sets'])).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item) )
              .toList(),
        ),
      ),
      notes: (json['stats']?['notes'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
    );
  }
}