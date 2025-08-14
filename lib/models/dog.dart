class Dog {
  String id;
  String name;
  String gender;
  String? picturePath;

  Dog({required this.id, required this.name, required this.gender, this.picturePath});

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'gender': gender, 'picturePath': picturePath};

  static Dog fromJson(Map<String, dynamic> j) => Dog(
      id: j['id'], name: j['name'], gender: j['gender'], picturePath: j['picturePath']);
}
