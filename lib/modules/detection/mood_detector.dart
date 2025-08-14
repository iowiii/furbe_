import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MoodDetector {
  late final ImageLabeler _imageLabeler;
  final double confidenceThreshold;

  MoodDetector({this.confidenceThreshold = 0.5}) {
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
    );
  }

  Future<Map<String, dynamic>> detectMood(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) {
        return {
          'mood': 'unknown',
          'confidence': 0.0,
        };
      }

      // Get the top label
      final topLabel = labels.reduce((a, b) => a.confidence > b.confidence ? a : b);

      return {
        'mood': topLabel.label,
        'confidence': topLabel.confidence,
      };
    } catch (e) {
      debugPrint('Mood detection error: $e');
      return {
        'mood': 'error',
        'confidence': 0.0,
      };
    }
  }

  void dispose() {
    _imageLabeler.close();
  }
}
