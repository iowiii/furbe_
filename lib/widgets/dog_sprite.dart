import 'package:flutter/material.dart';

class DogSprite extends StatelessWidget {
  final String mood;
  const DogSprite({super.key, required this.mood});
  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.pets;
    final m = mood.toLowerCase();
    if (m.contains('happy')) icon = Icons.emoji_emotions;
    if (m.contains('sad')) icon = Icons.emoji_emotions_outlined;
    if (m.contains('angry')) icon = Icons.mood_bad;
    if (m.contains('scared')) icon = Icons.sentiment_very_dissatisfied;
    return CircleAvatar(radius: 36, child: Icon(icon, size: 36));
  }
}
