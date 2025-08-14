import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodChart extends StatelessWidget {
  final Map<String, int> moodData;
  const MoodChart({super.key, required this.moodData});

  @override
  Widget build(BuildContext context) {
    final moods = moodData.keys.toList();
    final counts = moodData.values.toList();

    return PieChart(
      PieChartData(
        sections: List.generate(
          moods.length,
              (i) => PieChartSectionData(
            value: counts[i].toDouble(),
            title: moods[i],
          ),
        ),
      ),
    );
  }
}
