import 'package:intl/intl.dart';

class WorkoutDetails {
  final String startTime;
  final String? endTime;
  final Map <String, List<Map<String, dynamic>>> sets;
  final Map<String, String>? notes;
  final String? routineId;

  const WorkoutDetails({
    required this.startTime,
    this.endTime, 
    required this.sets,
    this.routineId,
    this.notes,
  });
  WorkoutDetails copyWith({
    String? startTime,
    String? endTime,
    Map<String, List<Map<String, dynamic>>>? sets,
    Map<String, String>? notes,
    String? routineId,
  }) {
    return WorkoutDetails(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      routineId: routineId ?? this.routineId,
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
      notes: (json['stats']?['notes'] as Map?)
    ?.map((key, value) => MapEntry(key as String, value as String)),
      routineId: json['stats']?['routineId'] as String?,
    );
  }

  Map <String, dynamic> toJson() {
    return {
      'stats': {
        'startTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(startTime)),
        'endTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(endTime!)),
        if (notes != null) 'notes': notes,
        if (routineId != null) 'routineId': routineId,
      },
      'sets': sets.map((key, value) => MapEntry(
        key,
        value.map((item) => Map<String, dynamic>.from(item)).toList(),
      )),
    };
  }
}