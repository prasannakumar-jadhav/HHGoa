import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onNewTask;
  final VoidCallback? onVoice;
  final VoidCallback? onAiAssist;
  final VoidCallback? onAnalytics;

  const QuickActionsCard({
    super.key,
    this.onNewTask,
    this.onVoice,
    this.onAiAssist,
    this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.add_task_rounded,
                  label: 'New Task',
                  color: Colors.indigo,
                  onTap: onNewTask,
                ),
                _ActionButton(
                  icon: Icons.mic_rounded,
                  label: 'Voice',
                  color: Colors.purple,
                  onTap: onVoice,
                ),
                _ActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Assist',
                  color: Colors.teal,
                  onTap: onAiAssist,
                ),
                _ActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  color: Colors.orange,
                  onTap: onAnalytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
