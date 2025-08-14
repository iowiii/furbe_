import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});
  @override
  Widget build(BuildContext context) {
    // Placeholder chart; hook to Firebase data later
    final spots = [FlSpot(0, 1), FlSpot(1, 2), FlSpot(2, 1.5), FlSpot(3, 3)];
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: Center(
        child: SizedBox(height: 220, child: LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3)]))),
      ),
    );
  }
}
