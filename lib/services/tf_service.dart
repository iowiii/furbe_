import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
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
      _interpreter =
      await Interpreter.fromAsset('assets/models/dog_mood_classifier_finetuned.tflite');
      _labels = [
        'shih_tzu_happy', 'shih_tzu_sad', 'shih_tzu_angry', 'shih_tzu_scared',
        'pug_happy', 'pug_sad', 'pug_angry', 'pug_scared',
        'pomeranian_happy', 'pomeranian_sad', 'pomeranian_angry', 'pomeranian_scared'
      ];
    } catch (e) {
      debugPrint('Error loading model: $e');
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
      
      // Create flat input tensor
      final input = Float32List(224 * 224 * 3);
      int pixelIndex = 0;
      
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          input[pixelIndex++] = pixel.r  / 255.0;
          input[pixelIndex++] = pixel.g  / 255.0;
          input[pixelIndex++] = pixel.b  / 255.0;
        }
      }
      
      final output = Float32List(_labels.length);
      final reshapedInput = input.reshape([1, 224, 224, 3]);
      final reshapedOutput = output.reshape([1, _labels.length]);

      _interpreter!.run(reshapedInput, reshapedOutput);


      final results = <TFLiteResult>[];
      for (int i = 0; i < _labels.length; i++) {
        if (output[i] > 0.3) {
          results.add(TFLiteResult(_labels[i], output[i]));
        }
      }

      return results;
    } catch (e) {
      debugPrint("Error processing image: $e");
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
