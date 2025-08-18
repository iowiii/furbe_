class Dog {
  String? id;       // unique Firebase key for this dog
  String name;
  String gender;    // "male" or "female"
  String type;      // e.g., "pomeranian", "shih-tzu", etc.
  String info;      // description or notes
  String photo;     // URL or base64 string

  Dog({
    this.id,
    required this.name,
    required this.gender,
    required this.type,
    required this.info,
    required this.photo,
  });

  /// Convert Firebase snapshot map to Dog object
  factory Dog.fromMap(String id, Map<dynamic, dynamic> map) {
    return Dog(
      id: id,
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      type: map['type'] ?? '',
      info: map['info'] ?? '',
      photo: map['photo'] ?? '',
    );
  }

  /// Convert Dog object to map for saving to Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'type': type,
      'info': info,
      'photo': photo,
    };
  }
}
