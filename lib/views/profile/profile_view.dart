import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 48, child: Icon(Icons.pets, size: 48)),
          const SizedBox(height: 8),
          Text(user?.phoneNumber ?? 'Guest'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => auth.logout(), child: const Text('Logout')),
        ]),
      ),
    );
  }
}
