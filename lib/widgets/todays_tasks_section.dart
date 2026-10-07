import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

class TodaysTasksSection extends StatelessWidget {
  final List<Task> tasks;
  final void Function(String taskId) onToggle;
  final VoidCallback? onSeeAll;

  const TodaysTasksSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Today's Tasks", style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: theme.textTheme.labelMedium?.copyWith(color: cs.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TaskCard(task: task, onTap: () => onToggle(task.id)),
          ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDone = task.isDone;

    return AnimatedOpacity(
      opacity: isDone ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        // Inherits CardTheme: elevation-0, radius-16, surfaceContainerLow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDone
                ? cs.outlineVariant.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isDone,
                    onChanged: (_) => onTap(),
                    shape: const CircleBorder(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: cs.onSurface.withValues(alpha: 0.4),
                          color: isDone
                              ? cs.onSurface.withValues(alpha: 0.4)
                              : cs.onSurface,
                        ),
                        child: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Priority badge + time
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
                        color: task.priority.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.priority.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: task.priority.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
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
