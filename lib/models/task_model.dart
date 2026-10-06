import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, completed }

// ---------------------------------------------------------------------------
// Extensions
// ---------------------------------------------------------------------------

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

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.grey.shade600;
      case TaskStatus.inProgress:
        return Colors.blue.shade600;
      case TaskStatus.completed:
        return Colors.green.shade600;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class Task {
  final String id;
  final String title;
  final String description;

  /// Optional display time string (e.g. "2:00 PM"). Kept for backward
  /// compatibility with widgets that show a time label.
  final String time;

  final TaskPriority priority;
  TaskStatus status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.priority,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convenience getter — true when status is [TaskStatus.completed].
  bool get isDone => status == TaskStatus.completed;

  /// Toggles between [TaskStatus.pending] and [TaskStatus.completed].
  /// If the task is [TaskStatus.inProgress] it moves to [TaskStatus.completed].
  void toggleDone() {
    status = isDone ? TaskStatus.pending : TaskStatus.completed;
  }

  /// Returns a copy with updated fields.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
