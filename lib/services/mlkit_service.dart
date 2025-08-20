import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  late final ImageLabeler _imageLabeler;

  MLKitService() {
    _imageLabeler = ImageLabeler(
      options: LocalLabelerOptions(
        modelPath: 'assets/models/dog_mood_classifier.tflite',
        confidenceThreshold: 0.3,
      ),
    );
  }

  Future<List<ImageLabel>> processCameraImage(
      CameraImage cameraImage, InputImageRotation rotation) async {
    try {
      final bytes = _convertYUV420ToNV21(cameraImage);

      final metadata = InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);

      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) {
        debugPrint('! No labels detected by ML Kit');
      } else {
        labels.sort((a, b) => b.confidence.compareTo(a.confidence));
        final top = labels.first;
        print("🔹 Top label: ${top.label}, Confidence: ${top.confidence}");
      }

      return labels;
    } catch (e) {
      debugPrint("❌ Error processing camera image: $e");
      return [];
    }
  }

  void dispose() {
    _imageLabeler.close();
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final nv21 = Uint8List(width * height + 2 * (width ~/ 2) * (height ~/ 2));
    int index = 0;

    nv21.setRange(0, width * height, yPlane);
    index += width * height;

    for (int i = 0; i < uPlane.length; i++) {
      nv21[index++] = vPlane[i];
      nv21[index++] = uPlane[i];
    }

    return nv21;
  }
}
