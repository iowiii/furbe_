import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Canonical color map for moods
const Map<String, Color> kMoodColors = {
  'happy': Colors.green,
  'sad': Colors.blue,
  'angry': Colors.red,
  'scared': Colors.orange,
};

const Map<String, double> kMoodScores = {
  'happy': 2.0,
  'sad': -1.0,
  'angry': -2.0,
  'scared': -1.0,
};

String normalizeMood(String? mood) => (mood ?? '').trim().toLowerCase();

Color moodColorOf(String mood) => kMoodColors[normalizeMood(mood)] ?? Colors.grey;

/// Per-day analytics output
class DailyMoodStats {
  final Map<String, int> counts;
  final Map<String, double> percentages;
  final String dominantMood;
  final double avgScore;

  DailyMoodStats({
    required this.counts,
    required this.percentages,
    required this.dominantMood,
    required this.avgScore,
  });
}

DailyMoodStats computeDailyStats(List<Map<String, dynamic>> saves) {
  final counts = <String, int>{'happy': 0, 'sad': 0, 'angry': 0, 'scared': 0};

  double totalScore = 0.0;
  int n = 0;

  for (final s in saves) {
    final mood = normalizeMood(s['mood']?.toString());
    if (!counts.containsKey(mood)) continue;
    counts[mood] = (counts[mood] ?? 0) + 1;
    totalScore += (kMoodScores[mood] ?? 0.0);
    n += 1;
  }

  final total = counts.values.fold<int>(0, (a, b) => a + b);
  final percentages = <String, double>{};
  if (total > 0) {
    counts.forEach((k, v) => percentages[k] = (v / total) * 100.0);
  } else {
    counts.forEach((k, _) => percentages[k] = 0.0);
  }

  String dominant = '—';
  int maxCount = -1;
  counts.forEach((k, v) {
    if (v > maxCount) {
      maxCount = v;
      dominant = k;
    }
  });

  final avg = n > 0 ? (totalScore / n) : 0.0;
  return DailyMoodStats(
    counts: counts,
    percentages: percentages,
    dominantMood: dominant,
    avgScore: avg,
  );
}

Map<String, List<Map<String, dynamic>>> groupSavesByDay(List<Map<String, dynamic>> saves) {
  final Map<String, List<Map<String, dynamic>>> grouped = {};
  for (final save in saves) {
    final dateStr = save['dateSave']?.toString();
    if (dateStr == null || dateStr.isEmpty) continue;

    final dt = DateTime.tryParse(dateStr);
    if (dt == null) continue;

    final key = DateFormat('yyyy-MM-dd').format(dt);
    grouped.putIfAbsent(key, () => []).add(save);
  }
  return grouped;
}
