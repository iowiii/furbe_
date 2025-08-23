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
      final dog = dataController.currentDog.value;
      if (dog == null) {
        resultText.value = "No dog registered";
        return;
      }

      final results = await tfliteService.processCameraImage(cameraImage, breed: dog.type);

      if (results.isNotEmpty) {
        results.sort((a, b) => b.confidence.compareTo(a.confidence));
        final topResult = results.first;
        
        // Only show results with 70% or higher confidence
        if (topResult.confidence >= 0.7) {
          final modeText = _saveToDatabase ? "[SAVING]" : "[QUICK]";
          
          if (_saveToDatabase) {
            resultText.value = "$modeText ${topResult.label} - ${dog.type}";
          } else {
            resultText.value = "$modeText ${topResult.label}";
          }
          
          fpsText.value = "FPS: ${_currentFps.toStringAsFixed(1)}";
          
          if (_saveToDatabase && !_hasSaved) {
            _hasSaved = true;
            Future.delayed(const Duration(seconds: 3), () {
              showCapturePopup(topResult.label);
            });
          }
        } else {
          resultText.value = "Detecting ${dog.type} mood (${(topResult.confidence * 100).toInt()}%)";
        }
      } else {
        resultText.value = "Position your ${dog.type}";
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
                _infoBox("Breed: ${dog.type}"),
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
                      dog.info = infoController.text; // save additional info
                      await _saveResult(mood);
                      Get.back();
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
