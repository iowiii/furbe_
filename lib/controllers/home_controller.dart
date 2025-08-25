import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/tf_service.dart';
import '../services/inference_service.dart';
import 'model_controller.dart';
import 'data_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


class HomeController extends GetxController {
  final TFLiteService tfliteService = TFLiteService();
  final DataController dataController = Get.find<DataController>();
  final modelController = ModelController();

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  RxBool isCameraInitialized = false.obs;
  RxBool isLoading = false.obs;
  RxString resultText = "".obs;
  RxString fpsText = "FPS: 0".obs;

  bool _isProcessing = false;
  bool _hasSaved = false;
  bool _saveToDatabase = false;
  String? _detectedBreed;
  bool _breedDetected = false;
  bool _isQuickScan = false;

  // FPS tracking
  DateTime? _lastFrameTime;
  int _frameCount = 0;
  double _currentFps = 0.0;

  // Memory protection
  int _skipFrameCount = 0;
  static const int _maxSkipFrames = 2;
  bool get mounted => Get.isRegistered<HomeController>();

  Future<void> initCamera({bool saveMode = false, bool quickScan = false}) async {
    // Clean buffer and temp files
    await _cleanBufferAndTemp();

    _saveToDatabase = saveMode;
    _hasSaved = false;
    _detectedBreed = null;
    _breedDetected = false;
    _isQuickScan = quickScan;

    // For Start Scan, use registered dog's breed
    if (!_isQuickScan) {
      final dog = dataController.currentDog.value;
      if (dog != null) {
        _detectedBreed = dog.type;
        _breedDetected = true;
      }
    }

    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.low, // Further reduced to prevent memory issues
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      cameraController!.startImageStream((CameraImage image) {
        // Skip frames to reduce processing load
        _skipFrameCount++;
        if (_skipFrameCount < _maxSkipFrames) return;
        _skipFrameCount = 0;

        if (!_isProcessing && mounted) {
          _isProcessing = true;
          processFrame(image).catchError((e) {
            debugPrint('Frame processing error: $e');
          }).whenComplete(() {
            // Increased delay to prevent memory overflow
            Future.delayed(const Duration(milliseconds: 800), () {
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
      // For Quick Scan: detect breed first, then mood
      // For Start Scan: use registered dog breed, detect mood only
      if (_isQuickScan && !_breedDetected) {
        await _detectBreedFromFrame(cameraImage);
        return;
      }

      // Detect mood using general model
      final results = await tfliteService.processCameraImageForMood(cameraImage);

      if (results.isNotEmpty) {
        results.sort((a, b) => b.confidence.compareTo(a.confidence));
        final topResult = results.first;

        // Only show results with 70% or higher confidence
        if (topResult.confidence >= 0.55) {
          final modeText = _saveToDatabase ? "[SAVING]" : "[QUICK]";
          final breedText = _detectedBreed != null ? " - $_detectedBreed" : "";

          resultText.value = "$modeText ${topResult.label}$breedText";
          fpsText.value = "FPS: ${_currentFps.toStringAsFixed(1)}";

          if (_saveToDatabase && !_hasSaved) {
            _hasSaved = true;
            showCapturePopup(topResult.label);
          }
        } else {
          final breedText = _detectedBreed ?? "dog";
          resultText.value = "Detecting $breedText mood (${(topResult.confidence * 100).toInt()}%)";
        }
      } //else {
        //final breedText = _detectedBreed ?? "dog";
        //resultText.value = "Position your $breedText";
      //}
    } catch (e) {
      debugPrint("Error in processFrame: $e");
      resultText.value = "Error detecting mood";
    }
  }

  Future<void> _detectBreedFromFrame(CameraImage cameraImage) async {
    try {
      // Convert camera image to bytes for breed detection
      final imageBytes = await _cameraImageToBytes(cameraImage);
      if (imageBytes == null) return;

      // Save temporary file for breed detection
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_breed_detection.jpg');
      await tempFile.writeAsBytes(imageBytes);

      // Detect breed using inference service
      final breedResult = await InferenceService.detectBreed(tempFile.path);

      if (breedResult['label'] != 'Unknown' && breedResult['confidence'] > 0.6) {
        _detectedBreed = breedResult['label'];
        _breedDetected = true;
        resultText.value = "Breed detected: $_detectedBreed. Now detecting mood...";
      } else {
        resultText.value = "Detecting breed... (${(breedResult['confidence'] * 100).toInt()}%)";
      }

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      debugPrint("Error detecting breed: $e");
      _breedDetected = true;
      resultText.value = "Proceeding with mood detection...";
    }
  }

  Future<Uint8List?> _cameraImageToBytes(CameraImage cameraImage) async {
    try {
      final img.Image rgbImage = _yuv420ToImage(cameraImage);
      return Uint8List.fromList(img.encodeJpg(rgbImage));
    } catch (e) {
      debugPrint("Error converting camera image: $e");
      return null;
    }
  }

  img.Image _yuv420ToImage(CameraImage image) {
    final maxDimension = 320;
    final width = image.width > maxDimension ? maxDimension : image.width;
    final height = image.height > maxDimension ? maxDimension : image.height;

    final imgImage = img.Image(width: width, height: height);

    try {
      final yPlane = image.planes[0].bytes;
      final uPlane = image.planes[1].bytes;
      final vPlane = image.planes[2].bytes;

      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final scaleX = image.width / width;
      final scaleY = image.height / height;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final srcX = (x * scaleX).toInt();
          final srcY = (y * scaleY).toInt();

          final uvIndex = uvPixelStride * (srcX ~/ 2) + uvRowStride * (srcY ~/ 2);
          final yIndex = srcY * image.planes[0].bytesPerRow + srcX;

          if (yIndex < yPlane.length && uvIndex < uPlane.length && uvIndex < vPlane.length) {
            final yp = yPlane[yIndex];
            final up = uPlane[uvIndex];
            final vp = vPlane[uvIndex];

            // Convert YUV -> RGB
            int r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255).toInt();
            int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                .clamp(0, 255)
                .toInt();
            int b = (yp + up * 1814 / 1024 - 227).clamp(0, 255).toInt();

            imgImage.setPixelRgb(x, y, r, g, b);
          }
        }
      }
    } catch (e) {
      debugPrint('YUV conversion error: $e');
    }

    return imgImage;
  }


  void showCapturePopup(String mood) {
    final dog = dataController.currentDog.value;
    if (dog == null) return;

    final dateNow = DateTime.now();
    final infoController = TextEditingController(text: ""); // reset on scan

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dog Detected",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dog info boxes
                _infoBox("Name: ${dog.name}"),
                const SizedBox(height: 8),
                _infoBox("Breed: ${_detectedBreed ?? dog.type}"),
                const SizedBox(height: 8),
                _infoBox("Mood: $mood"),
                const SizedBox(height: 8),
                _infoBox("Date: ${DateFormat('MMM dd, yyyy HH:mm').format(dateNow)}"),
                const SizedBox(height: 12),

                // Additional info input
                TextField(
                  controller: infoController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Info',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Save button full width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      dog.info = infoController.text;
                      await _saveResult(mood, _detectedBreed ?? dog.type);
                      Get.back();

                      // Close camera and show loading
                      await disposeCamera();
                      isLoading.value = true;
                      resultText.value = "Cleaning and preparing camera...";

                      // Clean and restart camera
                      await _cleanBufferAndTemp();
                      await initCamera(saveMode: _saveToDatabase, quickScan: _isQuickScan);

                      isLoading.value = false;
                      resultText.value = "";
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  Future<void> _saveResult(String mood, String breed) async {
    final dog = dataController.currentDog.value;
    final userPhone = dataController.currentPhone;
    if (dog == null || userPhone == null) return;

    final dateNow = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(dateNow);
    final saveId = "${dog.id}_$formattedDate";

    final saveData = {
      'dogName': dog.name,
      'mood': mood,
      'breed': breed,
      'dateSave': dateNow.toIso8601String(),
      'info': dog.info,
    };

    await dataController.firebaseService.db
        .child('accounts/$userPhone/saves/${dog.id}/$saveId')
        .set(saveData);

    print("Saved scan: $saveData");
  }

  // Start Scan - uses registered dog breed, detects mood and saves to database
  Future<void> startScan() async {
    await initCamera(saveMode: true, quickScan: false);
  }

  // Quick Scan - detects breed first, then mood, no saving
  Future<void> quickScan() async {
    await initCamera(saveMode: false, quickScan: true);
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

  Future<void> _cleanBufferAndTemp() async {
    try {
      // Clear temp directory
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final file in tempDir.list()) {
          if (file is File) {
            await file.delete().catchError((_) {});
          }
        }
      }

      // Reset processing flags
      _isProcessing = false;
      _skipFrameCount = 0;

      // Force garbage collection with longer delay for thorough cleaning
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Error cleaning buffer and temp: $e');
    }
  }

  Future<void> disposeCamera() async {
    try {
      _isProcessing = false;
      await cameraController?.stopImageStream();
      await cameraController?.dispose();
      cameraController = null;
      isCameraInitialized.value = false;
      _lastFrameTime = null;
      _frameCount = 0;

      // Force garbage collection
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  @override
  void onClose() {
    disposeCamera();
    tfliteService.dispose();
    super.onClose();
  }
}
