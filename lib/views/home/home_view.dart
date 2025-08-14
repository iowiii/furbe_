import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            Expanded(flex: 3, child: Obx(() => c.cameraPreviewWidget())),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => DogSprite(mood: c.currentMood.value)),
                  const SizedBox(height: 8),
                  Obx(() => MoodDisplay(
                    breed: c.detectedBreed.value,
                    mood: c.currentMood.value,
                    confidence: c.confidence.value,
                  )),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: c.saveDetection,
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
