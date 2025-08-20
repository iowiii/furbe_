import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/mlkit_service.dart';
import 'model_controller.dart';
import 'data_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';


class HomeController extends GetxController {
  final MLKitService mlKitService = MLKitService();
  final DataController dataController = Get.find<DataController>();
  final modelController = ModelController();

  CameraController? cameraController;
  List<CameraDescription>? cameras;
  RxBool isCameraInitialized = false.obs;
  RxString resultText = "".obs;

  bool _isProcessing = false;
  bool _hasSaved = false;
  bool autoSave = false;

  Future<void> initCamera({bool saveMode = false}) async {
    autoSave = saveMode;
    _hasSaved = false;

    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          processFrame(image).then((_) => _isProcessing = false);
        }
      });
    } else {
      resultText.value = "No camera found";
    }
  }

  Future<void> processFrame(CameraImage cameraImage) async {

    try {
      final rotation = InputImageRotationValue.fromRawValue(
        cameras!.first.sensorOrientation,
      ) ?? InputImageRotation.rotation0deg;

      final labels = await mlKitService.processCameraImage(cameraImage, rotation);

      if (labels.isNotEmpty) {
        labels.sort((a, b) => b.confidence.compareTo(a.confidence));
        final topLabel = labels.first;
        print("🔹 Top label: ${topLabel.label}, Confidence: ${topLabel.confidence}");

        if (topLabel.label.toLowerCase() == "dog") {
          print("✅ Dog detected! Running TFLite model for mood...");

          final bytes = _concatenatePlanes(cameraImage.planes);

          final mood = await modelController.classify(bytes);

          if (mood.isNotEmpty) {
            resultText.value = mood;
            print("✅ Mood detected: $mood");

            if (!_hasSaved) {
              _hasSaved = true;
              Future.delayed(const Duration(seconds: 5), () {
                showCapturePopup(mood);
              });
            }
          } else {
            resultText.value = "Mood unknown";
            print("⚠️ TFLite model returned unknown mood");
          }
        } else {
          resultText.value = "Position your dog";
          print("⚠️ Top label not a dog: ${topLabel.label}");
        }
      } else {
        resultText.value = "No labels detected";
        print("⚠️ No labels detected by ML Kit");
      }
    } catch (e) {
      debugPrint("❌ Error in processFrame: $e");
      resultText.value = "Error detecting mood";
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
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

    print("✅ Saved scan: $saveData");
  }

  Future<void> disposeCamera() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    isCameraInitialized.value = false;
  }

  @override
  void onClose() {
    disposeCamera();
    mlKitService.dispose();
    super.onClose();
  }
}
