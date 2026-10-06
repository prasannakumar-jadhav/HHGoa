import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

class StatsRow extends StatelessWidget {
  final List<Task> tasks;
  const StatsRow({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final total = tasks.length;
    final completed = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final inProgress = tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .length;
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: total,
            icon: Icons.format_list_bulleted_rounded,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Done',
            value: completed,
            icon: Icons.check_circle_rounded,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Active',
            value: inProgress,
            icon: Icons.timelapse_rounded,
            color: cs.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: pending,
            icon: Icons.hourglass_empty_rounded,
            color: Colors.orange.shade600,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      // Inherits CardTheme: elevation-0, radius-16, surfaceContainerLow
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
