import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelController {
  late Interpreter _interpreter;
  final int inputSize = 224;
  final List<String> labels = [
    'shih_tzu_happy', 'shih_tzu_sad', 'shih_tzu_angry', 'shih_tzu_scared',
    'pug_happy', 'pug_sad', 'pug_angry', 'pug_scared',
    'pomeranian_happy', 'pomeranian_sad', 'pomeranian_angry', 'pomeranian_scared'
  ];

  bool _isModelLoaded = false;
  late List<int> _outputShape;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('your_model.tflite');
      _outputShape = _interpreter.getOutputTensor(0).shape;
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  /// Preprocess image for Float32 model input [0,1] normalization
  Float32List preprocess(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Unable to decode image");
    }

    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    final input = Float32List(inputSize * inputSize * 3);

    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = img.getRed(pixel) / 255.0;
        input[index++] = img.getGreen(pixel) / 255.0;
        input[index++] = img.getBlue(pixel) / 255.0;
      }
    }
    return input;
  }

  Future<String> classify(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      print('❗ Model not loaded yet');
      return 'no_dog';
    }

    try {
      final input = preprocess(imageBytes).reshape([1, inputSize, inputSize, 3]);
      final output = List.filled(_outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(_outputShape);

      _interpreter.run(input, output);

      // Flatten output to a single list of probabilities
      final probs = List<double>.from(output[0]);

      // Find max probability index
      int maxIndex = 0;
      double maxProb = probs[0];
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > maxProb) {
          maxProb = probs[i];
          maxIndex = i;
        }
      }

      return labels[maxIndex];
    } catch (e) {
      print('Classification error: $e');
      return 'no_dog';
    }
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
