import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  /// Converts [CameraImage] to [InputImage] for ML Kit
  InputImage _convertToInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final cameraRotation = InputImageRotation.rotation0deg; // Adjust if needed

    final inputImageFormat = InputImageFormatMethods.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: cameraRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );
  }

  /// Processes the image and returns [label, confidence]
  Future<Map<String, dynamic>?> processImage(CameraImage image) async {
    try {
      final inputImage = _convertToInputImage(image);
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        final topLabel = labels.first;
        return {
          "label": topLabel.label,
          "confidence": topLabel.confidence,
        };
      }
    } catch (e) {
      debugPrint("MLKit processing error: $e");
    }
    return null;
  }

  void dispose() {
    _imageLabeler.close();
  }
}
