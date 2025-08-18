import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dog_setup_gender_view.dart';

class DogSetupNameView extends StatefulWidget {
  const DogSetupNameView({super.key});

  @override
  State<DogSetupNameView> createState() => _DogSetupNameViewState();
}

class _DogSetupNameViewState extends State<DogSetupNameView> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Name')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('What is your dog\'s name?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Dog Name')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Get.to(() => DogSetupGenderView(dogName: nameController.text.trim()));
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
