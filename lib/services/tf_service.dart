import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class TFLiteResult {
  final String label;
  final double confidence;

  TFLiteResult(this.label, this.confidence);
}

class TFLiteService {
  Interpreter? _moodInterpreter;
  Interpreter? _breedInterpreter;
  List<String> _moodLabels = ['Happy', 'Sad', 'Angry', 'Scared'];
  int _frameCount = 0;
  static const int _skipFrames = 5; // Process every 5th frame for better FPS

  TFLiteService() {
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      // Load general mood detection model
      _moodInterpreter = await Interpreter.fromAsset('assets/models/dog_mood_lite0_float32_7_3.tflite');
      print("✅ General mood model loaded successfully");
      
      // Load breed detection model
      _breedInterpreter = await Interpreter.fromAsset('assets/models/dog_classification.tflite');
      print("✅ Breed detection model loaded successfully");

      // Inspect tensor shapes
      if (_moodInterpreter != null) {
        for (var i = 0; i < _moodInterpreter!.getInputTensors().length; i++) {
          final tensor = _moodInterpreter!.getInputTensors()[i];
          print("🔹 Mood Input[$i] shape: ${tensor.shape}, type: ${tensor.type}");
        }
        for (var i = 0; i < _moodInterpreter!.getOutputTensors().length; i++) {
          final tensor = _moodInterpreter!.getOutputTensors()[i];
          print("🔸 Mood Output[$i] shape: ${tensor.shape}, type: ${tensor.type}");
        }
      }
    } catch (e) {
      print('❌ Error loading models: $e');
    }
  }

  Future<List<TFLiteResult>> processCameraImageForMood(CameraImage image) async {
    if (_moodInterpreter == null) return [];

    // Skip frames for better FPS
    _frameCount++;
    if (_frameCount % _skipFrames != 0) return [];

    try {
      final img.Image rgbImage = _yuv420ToImage(image);
      final img.Image resized = img.copyResize(rgbImage, width: 224, height: 224);

      // Create 4D input tensor [1, 224, 224, 3]
      final input = List.generate(1, (_) =>
          List.generate(224, (y) =>
              List.generate(224, (x) =>
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

      // Create 2D output tensor [1, 4] for mood classes
      final output = List.generate(1, (_) => List.filled(4, 0.0));

      _moodInterpreter!.run(input, output);

      final results = <TFLiteResult>[];
      final prediction = output[0];
      for (int i = 0; i < _moodLabels.length; i++) {
        if (prediction[i] > 0.3) {
          results.add(TFLiteResult(_moodLabels[i], prediction[i]));
        }
      }

      return results;
    } catch (e) {
      print("❌ Error processing image for mood: $e");
      return [];
    }
  }

  Future<TFLiteResult?> detectBreedFromBytes(Uint8List imageBytes) async {
    if (_breedInterpreter == null) return null;

    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      
      final resized = img.copyResize(image, width: 224, height: 224);

      // Create 4D input tensor [1, 224, 224, 3]
      final input = List.generate(1, (_) =>
          List.generate(224, (y) =>
              List.generate(224, (x) =>
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

      // Assuming breed model outputs probabilities for different breeds
      final output = List.generate(1, (_) => List.filled(3, 0.0)); // Adjust size based on your breed model
      _breedInterpreter!.run(input, output);

      final prediction = output[0];
      final maxIndex = prediction.indexWhere((e) => e == prediction.reduce((a, b) => a > b ? a : b));
      
      final breedLabels = ['Pomeranian', 'Pug', 'Shih Tzu']; // Adjust based on your model
      if (maxIndex >= 0 && maxIndex < breedLabels.length) {
        return TFLiteResult(breedLabels[maxIndex], prediction[maxIndex]);
      }
      
      return null;
    } catch (e) {
      print("❌ Error detecting breed: $e");
      return null;
    }
  }

  img.Image _yuv420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final imgImage = img.Image(width: width, height: height);

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final yp = yPlane[y * image.planes[0].bytesPerRow + x];
        final up = uPlane[uvIndex];
        final vp = vPlane[uvIndex];

        // Convert YUV -> RGB
        int r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255).toInt();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .clamp(0, 255)
            .toInt();
        int b = (yp + up * 1814 / 1024 - 227).clamp(0, 255).toInt();

        imgImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return imgImage;
  }

  void dispose() {
    _moodInterpreter?.close();
    _breedInterpreter?.close();
    _moodInterpreter = null;
    _breedInterpreter = null;
  }
}
