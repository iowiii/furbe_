import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../services/tflite_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../models/mood_entry.dart';

class HomeController extends GetxController {
  final TFLiteService _tflite = Get.find<TFLiteService>();
  final StorageService _storage = Get.find<StorageService>();
  final FirebaseService _firebase = Get.find<FirebaseService>();

  CameraController? cameraController;
  RxString detectedBreed = '---'.obs;
  RxString currentMood = '---'.obs;
  RxDouble confidence = 0.0.obs;
  RxBool processing = false.obs;

  List<CameraDescription>? cameras;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _tflite.loadModel();
    await _initCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      final cam = cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras!.first);
      cameraController = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await cameraController!.initialize();
      // start stream
      cameraController!.startImageStream(_processCameraImage);
      update();
    } catch (e) {
      Get.snackbar('Camera', 'Error initializing camera: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (processing.value) return;
    if (!_tflite.isLoaded) return;
    processing.value = true;
    try {
      final converted = _yuv420ToImage(image);
      final result = await _tflite.predict(converted);
      detectedBreed.value = result['breed'] ?? 'Unknown';
      currentMood.value = result['mood'] ?? 'Unknown';
      confidence.value = (result['confidence'] as double?) ?? 0.0;
    } catch (e) {
      // ignore silently
    } finally {
      processing.value = false;
    }
  }

  // Convert YUV420 to package:image Image
  img.Image _yuv420ToImage(CameraImage camImage) {
    final width = camImage.width;
    final height = camImage.height;
    final image = img.Image(width, height);

    final planeY = camImage.planes[0].bytes;
    final planeU = camImage.planes[1].bytes;
    final planeV = camImage.planes[2].bytes;

    final rowStride = camImage.planes[0].bytesPerRow;
    final uvRowStride = camImage.planes[1].bytesPerRow;
    final uvPixelStride = camImage.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yp = y * rowStride + x;
        final uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;
        final yVal = planeY[yp];
        final uVal = planeU[uvIndex];
        final vVal = planeV[uvIndex];

        int r = (yVal + (1.370705 * (vVal - 128))).round();
        int g = (yVal - (0.337633 * (uVal - 128)) - (0.698001 * (vVal - 128))).round();
        int b = (yVal + (1.732446 * (uVal - 128))).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b);
      }
    }
    return image;
  }

  Future<void> saveDetection() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('Save', 'Camera not ready');
      return;
    }
    try {
      final file = await cameraController!.takePicture();
      final bytes = await File(file.path).readAsBytes();
      final path = await _storage.saveImageBytes(bytes, namePrefix: 'detection');
      final entry = MoodEntry(
        id: const Uuid().v4(),
        breed: detectedBreed.value,
        mood: currentMood.value,
        confidence: confidence.value,
        imagePath: path,
        createdAt: DateTime.now(),
      );
      await _firebase.pushMoodEntry(entry.toJson());
      Get.snackbar('Saved', 'Saved: $path');
    } catch (e) {
      Get.snackbar('Save', 'Failed to save: $e');
    }
  }

  Widget cameraPreviewWidget() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(cameraController!);
  }
}
