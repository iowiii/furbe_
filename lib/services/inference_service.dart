import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class InferenceService {
  static const String _pythonServerUrl = 'http://localhost:8000';
  
  static Future<Map<String, dynamic>> detectBreed(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return {'label': 'Unknown', 'confidence': 0.0};
      }

      final request = http.MultipartRequest('POST', Uri.parse('$_pythonServerUrl/predict_breed'));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {'label': 'Unknown', 'confidence': 0.0};
      }
    } catch (e) {
      print('Error detecting breed: $e');
      // Fallback to mock detection
      return _mockBreedDetection();
    }
  }
  
  static Future<Map<String, dynamic>> detectBreedAndMood(String imagePath) async {
    try {
      // First detect breed
      final breedResult = await detectBreed(imagePath);
      final breed = breedResult['label'];
      
      // Then detect mood using the detected breed
      final moodResult = await detectMood(imagePath, breed: breed);
      
      return {
        'breed': breedResult,
        'mood': moodResult,
      };
    } catch (e) {
      print('Error detecting breed and mood: $e');
      return {
        'breed': _mockBreedDetection(),
        'mood': _mockMoodDetection(),
      };
    }
  }
  
  static Future<Map<String, dynamic>> detectMood(String imagePath, {String? breed}) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return {'label': 'Unknown', 'confidence': 0.0};
      }

      final request = http.MultipartRequest('POST', Uri.parse('$_pythonServerUrl/predict_mood'));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      // Add breed parameter if provided
      if (breed != null) {
        request.fields['breed'] = breed;
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {'label': 'Unknown', 'confidence': 0.0};
      }
    } catch (e) {
      print('Error detecting mood: $e');
      // Fallback to mock detection
      return _mockMoodDetection();
    }
  }
  
  static Map<String, dynamic> _mockBreedDetection() {
    final breeds = ['Pomeranian', 'Pug', 'Shih Tzu'];
    final random = DateTime.now().millisecond % breeds.length;
    return {
      'label': breeds[random],
      'confidence': 0.85 + (DateTime.now().millisecond % 15) / 100
    };
  }
  
  static Map<String, dynamic> _mockMoodDetection() {
    final moods = ['Happy', 'Sad', 'Angry', 'Scared'];
    final random = DateTime.now().millisecond % moods.length;
    return {
      'label': moods[random],
      'confidence': 0.80 + (DateTime.now().millisecond % 20) / 100,
      'breed': 'Unknown'
    };
  }
  
  static Future<Map<String, dynamic>> checkModelsStatus() async {
    try {
      final response = await http.get(Uri.parse('$_pythonServerUrl/models_status'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed to check models status'};
      }
    } catch (e) {
      print('Error checking models status: $e');
      return {'error': 'Connection failed'};
    }
  }
}