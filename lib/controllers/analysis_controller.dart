import 'package:get/get.dart';

class AnalysisController extends GetxController {
  final RxMap<String, int> moodCount = {
    'happy': 0,
    'sad': 0,
    'angry': 0,
    'scared': 0,
  }.obs;

  void logMood(String mood) {
    if (moodCount.containsKey(mood)) {
      moodCount[mood] = moodCount[mood]! + 1;
    }
  }

  Map<String, int> getMoodStats() {
    return moodCount;
  }
}
