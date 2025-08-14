class UserModel {
  String id;
  String name;
  String email;
  List<Map<String, dynamic>> dogs;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.dogs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dogs': dogs,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    dogs: List<Map<String, dynamic>>.from(json['dogs']),
  );
}
