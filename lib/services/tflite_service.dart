import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  late ImageProcessor _imageProcessor;
  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  bool get isLoaded => _interpreter != null && _labels != null;

  Future<void> loadModel({
    String modelAsset = 'assets/model.tflite',
    String labelsAsset = 'assets/labels.txt',
  }) async {
    _interpreter = await Interpreter.fromAsset(
      modelAsset,
      options: InterpreterOptions()..threads = 4,
    );

    final rawLabels = await rootBundle.loadString(labelsAsset);
    _labels = rawLabels
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    // Input shape: [1, height, width, channels]
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final height = inputShape[1];
    final width = inputShape[2];

    _imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(height, width, ResizeMethod.bilinear))
        .add(NormalizeOp(127.5, 127.5)) // [-1, 1] normalization
        .build();

    _inputImage = TensorImage(TfLiteType.float32);

    // Create output buffer with correct shape and type
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final outputType = _interpreter!.getOutputTensor(0).type;
    _outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
  }

  /// Predict mood and breed from `image.Image` frame.
  Future<Map<String, dynamic>> predict(img.Image frame) async {
    if (!isLoaded) {
      throw Exception('Model not loaded');
    }

    _inputImage.loadImage(frame);
    final processedImage = _imageProcessor.process(_inputImage);

    // Run inference with TensorImage and TensorBuffer
    _interpreter!.run(processedImage.buffer, _outputBuffer.buffer);

    final probs = _outputBuffer.getDoubleList();

    int maxIndex = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIndex = i;
      }
    }

    final label = _labels![maxIndex];
    final parts = label.split('_');
    final breed = parts.isNotEmpty ? parts[0] : label;
    final mood = parts.length > 1 ? parts.sublist(1).join('_') : 'unknown';

    return {
      'label': label,
      'breed': breed,
      'mood': mood,
      'confidence': maxProb,
      'raw': probs,
    };
  }
}
