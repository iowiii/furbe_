import 'dog.dart' as dog_model;

class AppUser {
  final String name;
  final String phone;
  final String password;
  final Map<String, dog_model.Dog> dogs;


  AppUser({
    required this.name,
    required this.phone,
    required this.password,
    required this.dogs,
  });

  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    final dogsMap = <String, dog_model.Dog>{};
    if (map['dogs'] != null) {
      final dogsDynamic = map['dogs'] as Map<dynamic, dynamic>;
      dogsDynamic.forEach((key, value) {
        if (value != null) {
          final dogMap = Map<String, dynamic>.from(value as Map);
          dogsMap[key.toString()] = dog_model.Dog.fromMap(key.toString(), dogMap);
        }
      });
    }

    return AppUser(
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      dogs: dogsMap,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'dogs': dogs.map((key, dog) => MapEntry(key, dog.toMap())),
    };
  }
}
