import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:voxpilot/models/task_model.dart';

/// Persists and retrieves the task list (with category) using [SharedPreferences].
///
/// Each entry is stored as `{ "task": { ...Task fields... }, "category": "Work" }`
/// so that the category survives app restarts without a separate data store.
///
/// Call [saveItems] after every mutation (add, delete, toggle, status change).
/// Call [loadItems] once at startup.
class TaskStorageService {
  static const String _kKey = 'voxpilot_task_items';

  // Singleton ----------------------------------------------------------------
  TaskStorageService._();
  static final TaskStorageService instance = TaskStorageService._();

  // Public API ---------------------------------------------------------------

  /// Loads the persisted list. Each map has keys `"task"` and `"category"`.
  /// Returns an empty list if nothing is saved yet or decoding fails.
  Future<List<({Task task, String category})>> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return (
          task: Task.fromJson(map['task'] as Map<String, dynamic>),
          category: map['category'] as String,
        );
      }).toList();
    } catch (_) {
      // Corrupt data — start fresh rather than crash.
      return [];
    }
  }

  /// Persists [items]. Each item must expose `task` (a [Task]) and
  /// `category` (a [String]) — matching the `_TaskItem` fields in
  /// tasks_screen.dart.
  Future<void> saveItems(List<({Task task, String category})> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      items
          .map((i) => {'task': i.task.toJson(), 'category': i.category})
          .toList(),
    );
    await prefs.setString(_kKey, encoded);
  }

  /// Removes all persisted tasks (useful for testing / reset flows).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
