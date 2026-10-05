import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

class TodaysTasksSection extends StatelessWidget {
  final List<Task> tasks;
  final void Function(String taskId) onToggle;

  const TodaysTasksSection({
    super.key,
    required this.tasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's Tasks",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: tasks
              .map(
                (task) => _TaskCard(task: task, onTap: () => onToggle(task.id)),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: task.isDone ? 0.6 : 1.0,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Checkbox(
                  value: task.isDone,
                  onChanged: (_) => onTap(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isDone ? Colors.grey : Colors.black87,
                        ),
                        child: Text(task.title),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: task.priority.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: task.priority.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
