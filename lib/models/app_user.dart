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
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
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
