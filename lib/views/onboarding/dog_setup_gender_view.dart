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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What is your dog\'s\ngender?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderButton('Male'),
                const SizedBox(width: 16),
                _genderButton('Female'),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE15C31),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: gender == null
                    ? null
                    : () => Get.to(() => DogSetupPhotoView(
                  dogName: widget.dogName,
                  dogGender: gender!,
                )),
                child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderButton(String label) {
    final isSelected = gender == label;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFE15C31) : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(color: const Color(0xFFE15C31)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => setState(() => gender = label),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
