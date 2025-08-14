import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ModelController {
  late final ImageLabeler _imageLabeler;
  final double confidenceThreshold;
  final List<String> supportedLabels = [
    'shih_tzu_happy', 'shih_tzu_sad', 'shih_tzu_angry', 'shih_tzu_scared',
    'pug_happy', 'pug_sad', 'pug_angry', 'pug_scared',
    'pomeranian_happy', 'pomeranian_sad', 'pomeranian_angry', 'pomeranian_scared'
  ];

  ModelController({this.confidenceThreshold = 0.5}) {
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
    );
  }

  Future<String> classify(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(224, 224), // You can adjust if needed
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21, // Default format
          bytesPerRow: 224 * 3,
        ),
      );

      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) return 'no_dog';

      // Find highest confidence label that matches our supported list
      final topLabel = labels.reduce((a, b) => a.confidence > b.confidence ? a : b);
      if (!supportedLabels.contains(topLabel.label)) return 'no_dog';

      return topLabel.label;
    } catch (e) {
      debugPrint('Classification error: $e');
      return 'no_dog';
    }
  }

  void dispose() {
    _imageLabeler.close();
  }
}
