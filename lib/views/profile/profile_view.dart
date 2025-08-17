import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Obx(() {
          final user = auth.appUser.value;

          if (user == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.pets, size: 48),
                SizedBox(height: 8),
                Text('Not logged in'),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 48, child: Icon(Icons.pets, size: 48)),
              const SizedBox(height: 8),
              Text(user.name),
              Text(user.phone),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await auth.logout();
                  auth.appUser.value = null;
                  Get.snackbar('Logout', 'You have been logged out');
                },
                child: const Text('Logout'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
