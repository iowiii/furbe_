import 'package:camera/camera.dart';
import 'breed_classification_service.dart';
import 'tf_service.dart';

class BreedMoodResult {
  final String breed;
  final String mood;
  final double breedConfidence;
  final double moodConfidence;

  BreedMoodResult({
    required this.breed,
    required this.mood,
    required this.breedConfidence,
    required this.moodConfidence,
  });
}

class BreedMoodDetector {
  final BreedClassificationService _breedService = BreedClassificationService();
  final TFLiteService _moodService = TFLiteService();
  
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _breedService.loadModel();
    _isInitialized = true;
  }

  Future<BreedMoodResult?> detectBreedAndMood(CameraImage image) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Step 1: Detect breed
    final breedResult = await _breedService.classifyBreed(image);
    if (breedResult == null || breedResult.confidence < 0.6) {
      return null;
    }

    // Step 2: Detect mood using breed-specific model
    final moodResults = await _moodService.processCameraImage(image, breed: breedResult.breed);
    if (moodResults.isEmpty) {
      return null;
    }

    // Get the highest confidence mood
    moodResults.sort((a, b) => b.confidence.compareTo(a.confidence));
    final topMood = moodResults.first;

    if (topMood.confidence < 0.7) {
      return null;
    }

    return BreedMoodResult(
      breed: breedResult.breed,
      mood: topMood.label,
      breedConfidence: breedResult.confidence,
      moodConfidence: topMood.confidence,
    );
  }

  void dispose() {
    _breedService.dispose();
    _moodService.dispose();
  }
}