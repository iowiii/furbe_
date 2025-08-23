// lib/services/dog_inference.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Model paths (same as your Python)
const String _breedModelPath = 'assets/models/dog_classification.tflite';
const Map<String, String> _moodModelPaths = {
    'Pomeranian': 'assets/models/pomeranian_mood.tflite',
    'Pug': 'assets/models/pug_mood.tflite',
    'Shih Tzu': 'assets/models/shih_tzu_mood.tflite',
};

/// Class names
const List<String> breedClasses = ['Pomeranian', 'Pug', 'Shih Tzu'];
const List<String> moodClasses  = ['Happy', 'Sad', 'Angry', 'Scared'];

class DogInference {
Interpreter? _breedInterpreter;
final Map<String, Interpreter> _moodInterpreters = {};
bool _initialized = false;

/// Lazy init: first call to predict will load models.
                                               Future<void> _ensureInitialized() async {
if (_initialized) return;

try {
final options = InterpreterOptions();

// Breed model
_breedInterpreter = await Interpreter.fromAsset(_breedModelPath, options: options);

// Mood models
for (final entry in _moodModelPaths.entries) {
    try {
    final it = await Interpreter.fromAsset(entry.value, options: options);
_moodInterpreters[entry.key] = it;
} catch (e) {
    debugPrint('Failed loading mood model for ${entry.key}: $e');
}
}

_initialized = true;
} catch (e) {
    debugPrint('Error loading models: $e');
}
}

/// Convert image bytes Float32List normalized to [0,1], shape (1,224,224,3)
Float32List _preprocess(Uint8List imageBytes, {int inputSize = 224}) {
    final decoded = img.decodeImage(imageBytes);
if (decoded == null) {
    throw Exception('Could not decode image bytes');
}

final resized = img.copyResize(
    decoded,
    width: inputSize,
height: inputSize,
interpolation: img.Interpolation.average,
);

// Get RGB bytes and normalize
final rgbBytes = resized.getBytes(order: img.ChannelOrder.rgb);
final floats = Float32List(rgbBytes.length);
for (var i = 0; i < rgbBytes.length; i++) {
    floats[i] = rgbBytes[i] / 255.0;
}
return floats; // flattened [H*W*3]
}

int _argMax(List<double> list) {
var bestIdx = 0;
var bestVal = list[0];
for (var i = 1; i < list.length; i++) {
if (list[i] > bestVal) {
bestVal = list[i];
bestIdx = i;
}
}
return bestIdx;
}

/// Returns: {"label": String, "confidence": double}
Future<Map<String, dynamic>> predictBreed(Uint8List imageBytes) async {
await _ensureInitialized();
final it = _breedInterpreter;
if (it == null) {
return {"label": "Unknown", "confidence": 0.0};
}

try {
final floats = _preprocess(imageBytes, inputSize: 224);

// Input: [1, 224, 224, 3]
final input = floats.reshape([1, 224, 224, 3]);

// Output: [1, numClasses]
final output = List<double>.filled(breedClasses.length, 0).reshape([1, breedClasses.length]);

it.run(input, output);
final scores = List<double>.from(output[0]);
final idx = _argMax(scores);

return {"label": breedClasses[idx], "confidence": scores[idx].toDouble()};
} catch (e) {
debugPrint('Error predicting breed: $e');
return {"label": "Unknown", "confidence": 0.0};
}
}

/// Returns: {"label": String, "confidence": double, "breed": String}
Future<Map<String, dynamic>> predictMood(Uint8List imageBytes, {String? breed}) async {
    await _ensureInitialized();

// Auto-detect breed if not provided
String detectedBreed = breed ?? (await predictBreed(imageBytes))["label"] as String;

final it = _moodInterpreters[detectedBreed];
if (it == null) {
return {"label": "Unknown", "confidence": 0.0, "breed": detectedBreed};
}

try {
final floats = _preprocess(imageBytes, inputSize: 224);
final input = floats.reshape([1, 224, 224, 3]);

final output = List<double>.filled(moodClasses.length, 0).reshape([1, moodClasses.length]);

it.run(input, output);
final scores = List<double>.from(output[0]);
final idx = _argMax(scores);

return {
    "label": moodClasses[idx],
    "confidence": scores[idx].toDouble(),
    "breed": detectedBreed,
};
} catch (e) {
debugPrint('Error predicting mood for $detectedBreed: $e');
return {"label": "Unknown", "confidence": 0.0, "breed": detectedBreed};
}
}

/// Free native resources if you need to tear down.
                                              Future<void> close() async {
try {
_breedInterpreter?.close();
for (final it in _moodInterpreters.values) {
it.close();
}
_moodInterpreters.clear();
_initialized = false;
} catch (_) {}
}
}

/// Global instance and convenience functions (similar to Python)
final dogInference = DogInference();

Future<Map<String, dynamic>> predictBreed(Uint8List imageBytes) =>
dogInference.predictBreed(imageBytes);

Future<Map<String, dynamic>> predictMood(Uint8List imageBytes, {String? breed}) =>
dogInference.predictMood(imageBytes, breed: breed);
