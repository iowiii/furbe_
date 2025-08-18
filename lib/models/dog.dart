class Dog {
  final String id;
  final String name;
  final String gender;
  final String type;
  final String info;
  final String photo;

  Dog({
    required this.id,
    required this.name,
    required this.gender,
    required this.type,
    required this.info,
    required this.photo,
  });

  factory Dog.fromMap(String id, Map<String, dynamic> map) {
    return Dog(
      id: id,
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      type: map['type'] ?? '',
      info: map['info'] ?? '',
      photo: map['photo'] ?? '',
    );
  }


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
