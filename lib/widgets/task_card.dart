import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

/// A reusable card that displays a single [Task] with its title, description,
/// priority badge, status badge, category chip, and time label.
///
/// [onToggle] is called when the leading checkbox is tapped.
/// [onStatusChanged] is optional — shows a status dropdown menu if provided.
class TaskCard extends StatelessWidget {
  final Task task;
  final String category;
  final VoidCallback? onToggle;
  final ValueChanged<TaskStatus>? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.category,
    this.onToggle,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDone = task.isDone;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone
              ? cs.outlineVariant.withValues(alpha: 0.4)
              : cs.outlineVariant,
          width: 1,
        ),
      ),
      color: isDone
          ? cs.surfaceContainerLowest
          : cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isDone,
                  onChanged: onToggle == null ? null : (_) => onToggle!(),
                  shape: const CircleBorder(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone
                                ? cs.onSurface.withValues(alpha: 0.45)
                                : cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        status: task.status,
                        onChanged: onStatusChanged,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    task.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(
                        alpha: isDone ? 0.35 : 0.6,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Bottom row: category · priority · time
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _CategoryChip(label: category),
                      _PriorityBadge(priority: task.priority),
                      _TimeBadge(time: task.time),
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
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

/// Tappable status badge. If [onChanged] is provided, tapping opens a popup
/// menu to cycle through all statuses.
class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final ValueChanged<TaskStatus>? onChanged;

  const _StatusBadge({required this.status, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );

    if (onChanged == null) return badge;

    return PopupMenuButton<TaskStatus>(
      tooltip: 'Change status',
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (_) => TaskStatus.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  Icon(s.icon, size: 16, color: s.color),
                  const SizedBox(width: 8),
                  Text(s.label),
                ],
              ),
            ),
          )
          .toList(),
      child: badge,
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: priority.color,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  static const _categoryColors = <String, Color>{
    'Work': Colors.indigo,
    'Learning': Colors.purple,
    'Personal': Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[label] ?? Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String time;
  const _TimeBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 11,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 3),
        Text(
          time,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
