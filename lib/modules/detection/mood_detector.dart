import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MoodDetector {
  late Interpreter _interpreter;
  late List<String> _labels;
  late List<int> _inputShape;
  late List<int> _outputShape;

  Future<void> loadModel() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('dog_mood_model.tflite');

      // Get input/output tensor shapes
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      // Load labels
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

  /// Preprocess the image: resize and normalize to [0,1]
  Float32List _preprocessImage(File imageFile) {
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    final targetHeight = _inputShape[1];
    final targetWidth = _inputShape[2];

    // Resize
    final resized = img.copyResize(image, width: targetWidth, height: targetHeight);

    // Convert to Float32List
    final inputBuffer = Float32List(targetHeight * targetWidth * 3);
    int index = 0;

    for (int y = 0; y < targetHeight; y++) {
      for (int x = 0; x < targetWidth; x++) {
        final pixel = resized.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // Normalization to [0,1] — change to (-1,1) if your model expects it
        inputBuffer[index++] = r / 255.0;
        inputBuffer[index++] = g / 255.0;
        inputBuffer[index++] = b / 255.0;
      }
    }

    return inputBuffer;
  }

  Map<String, dynamic> detectMood(File imageFile) {
    final input = _preprocessImage(imageFile)
        .reshape([1, _inputShape[1], _inputShape[2], _inputShape[3]]);

    // Prepare output buffer
    final output = List.filled(_outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(_outputShape);

    // Run inference
    _interpreter.run(input, output);

    // Flatten output to probabilities
    final probs = List<double>.from(output[0]);

    // Find max probability
    int maxIndex = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIndex = i;
      }
    }

    return {
      'mood': _labels[maxIndex],
      'confidence': maxProb,
    };
  }
}

extension ListReshapeExt<T> on List<T> {
  dynamic reshape(List<int> dims) {
    if (dims.length == 1) return this;
    int chunkSize = dims.sublist(1).reduce((a, b) => a * b);
    return [
      for (int i = 0; i < length; i += chunkSize)
        sublist(i, i + chunkSize).reshape(dims.sublist(1))
    ];
  }
}
