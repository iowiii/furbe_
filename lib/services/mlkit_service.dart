import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  late final ImageLabeler _imageLabeler;

  MLKitService() {
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  Future<List<ImageLabel>> processCameraImage(
      CameraImage image,
      InputImageRotation rotation,
      ) async {
    try {
      // Merge all planes into a single byte array
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final Uint8List bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final InputImageFormat format =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      // ✅ New metadata format — no planeData anymore
      final InputImageMetadata metadata = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );

      // Process image with ML Kit
      final labels = await _imageLabeler.processImage(inputImage);
      return labels;
    } catch (e) {
      debugPrint("Error processing image: $e");
      return [];
    }
  }

  void dispose() {
    _imageLabeler.close();
  }
}
