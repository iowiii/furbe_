import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteResult {
  final String label;
  final double confidence;

  TFLiteResult(this.label, this.confidence);
}

class TFLiteService {
  Map<String, Interpreter> _interpreters = {};
  List<String> _labels = ['Happy', 'Sad', 'Angry', 'Scared'];
  int _frameCount = 0;
  static const int _skipFrames = 5; // Process every 5th frame for better FPS

  TFLiteService() {
    _loadModels();
  }

  Future<void> _loadModels() async {
    final breedModels = {
      'Pomeranian': 'assets/models/pomeranian_mood.tflite',
      'Pug': 'assets/models/pug_mood.tflite',
      'Shih Tzu': 'assets/models/shih_tzu_mood.tflite',
    };

    for (final entry in breedModels.entries) {
      try {
        final interpreter = await Interpreter.fromAsset(entry.value);
        _interpreters[entry.key] = interpreter;
        print("✅ ${entry.key} model loaded successfully");

        // 🔍 Inspect input and output tensor shapes
        for (var i = 0; i < interpreter.getInputTensors().length; i++) {
          final tensor = interpreter.getInputTensors()[i];
          print("🔹 ${entry.key} Input[$i] shape: ${tensor.shape}, type: ${tensor.type}");
        }

        for (var i = 0; i < interpreter.getOutputTensors().length; i++) {
          final tensor = interpreter.getOutputTensors()[i];
          print("🔸 ${entry.key} Output[$i] shape: ${tensor.shape}, type: ${tensor.type}");
        }
      } catch (e) {
        print('❌ Error loading ${entry.key} model: $e');
      }
    }
  }

  Future<List<TFLiteResult>> processCameraImage(CameraImage image, {String? breed}) async {
    if (breed == null || !_interpreters.containsKey(breed)) return [];

    final interpreter = _interpreters[breed]!;

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

      interpreter.run(input, output);

      final results = <TFLiteResult>[];
      final prediction = output[0];
      for (int i = 0; i < _labels.length; i++) {
        if (prediction[i] > 0.3) {
          results.add(TFLiteResult(_labels[i], prediction[i]));
        }
      }

      return results;
    } catch (e) {
      print("❌ Error processing image: $e");
      return [];
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
    for (final interpreter in _interpreters.values) {
      interpreter.close();
    }
    _interpreters.clear();
  }
}
