import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dog_setup_photo_view.dart';

class DogSetupGenderView extends StatefulWidget {
  final String dogName;
  const DogSetupGenderView({super.key, required this.dogName});

  @override
  State<DogSetupGenderView> createState() => _DogSetupGenderViewState();
}

class _DogSetupGenderViewState extends State<DogSetupGenderView> {
  String? gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Gender'),
        leading: BackButton(onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('What is your dog\'s gender?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: gender == 'Male' ? Colors.orange : null),
                  onPressed: () => setState(() => gender = 'Male'),
                  child: const Text('Male'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: gender == 'Female' ? Colors.orange : null),
                  onPressed: () => setState(() => gender = 'Female'),
                  child: const Text('Female'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: gender == null ? null : () => Get.to(() => DogSetupPhotoView(dogName: widget.dogName, dogGender: gender!)),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
