import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section A: Hero completion card ──────────────────────────
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '82%',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tasks completed this week',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+12% vs last week ↑',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section B: 2×2 stat grid ─────────────────────────────────
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  icon: Icons.check_circle_outline,
                  value: '14',
                  label: 'Total Tasks',
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
                _StatCard(
                  icon: Icons.task_alt,
                  value: '11',
                  label: 'Completed',
                  color: Colors.green,
                  theme: theme,
                ),
                _StatCard(
                  icon: Icons.local_fire_department,
                  value: '5 days',
                  label: 'Current Streak',
                  color: Colors.orange,
                  theme: theme,
                ),
                _StatCard(
                  icon: Icons.timer_outlined,
                  value: '3.2h',
                  label: 'Focus Time',
                  color: theme.colorScheme.secondary,
                  theme: theme,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section C: Category Breakdown ────────────────────────────
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _CategoryBreakdownItem(
              label: 'Work',
              percentage: '64%',
              fraction: 0.64,
              color: theme.colorScheme.primary,
            ),
            _CategoryBreakdownItem(
              label: 'Personal',
              percentage: '21%',
              fraction: 0.21,
              color: theme.colorScheme.tertiary,
            ),
            _CategoryBreakdownItem(
              label: 'Learning',
              percentage: '15%',
              fraction: 0.15,
              color: theme.colorScheme.secondary,
            ),

            const SizedBox(height: 24),

            // ── Section D: Recent Activity ───────────────────────────────
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._recentActivity.map(
              (entry) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                title: Text(entry.$1),
                subtitle: Text(entry.$2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<(String, String)> _recentActivity = [
    ('Refactor auth module', '2h ago'),
    ('Morning workout', '5h ago'),
    ('Write API docs', 'Yesterday'),
    ('Call dentist', 'Yesterday'),
    ('Grocery shopping', '2 days ago'),
  ];
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownItem extends StatelessWidget {
  const _CategoryBreakdownItem({
    required this.label,
    required this.percentage,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String percentage;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(percentage, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: fraction,
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
