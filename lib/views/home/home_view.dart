import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import 'package:camera/camera.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        elevation: 0,
        title: Row(
          children: [
            // sample profile pic
            const CircleAvatar(
             //HERE PROFILE? IDK
              radius: 30.0,
            ),
            const SizedBox(width: 8),
            Text("Riri", style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // or any color you want
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Start Scan button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE15C31),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(40),
              ),
              onPressed: () async {
                await Get.to(() => const StartScanPage());
              },
              child: const Icon(
                Icons.videocam_outlined,
                size: 40,
                color: Colors.white, //makes icon white
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start Scan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // or any color you want
              ),
            ),

            // Space between buttons
            const SizedBox(height: 130),

            // Quick Scan button but still using the startScan button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE15C31),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(40),
              ),
              onPressed: () async {
                await Get.to(() => const StartScanPage(quick: true));
              },
              child: const Icon(
                Icons.flash_on,
                size: 40,
                color: Colors.white, //makes icon white
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Quick Scan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // or any color you want
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class StartScanPage extends StatefulWidget {
  final bool quick;
  const StartScanPage({super.key, this.quick = false});

  @override
  State<StartScanPage> createState() => _StartScanPageState();
}

class _StartScanPageState extends State<StartScanPage> {
  final HomeController c = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    c.initCamera();
  }

  @override
  void dispose() {
    c.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange.shade700, // back button color
        title: Text(
          widget.quick ? "Quick Scan" : "Start Scan",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Obx(() {
          if (!c.isCameraInitialized.value || c.cameraController == null) {
            return const CircularProgressIndicator();
          }

          // Keep aspect ratio to prevent stretching
          return FittedBox(
            fit: BoxFit.cover, // fills the whole screen
            child: SizedBox(
              width: c.cameraController!.value.previewSize!.height,
              height: c.cameraController!.value.previewSize!.width,
              child: CameraPreview(c.cameraController!),
            ),
          );
        }),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Position your dog within the frame",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Result text if detected
          Obx(() {
            final mood = c.resultText.value;
            if (mood.isEmpty) return const SizedBox.shrink();
            return Container(
              color: Colors.green,
              padding: const EdgeInsets.all(16),
              child: Text(
                mood,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }
}

