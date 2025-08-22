import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteResult {
  final String label;
  final double confidence;

  TFLiteResult(this.label, this.confidence);
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  int _frameCount = 0;
  static const int _skipFrames = 5; // Process every 5th frame for better FPS

  TFLiteService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/dog_mood_classifier_finetuned.tflite',
      );

      _labels = [
        'shih_tzu_happy', 'shih_tzu_sad', 'shih_tzu_angry', 'shih_tzu_scared',
        'pug_happy', 'pug_sad', 'pug_angry', 'pug_scared',
        'pomeranian_happy', 'pomeranian_sad', 'pomeranian_angry', 'pomeranian_scared'
      ];

      print("✅ Model loaded successfully");

      // 🔎 Print Input Tensor details
      final inputs = _interpreter!.getInputTensors();
      for (var i = 0; i < inputs.length; i++) {
        print("👉 Input[$i] shape: ${inputs[i].shape}, type: ${inputs[i].type}");
      }

      // 🔎 Print Output Tensor details
      final outputs = _interpreter!.getOutputTensors();
      for (var i = 0; i < outputs.length; i++) {
        print("👉 Output[$i] shape: ${outputs[i].shape}, type: ${outputs[i].type}");
      }

    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }

  Future<List<TFLiteResult>> processCameraImage(CameraImage image) async {
    if (_interpreter == null) return [];

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

      // Create 2D output tensor [1, 12]
      final output = List.generate(1, (_) => List.filled(12, 0.0));

      _interpreter!.run(input, output);

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
    _interpreter?.close();
  }
}
