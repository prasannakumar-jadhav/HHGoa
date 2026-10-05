import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const _ActionButton(
                    icon: Icons.add_task,
                    label: 'New Task',
                    color: Colors.indigo,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const _ActionButton(
                    icon: Icons.mic,
                    label: 'Voice',
                    color: Colors.purple,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const _ActionButton(
                    icon: Icons.auto_awesome,
                    label: 'AI Assist',
                    color: Colors.teal,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const _ActionButton(
                    icon: Icons.bar_chart,
                    label: 'Analytics',
                    color: Colors.orange,
                  ),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
