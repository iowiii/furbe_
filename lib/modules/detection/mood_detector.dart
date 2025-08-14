import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class MoodDetector {
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('dog_mood_model.tflite');
      _labels = await _loadLabels('assets/labels.txt');
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<List<String>> _loadLabels(String assetPath) async {
    final rawLabels = await rootBundle.loadString(assetPath);
    return rawLabels
        .split('\n')
        .where((element) => element.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> detectMood(File imageFile) {
    TensorImage inputImage = TensorImage.fromFile(imageFile);

    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(224, 224, ResizeMethod.bilinear))
        .build();

    inputImage = imageProcessor.process(inputImage);

    // Pass shape as List<int> — no TensorShape import needed
    final outputBuffer = TensorBufferFloat([1, _labels.length]);

    _interpreter.run(inputImage.buffer, outputBuffer.buffer);

    final labeledProb =
    TensorLabel.fromList(_labels, outputBuffer).getMapWithFloatValue();

    final sorted = labeledProb.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'mood': sorted.first.key,
      'confidence': sorted.first.value,
    };
  }
}
