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

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('your_model.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Uint8List preprocess(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    final resized = img.copyResize(image!, width: inputSize, height: inputSize);

    final input = Float32List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }
    return input.buffer.asUint8List();
  }

  Future<String> classify(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      print('Model not loaded yet');
      return 'no_dog';
    }
    try {
      final input = preprocess(imageBytes);
      final output = List.filled(12, 0.0).reshape([1, 12]);
      _interpreter.run(input, output);

      final prediction = output[0] as List<double>;
      final maxIndex = prediction.indexWhere(
            (e) => e == prediction.reduce((a, b) => a > b ? a : b),
      );

      return labels[maxIndex];
    } catch (e) {
      print('Classification error: $e');
      return 'no_dog';
    }
  }
}
