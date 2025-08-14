import 'package:flutter/material.dart';

class MoodDisplay extends StatelessWidget {
  final String breed;
  final String mood;
  final double confidence;
  const MoodDisplay({super.key, required this.breed, required this.mood, required this.confidence});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Breed: $breed', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Mood: $mood (${(confidence * 100).toStringAsFixed(0)}%)'),
    ]);
  }
}
