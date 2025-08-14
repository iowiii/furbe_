import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/mlkit_service.dart';

class HomeController extends GetxController {
  final MLKitService _mlKitService = MLKitService();
  final RxString detectedBreed = ''.obs;
  final RxString currentMood = ''.obs;
  final RxDouble confidence = 0.0.obs;

  CameraController? cameraController;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _savedDetections = [];

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await cameraController!.initialize();

    cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      final result = await _mlKitService.processImage(image);
      if (result != null) {
        detectedBreed.value = result["label"];
        confidence.value = result["confidence"];
        currentMood.value = _mapBreedToMood(result["label"]);
      }

      _isProcessing = false;
    });

    update();
  }

  String _mapBreedToMood(String breed) {
    // You can customize mood mapping here
    if (breed.toLowerCase().contains("happy")) return "Happy";
    if (breed.toLowerCase().contains("sad")) return "Sad";
    if (breed.toLowerCase().contains("angry")) return "Angry";
    return "Neutral";
  }

  Widget cameraPreviewWidget() {
    return cameraController != null && cameraController!.value.isInitialized
        ? CameraPreview(cameraController!)
        : const Center(child: CircularProgressIndicator());
  }

  void saveDetection() {
    if (detectedBreed.value.isNotEmpty) {
      _savedDetections.add({
        "breed": detectedBreed.value,
        "mood": currentMood.value,
        "confidence": confidence.value,
        "timestamp": DateTime.now().toIso8601String(),
      });
      Get.snackbar("Saved", "Detection saved successfully!");
    }
  }

  List<Map<String, dynamic>> get savedDetections => _savedDetections;

  @override
  void onClose() {
    cameraController?.dispose();
    _mlKitService.dispose();
    super.onClose();
  }
}
