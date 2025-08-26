import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelController {
  late Interpreter _interpreter;
  final int inputSize = 224;
  final List<String> labels = ['Happy', 'Sad', 'Angry', 'Scared'];

  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/dog_mood_lite0_float32_7_3.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  List<List<List<List<double>>>> preprocess(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    final resized = img.copyResize(image!, width: inputSize, height: inputSize);

    // Create 4D tensor [1, 224, 224, 3]
    final input = List.generate(1, (_) => 
      List.generate(inputSize, (y) => 
        List.generate(inputSize, (x) => 
          List.generate(3, (c) {
            final pixel = resized.getPixel(x, y);
            switch (c) {
              case 0: return pixel.r / 255.0;
              case 1: return pixel.g / 255.0;
              case 2: return pixel.b / 255.0;
              default: return 0.0;
            }
          })
        )
      )
    );
    return input;
  }

  Future<String> classify(Uint8List imageBytes) async {
    if (!_isModelLoaded) {
      print('Model not loaded yet');
      return 'no_dog';
    }
    try {
      final input = preprocess(imageBytes);
      // Create 2D output tensor [1, 4] for general mood classes
      final output = List.generate(1, (_) => List.filled(4, 0.0));
      
      _interpreter.run(input, output);

      final prediction = output[0];
      final maxIndex = prediction.indexWhere(
            (e) => e == prediction.reduce((a, b) => a > b ? a : b),
      );

      if (maxIndex >= 0 && maxIndex < labels.length) {
        return labels[maxIndex];
      }
      return 'no_dog';
    } catch (e) {
      print('Classification error: $e');
      return 'no_dog';
    }
  }
  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
      print('Model disposed');
    }
  }
}
