import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/dog_sprite.dart';
import '../../widgets/mood_display.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Obx(() {
            if (!c.isCameraInitialized.value || c.cameraController == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return CameraPreview(c.cameraController!);
          }),
        ),

        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => DogSprite(mood: c.resultText.value)),
                const SizedBox(height: 12),
                Obx(() => MoodDisplay(
                  breed: 'Dog',
                  mood: c.resultText.value,
                  confidence: 0.0,
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Save Detection tapped: ${c.resultText.value}');
                    },
                    child: const Text('Save Detection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
