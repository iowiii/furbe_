class AppUser {
  final String name;
  final String phone;
  final String? password;

  AppUser({
    required this.name,
    required this.phone,
    this.password,
  });

  factory AppUser.fromMap(Map data) {
    return AppUser(
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
    };
  }
}
