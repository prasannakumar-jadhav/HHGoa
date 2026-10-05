import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

// Local wrapper to attach a category string to each Task without modifying task_model.dart
class _TaskItem {
  final Task task;
  final String category;

  _TaskItem({required this.task, required this.category});
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<_TaskItem> _items = [
    _TaskItem(
      task: Task(
        id: 't1',
        title: 'Refactor auth module',
        description: 'Clean up JWT logic',
        time: '9:00 AM',
        priority: TaskPriority.high,
        isDone: false,
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't2',
        title: 'Read Clean Code chapter 5',
        description: 'Book study session',
        time: '11:00 AM',
        priority: TaskPriority.medium,
        isDone: false,
      ),
      category: 'Learning',
    ),
    _TaskItem(
      task: Task(
        id: 't3',
        title: 'Grocery shopping',
        description: 'Weekly groceries',
        time: '1:00 PM',
        priority: TaskPriority.low,
        isDone: true,
      ),
      category: 'Personal',
    ),
    _TaskItem(
      task: Task(
        id: 't4',
        title: 'Write API docs',
        description: 'Document REST endpoints',
        time: '2:00 PM',
        priority: TaskPriority.medium,
        isDone: false,
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't5',
        title: 'Morning workout',
        description: '30 min cardio',
        time: '7:00 AM',
        priority: TaskPriority.low,
        isDone: true,
      ),
      category: 'Personal',
    ),
    _TaskItem(
      task: Task(
        id: 't6',
        title: 'Review Flutter PR #88',
        description: 'Check UI changes',
        time: '3:00 PM',
        priority: TaskPriority.high,
        isDone: false,
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't7',
        title: 'Study state management',
        description: 'Riverpod deep dive',
        time: '5:00 PM',
        priority: TaskPriority.medium,
        isDone: false,
      ),
      category: 'Learning',
    ),
    _TaskItem(
      task: Task(
        id: 't8',
        title: 'Call dentist',
        description: 'Schedule appointment',
        time: '10:00 AM',
        priority: TaskPriority.low,
        isDone: true,
      ),
      category: 'Personal',
    ),
  ];

  void _toggleTask(int index) {
    setState(() {
      _items[index].task.isDone = !_items[index].task.isDone;
    });
  }

  Widget _buildTaskCard(BuildContext context, _TaskItem item, int index,
      {bool completedOnly = false}) {
    final theme = Theme.of(context);
    final task = item.task;
    final isDone = task.isDone;

    final titleStyle = completedOnly || isDone
        ? theme.textTheme.bodyLarge?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          )
        : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isDone,
              onChanged: completedOnly
                  ? null
                  : (_) => _toggleTask(index),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: titleStyle),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Category chip
                      Chip(
                        label: Text(
                          item.category,
                          style: theme.textTheme.labelSmall,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      // Priority badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.priority.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priority.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: task.priority.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Time
                      Text(
                        task.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedItems = _items
        .where((item) => item.task.isDone)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Tasks'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Tasks tab
            ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              itemBuilder: (context, index) =>
                  _buildTaskCard(context, _items[index], index),
            ),
            // Completed tab
            completedItems.isEmpty
                ? Center(
                    child: Text(
                      'No completed tasks yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: completedItems.length,
                    itemBuilder: (context, index) => _buildTaskCard(
                      context,
                      completedItems[index],
                      // find original index for toggling (though completedOnly disables it)
                      _items.indexOf(completedItems[index]),
                      completedOnly: true,
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Task coming soon!')),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
