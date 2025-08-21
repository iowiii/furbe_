import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/tf_service.dart';
import 'model_controller.dart';
import 'data_controller.dart';
import 'package:intl/intl.dart';


class HomeController extends GetxController {
  final TFLiteService tfliteService = TFLiteService();
  final DataController dataController = Get.find<DataController>();
  final modelController = ModelController();

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  RxBool isCameraInitialized = false.obs;
  RxString resultText = "".obs;
  RxString fpsText = "FPS: 0".obs;

  bool _isProcessing = false;
  bool _hasSaved = false;
  bool _saveToDatabase = false;
  
  // FPS tracking
  DateTime? _lastFrameTime;
  int _frameCount = 0;
  double _currentFps = 0.0;

  Future<void> initCamera({bool saveMode = false}) async {
    _saveToDatabase = saveMode;
    _hasSaved = false;

    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.medium, // Reduced from high to medium for better FPS
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          processFrame(image).then((_) {
            // Add delay to prevent buffer overflow and reduce GC pressure
            Future.delayed(const Duration(milliseconds: 300), () {
              _isProcessing = false;
            });
          });
        }
      });
    } else {
      resultText.value = "No camera found";
    }
  }

  Future<void> processFrame(CameraImage cameraImage) async {
    // Calculate FPS
    _updateFPS();

    try {
      final results = await tfliteService.processCameraImage(cameraImage);

      if (results.isNotEmpty) {
        results.sort((a, b) => b.confidence.compareTo(a.confidence));
        final topResult = results.first;
        print("Top result: ${topResult.label}, Confidence: ${topResult.confidence}");

        final modeText = _saveToDatabase ? "[SAVING]" : "[QUICK]";
        resultText.value = "$modeText ${topResult.label}";
        fpsText.value = "FPS: ${_currentFps.toStringAsFixed(1)}";
        print("Mood detected: ${topResult.label} (Save mode: $_saveToDatabase)");

        if (_saveToDatabase && !_hasSaved) {
          _hasSaved = true;
          Future.delayed(const Duration(seconds: 5), () {
            showCapturePopup(topResult.label);
          });
        }
      } else {
        resultText.value = "Position your dog";
        print("No mood detected");
      }
    } catch (e) {
      debugPrint("Error in processFrame: $e");
      resultText.value = "Error detecting mood";
    }
  }


  void showCapturePopup(String mood) {
    final dog = dataController.currentDog.value;
    if (dog == null) return;

    final dateNow = DateTime.now();

    Get.dialog(
      AlertDialog(
        title: const Text("Dog Detected"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Name: ${dog.name}"),
            Text("Mood: $mood"),
            Text("Date: ${dateNow.toLocal().toString().split('.')[0]}"),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: dog.info),
              decoration: const InputDecoration(
                labelText: 'Additional Info',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => dog.info = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveResult(mood);
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResult(String mood) async {
    final dog = dataController.currentDog.value;
    final userPhone = dataController.currentPhone;
    if (dog == null || userPhone == null) return;

    final dateNow = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(dateNow);
    final saveId = "${dog.id}_$formattedDate";

    final saveData = {
      'dogName': dog.name,
      'mood': mood,
      'dateSave': dateNow.toIso8601String(),
      'info': dog.info,
    };

    await dataController.firebaseService.db
        .child('accounts/$userPhone/saves/${dog.id}/$saveId')
        .set(saveData);

    print("Saved scan: $saveData");
  }

  // Start Scan - detects mood and saves to database
  Future<void> startScan() async {
    await initCamera(saveMode: true);
  }

  // Quick Scan - detects mood only, no saving
  Future<void> quickScan() async {
    await initCamera(saveMode: false);
  }

  void _updateFPS() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final timeDiff = now.difference(_lastFrameTime!).inMilliseconds;
      if (timeDiff > 0) {
        _currentFps = 1000.0 / timeDiff;
        _frameCount++;
        
        // Update FPS display every 10 frames
        if (_frameCount % 10 == 0) {
          fpsText.value = "FPS: ${_currentFps.toStringAsFixed(1)}";
        }
      }
    }
    _lastFrameTime = now;
  }

  Future<void> disposeCamera() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    isCameraInitialized.value = false;
    _lastFrameTime = null;
    _frameCount = 0;
  }

  @override
  void onClose() {
    disposeCamera();
    tfliteService.dispose();
    super.onClose();
  }
}
