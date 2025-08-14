class MoodEntry {
  String id;
  String breed;
  String mood;
  double confidence;
  String imagePath;
  DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.breed,
    required this.mood,
    required this.confidence,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'breed': breed,
    'mood': mood,
    'confidence': confidence,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
  };

  static MoodEntry fromJson(Map<String, dynamic> j) => MoodEntry(
    id: j['id'],
    breed: j['breed'],
    mood: j['mood'],
    confidence: (j['confidence'] as num).toDouble(),
    imagePath: j['imagePath'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}
