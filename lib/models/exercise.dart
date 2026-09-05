class Exercise {
  final String id;
  final String name;
  final String type;
  final Map<String, int> primary;
  final Map<String, int> secondary;

  const Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.primary,
    required this.secondary,
  });

  factory Exercise.fromJson(String id, Map<String, dynamic> json) {
    return Exercise(
      id: id,
      name: json['name'] as String,
      type: json['type'] as String,
      primary: Map<String, int>.from(json['Primary'] as Map),
      secondary: Map<String, int>.from(json['Secondary'] as Map),
    );
  }
}