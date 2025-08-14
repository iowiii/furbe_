import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        ListTile(title: const Text('Registered Dogs'), onTap: () {}),
        ListTile(title: const Text('Data Privacy'), onTap: () {}),
        ListTile(title: const Text('Delete Account'), onTap: () {}),
        ListTile(title: const Text('Logout'), onTap: () => auth.logout()),
      ]),
    );
  }
}
