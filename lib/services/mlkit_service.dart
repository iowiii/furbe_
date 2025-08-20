import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  late final ImageLabeler _imageLabeler;

  MLKitService() {
    _imageLabeler = ImageLabeler(
      options: LocalLabelerOptions(
        modelPath: 'assets/models/model.tflite',
        confidenceThreshold: 0.3, // adjust if needed
      ),
    );
  }

  Future<List<ImageLabel>> processCameraImage(
      CameraImage cameraImage, InputImageRotation rotation) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
      Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

      // Create ML Kit metadata (old version)
      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      );

      final inputImage =
      InputImage.fromBytes(bytes: bytes, metadata: metadata);

      final labels = await _imageLabeler.processImage(inputImage);
      return labels;
    } catch (e) {
      debugPrint("❌ Error processing camera image: $e");
      return [];
    }
  }

  void dispose() {
    _imageLabeler.close();
  }
}