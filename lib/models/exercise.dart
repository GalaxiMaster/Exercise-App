class Exercise {
  final String id;
  final String name;
  final String type;
  final Map<String, int> primary;
  final Map<String, int> secondary;
  final String group;

  const Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.primary,
    required this.secondary, 
    required this.group,
  });

  factory Exercise.fromJson(String id, Map<String, dynamic> json) {
    return Exercise(
      id: id,
      name: json['name'] as String,
      type: json['type'] as String,
      primary: Map<String, int>.from(json['Primary'] as Map),
      secondary: Map<String, int>.from(json['Secondary'] as Map),
      group: json['Group'] as String? ?? '',
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? type,
    Map<String, int>? primary,
    Map<String, int>? secondary,
    String? group,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      group: group ?? this.group,
    );
  }
}