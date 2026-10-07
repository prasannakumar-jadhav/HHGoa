import 'package:flutter/material.dart';
import 'package:voxpilot/services/task_storage_service.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> showProfileSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _ProfileSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  int _totalTasks = 0;
  int _completedTasks = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final items = await TaskStorageService.instance.loadItems();
    if (!mounted) return;
    setState(() {
      _totalTasks = items.length;
      _completedTasks =
          items.where((i) => i.task.isDone).length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Avatar + name ────────────────────────────────────────────
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.primaryContainer,
            child: Text(
              'D',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Developer',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'developer@voxpilot.app',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),

          // ── Stats row ────────────────────────────────────────────────
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatPill(
                    value: '$_totalTasks',
                    label: 'Total Tasks',
                    color: cs.primary,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: cs.outlineVariant,
                  ),
                  _StatPill(
                    value: '$_completedTasks',
                    label: 'Completed',
                    color: Colors.green.shade600,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: cs.outlineVariant,
                  ),
                  _StatPill(
                    value: _totalTasks == 0
                        ? '0%'
                        : '${(_completedTasks / _totalTasks * 100).round()}%',
                    label: 'Rate',
                    color: cs.secondary,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          Divider(
            height: 1,
            indent: 24,
            endIndent: 24,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),

          // ── Menu items ───────────────────────────────────────────────
          _MenuItem(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Edit Profile — coming soon'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notification Settings',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Notification Settings — coming soon'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          _MenuItem(
            icon: Icons.color_lens_outlined,
            label: 'Appearance',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Appearance — coming soon'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help & Feedback',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Help & Feedback — coming soon'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            indent: 24,
            endIndent: 24,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            color: cs.error,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Sign Out — coming soon'),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveColor = color ?? cs.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveColor, size: 20),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: effectiveColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurface.withValues(alpha: 0.3),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
