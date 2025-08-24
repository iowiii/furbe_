import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class BreedClassificationResult {
  final String breed;
  final double confidence;

  BreedClassificationResult(this.breed, this.confidence);
}

class BreedClassificationService {
  Interpreter? _interpreter;
  final List<String> _breedLabels = ['Pomeranian', 'Pug', 'Shih Tzu'];
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/dog_classification.tflite');
      _isModelLoaded = true;
      print("✅ Breed classification model loaded successfully");
    } catch (e) {
      print('❌ Error loading breed classification model: $e');
    }
  }

  Future<BreedClassificationResult?> classifyBreed(CameraImage image) async {
    if (!_isModelLoaded || _interpreter == null) return null;

    try {
      final img.Image rgbImage = _yuv420ToImage(image);
      final img.Image resized = img.copyResize(rgbImage, width: 224, height: 224);

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

      final output = List.generate(1, (_) => List.filled(_breedLabels.length, 0.0));
      _interpreter!.run(input, output);

      final prediction = output[0];
      final maxIndex = prediction.indexWhere((e) => e == prediction.reduce((a, b) => a > b ? a : b));
      
      return BreedClassificationResult(_breedLabels[maxIndex], prediction[maxIndex]);
    } catch (e) {
      print("❌ Error classifying breed: $e");
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

        int r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255).toInt();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).clamp(0, 255).toInt();
        int b = (yp + up * 1814 / 1024 - 227).clamp(0, 255).toInt();

        imgImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return imgImage;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}