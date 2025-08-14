class MoodLogger {
  final List<Map<String, dynamic>> logs = [];

  void addLog(String breed, String mood) {
    logs.add({
      'breed': breed,
      'mood': mood,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> getLogs() {
    return logs;
  }
}
