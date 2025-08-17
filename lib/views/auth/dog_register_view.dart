import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => DogRegisterViewState();
}

class DogRegisterViewState extends State<RegisterView> {
  final nameCtrl = TextEditingController();
  String gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Dog')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Dog Name')),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (v) => setState(() => gender = v ?? 'Male'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Get.offAllNamed(AppRoutes.home), child: const Text('Done')),
          ]),
        ),
      ),
    );
  }
}
