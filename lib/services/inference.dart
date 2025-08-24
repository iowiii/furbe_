// lib/services/inference.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Model paths
const String _breedModelPath = 'assets/models/dog_classification.tflite';
const String _moodModelPath = 'assets/models/dog_mood_efficientnetb0_float32.tflite';

/// Class names
const List<String> breedClasses = ['Pomeranian', 'Pug', 'Shih Tzu'];
const List<String> moodClasses = ['Happy', 'Sad', 'Angry', 'Scared'];

class DogInference {
Interpreter? _breedInterpreter;
Interpreter? _moodInterpreter;
bool _initialized = false;

Future<void> _ensureInitialized() async {
if (_initialized) return;
try {
final options = InterpreterOptions(); // e.g., options.threads = 2;
_breedInterpreter =
await Interpreter.fromAsset(_breedModelPath, options: options);

_moodInterpreter =
await Interpreter.fromAsset(_moodModelPath, options: options);

_initialized = true;
} catch (e) {
    debugPrint('Error loading models: $e');
}
}

/// Resize to 224x224 and normalize to [0,1], returning flattened Float32List (H*W*3).
Float32List _preprocess(Uint8List imageBytes, {int size = 224}) {
    final decoded = img.decodeImage(imageBytes);
if (decoded == null) {
    throw Exception('Could not decode image');
}
final resized = img.copyResize(decoded, width: size, height: size);
final rgb = resized.getBytes(order: img.ChannelOrder.rgb); // 3 bytes/px
final out = Float32List(rgb.length);
for (var i = 0; i < rgb.length; i++) {
    out[i] = rgb[i] / 255.0;
}
return out;
}

// Build a 4D list [1, H, W, 3] from flattened floats (Interpreter needs nested lists).
                                                      List<List<List<List<double>>>> _to4D(
Float32List flat, int h, int w, int c) {
var idx = 0;
return [
    List.generate(
        h,
        (_) => List.generate(
    w,
    (_) => List.generate(
    c,
    (_) => flat[idx++].toDouble(),
),
),
)
];
}

int _argMax(List<double> v) {
var bi = 0;
var bv = v[0];
for (var i = 1; i < v.length; i++) {
if (v[i] > bv) {
bv = v[i];
bi = i;
}
}
return bi;
}

/// Returns {"label": String, "confidence": double}
Future<Map<String, dynamic>> predictBreed(Uint8List imageBytes) async {
await _ensureInitialized();
final it = _breedInterpreter;
if (it == null) {
return {"label": "Unknown", "confidence": 0.0};
}

try {
final floats = _preprocess(imageBytes, size: 224);
final input = _to4D(floats, 224, 224, 3);
final output = [
    List<double>.filled(breedClasses.length, 0.0),
];

it.run(input, output);
final scores = List<double>.from(output[0]);
final idx = _argMax(scores);

return {"label": breedClasses[idx], "confidence": scores[idx].toDouble()};
} catch (e) {
debugPrint('Error predicting breed: $e');
return {"label": "Unknown", "confidence": 0.0};
}
}

/// Returns {"label": String, "confidence": double}
Future<Map<String, dynamic>> predictMood(Uint8List imageBytes) async {
    await _ensureInitialized();

final it = _moodInterpreter;
if (it == null) {
return {"label": "Unknown", "confidence": 0.0};
}

try {
final floats = _preprocess(imageBytes, size: 224);
final input = _to4D(floats, 224, 224, 3);
final output = [
    List<double>.filled(moodClasses.length, 0.0),
];

it.run(input, output);
final scores = List<double>.from(output[0]);
final idx = _argMax(scores);

return {
    "label": moodClasses[idx],
    "confidence": scores[idx].toDouble()
};
} catch (e) {
debugPrint('Error predicting mood: $e');
return {"label": "Unknown", "confidence": 0.0};
}
}

Future<void> close() async {
try {
_breedInterpreter?.close();
_moodInterpreter?.close();
_initialized = false;
} catch (_) {}
}
}

/// Global instance & convenience functions (to mirror Python)
final inference = DogInference();

Future<Map<String, dynamic>> predictBreed(Uint8List imageBytes) =>
inference.predictBreed(imageBytes);

Future<Map<String, dynamic>> predictMood(Uint8List imageBytes) =>
inference.predictMood(imageBytes);
