import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return Colors.red.shade600;
      case TaskPriority.medium:
        return Colors.orange.shade600;
      case TaskPriority.low:
        return Colors.green.shade600;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String time;
  final TaskPriority priority;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.priority,
    this.isDone = false,
  });
}
