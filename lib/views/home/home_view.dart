import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart'; // ✅ Needed for CameraPreview

import '../../controllers/home_controller.dart';
import '../../widgets/dog_sprite.dart';
import '../../widgets/mood_display.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Live camera preview
            Expanded(
              flex: 3,
              child: Obx(() {
                if (!c.isCameraInitialized.value || c.cameraController == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CameraPreview(c.cameraController!);
              }),
            ),

            // Mood + info display
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show your sprite based on the current label text
                  Obx(() => DogSprite(mood: c.resultText.value)),
                  const SizedBox(height: 8),
                  // Simple display (breed/confidence placeholders for now)
                  Obx(() => MoodDisplay(
                    breed: 'Dog',
                    mood: c.resultText.value,
                    confidence: 0.0,
                  )),
                  const SizedBox(height: 8),
                  // Optional button (no-op here since we’re doing live feed only)
                  ElevatedButton(
                    onPressed: () {
                      // Hook this up to a save method if you add one later.
                      debugPrint('Save Detection tapped: ${c.resultText.value}');
                    },
                    child: const Text('Save Detection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Get.toNamed('/save');
          if (i == 2) Get.toNamed('/profile');
          if (i == 3) Get.toNamed('/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Saves'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
