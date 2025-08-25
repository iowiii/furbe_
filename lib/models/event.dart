import 'dart:ui';

class Event {
  final DateTime time;
  final String category;
  final String? title;
  final Color? color;

  Event({
    required this.time,
    required this.category,
    this.title,
    this.color,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      time: DateTime.parse(map['dateSave'] ?? DateTime.now().toIso8601String()),
      category: map['mood'] ?? 'uncategorized',
      title: map['title'],
    );
  }
}