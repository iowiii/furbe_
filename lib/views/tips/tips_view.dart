import 'package:flutter/material.dart';

class TipsView extends StatelessWidget {
  const TipsView({super.key});
  @override
  Widget build(BuildContext context) {
    final tips = [
      'If your dog shows prolonged sadness, check environment & diet.',
      'Anxious dogs benefit from calm, consistent routines.',
      'Use positive reinforcement when training.',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Tips')),
      body: ListView.builder(itemCount: tips.length, itemBuilder: (c, i) => ListTile(title: Text(tips[i]))),
    );
  }
}
