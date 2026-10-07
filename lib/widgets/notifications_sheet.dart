import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';
import 'package:voxpilot/services/task_storage_service.dart';

// ---------------------------------------------------------------------------
// Entry point — call this to show the sheet.
// ---------------------------------------------------------------------------

Future<void> showNotificationsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _NotificationsSheet(),
  );
}

// ---------------------------------------------------------------------------
// Notification item model
// ---------------------------------------------------------------------------

enum _NotifType { completed, added, reminder }

class _NotifItem {
  final String title;
  final String subtitle;
  final _NotifType type;
  final DateTime time;

  const _NotifItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
  });
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  List<_NotifItem> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final items = await TaskStorageService.instance.loadItems();
    final tasks = items.map((i) => i.task).toList();

    final notifs = <_NotifItem>[];

    // Completed tasks → "You completed X"
    final completed =
        tasks.where((t) => t.status == TaskStatus.completed).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final t in completed.take(3)) {
      notifs.add(
        _NotifItem(
          title: 'Task completed',
          subtitle: '"${t.title}" marked as done',
          type: _NotifType.completed,
          time: t.createdAt,
        ),
      );
    }

    // In-progress tasks → "Still working on X"
    final inProgress =
        tasks.where((t) => t.status == TaskStatus.inProgress).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final t in inProgress.take(2)) {
      notifs.add(
        _NotifItem(
          title: 'In progress',
          subtitle: '"${t.title}" is still in progress',
          type: _NotifType.reminder,
          time: t.createdAt,
        ),
      );
    }

    // High-priority pending tasks → reminder
    final highPending =
        tasks
            .where(
              (t) =>
                  t.priority == TaskPriority.high &&
                  t.status == TaskStatus.pending,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final t in highPending.take(2)) {
      notifs.add(
        _NotifItem(
          title: 'High priority pending',
          subtitle: '"${t.title}" hasn\'t been started yet',
          type: _NotifType.reminder,
          time: t.createdAt,
        ),
      );
    }

    // Recently added tasks → "New task added"
    final recent = tasks.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final t in recent.take(2)) {
      notifs.add(
        _NotifItem(
          title: 'Task added',
          subtitle: '"${t.title}" was added to your list',
          type: _NotifType.added,
          time: t.createdAt,
        ),
      );
    }

    // Sort all by time descending and deduplicate by subtitle
    notifs.sort((a, b) => b.time.compareTo(a.time));
    final seen = <String>{};
    final deduped = notifs.where((n) => seen.add(n.subtitle)).take(8).toList();

    if (!mounted) return;
    setState(() {
      _notifs = deduped;
      _loading = false;
    });
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Column(
        children: [
          // ── Handle ─────────────────────────────────────────────────
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

          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: cs.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Notifications', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (_notifs.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifs.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifs.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 68),
                    itemBuilder: (_, i) =>
                        _NotifTile(item: _notifs[i], timeAgo: _timeAgo),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual notification tile
// ---------------------------------------------------------------------------

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  final String Function(DateTime) timeAgo;

  const _NotifTile({required this.item, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (icon, bg, fg) = switch (item.type) {
      _NotifType.completed => (
        Icons.check_circle_rounded,
        Colors.green.shade50,
        Colors.green.shade600,
      ),
      _NotifType.added => (
        Icons.add_circle_rounded,
        cs.primaryContainer,
        cs.onPrimaryContainer,
      ),
      _NotifType.reminder => (
        Icons.alarm_rounded,
        Colors.orange.shade50,
        Colors.orange.shade700,
      ),
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: bg,
        child: Icon(icon, color: fg, size: 20),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timeAgo(item.time),
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: cs.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}
