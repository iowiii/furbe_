import 'package:flutter/material.dart';

class SaveView extends StatelessWidget {
  const SaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Saved mood scans will appear here.",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}