import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dog_setup_photo_view.dart';

class DogSetupBreedView extends StatefulWidget {
  final String dogName;
  final String dogGender;

  const DogSetupBreedView({
    super.key,
    required this.dogName,
    required this.dogGender,
  });

  @override
  State<DogSetupBreedView> createState() => _DogSetupBreedViewState();
}

class _DogSetupBreedViewState extends State<DogSetupBreedView> {
  String? selectedBreed;

  final List<String> breeds = [
    "Shih Tzu",
    "Pug",
    "Pomeranian",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "What is your dog’s breed?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            ...breeds.map((breed) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => selectedBreed = breed),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selectedBreed == breed ? const Color(0xFFE15C31) : Colors.transparent,
                    foregroundColor: selectedBreed == breed ? Colors.white : const Color(0xFFE15C31),
                    side: const BorderSide(color: Color(0xFFE15C31)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    breed,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ))
            ,
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedBreed == null
                    ? null
                    : () => Get.to(() => DogSetupPhotoView(
                  dogName: widget.dogName,
                  dogGender: widget.dogGender,
                  dogBreed: selectedBreed!,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE15C31),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
