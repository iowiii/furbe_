import 'package:flutter/material.dart';

class SaveCard extends StatelessWidget {
  final String dogName;
  final String breed;
  final String mood;
  final String date;

  const SaveCard({
    super.key,
    required this.dogName,
    required this.breed,
    required this.mood,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$dogName ($breed)'),
        subtitle: Text('Mood: $mood\nDate: $date'),
      ),
    );
  }
}
