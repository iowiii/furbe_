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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'What is the name\nof your dog?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: nameController,
                cursorColor: Colors.grey.shade600, // cursor color
                decoration: InputDecoration(
                  hintText: 'Enter dog name',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade600, // normal border color
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE15C31), // focused border color
                      width: 2,
                    ),
                  ),
                ),
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
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    Get.to(() => DogSetupGenderView(dogName: nameController.text.trim()));
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
