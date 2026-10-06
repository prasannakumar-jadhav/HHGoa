import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';
import 'package:voxpilot/services/task_storage_service.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  bool _loading = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadTasks();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final items = await TaskStorageService.instance.loadItems();
    if (!mounted) return;
    setState(() {
      _tasks = items.map((i) => i.task).toList();
      _loading = false;
    });
    _animCtrl.forward(from: 0);
  }

  // ── Derived stats ─────────────────────────────────────────────────────────

  int get _total => _tasks.length;
  int get _completed =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get _pending =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get _inProgress =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  double get _completionRate => _total == 0 ? 0.0 : _completed / _total;

  int get _highPriority =>
      _tasks.where((t) => t.priority == TaskPriority.high).length;
  int get _medPriority =>
      _tasks.where((t) => t.priority == TaskPriority.medium).length;
  int get _lowPriority =>
      _tasks.where((t) => t.priority == TaskPriority.low).length;

  List<Task> get _recentCompleted =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pct = (_completionRate * 100).round();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Insights',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _loading = true);
              _loadTasks();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── A: Completion hero ──────────────────────────────────
              _CompletionHeroCard(
                total: _total,
                completed: _completed,
                pct: pct,
                progressAnim: _progressAnim,
                completionRate: _completionRate,
              ),

              const SizedBox(height: 24),

              // ── B: Stat grid ─────────────────────────────────────────
              _SectionHeader(label: 'Overview'),
              const SizedBox(height: 12),
              _StatGrid(
                total: _total,
                completed: _completed,
                pending: _pending,
                inProgress: _inProgress,
              ),

              const SizedBox(height: 24),

              // ── C: Animated progress bar ─────────────────────────────
              _SectionHeader(label: 'Completion Progress'),
              const SizedBox(height: 12),
              _CompletionProgressCard(
                pct: pct,
                completed: _completed,
                total: _total,
                progressAnim: _progressAnim,
                completionRate: _completionRate,
              ),

              const SizedBox(height: 24),

              // ── D: Priority distribution ─────────────────────────────
              _SectionHeader(label: 'Priority Distribution'),
              const SizedBox(height: 12),
              _PriorityDistributionCard(
                high: _highPriority,
                medium: _medPriority,
                low: _lowPriority,
                total: _total,
                progressAnim: _progressAnim,
              ),

              const SizedBox(height: 24),

              // ── E: Status breakdown ───────────────────────────────────
              _SectionHeader(label: 'Status Breakdown'),
              const SizedBox(height: 12),
              _StatusBreakdownCard(
                completed: _completed,
                inProgress: _inProgress,
                pending: _pending,
                total: _total,
                progressAnim: _progressAnim,
              ),

              const SizedBox(height: 24),

              // ── F: Recent completed tasks ─────────────────────────────
              _SectionHeader(label: 'Recently Completed'),
              const SizedBox(height: 12),
              _RecentActivityCard(
                tasks: _recentCompleted.take(5).toList(),
                timeAgo: _timeAgo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

// ---------------------------------------------------------------------------
// A: Completion hero card with circular arc
// ---------------------------------------------------------------------------

class _CompletionHeroCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pct;
  final Animation<double> progressAnim;
  final double completionRate;

  const _CompletionHeroCard({
    required this.total,
    required this.completed,
    required this.pct,
    required this.progressAnim,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.tertiary],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Circular progress dial
            AnimatedBuilder(
              animation: progressAnim,
              builder: (_, _) => CustomPaint(
                size: const Size(100, 100),
                painter: _CircularProgressPainter(
                  progress: completionRate * progressAnim.value,
                  trackColor: Colors.white.withValues(alpha: 0.2),
                  progressColor: Colors.white,
                  strokeWidth: 9,
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(pct * progressAnim.value).round()}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'done',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Text summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total == 0 ? 'No tasks yet' : 'Great progress!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completed of $total tasks completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? 'Add your first task to get started'
                        : pct >= 80
                        ? 'Outstanding work! 🎉'
                        : pct >= 50
                        ? 'More than halfway there!'
                        : 'Keep going, you can do it!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
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

// ---------------------------------------------------------------------------
// B: 2×2 stat grid
// ---------------------------------------------------------------------------

class _StatGrid extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;
  final int inProgress;

  const _StatGrid({
    required this.total,
    required this.completed,
    required this.pending,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.format_list_bulleted_rounded,
          value: '$total',
          label: 'Total Tasks',
          color: cs.primary,
        ),
        _StatCard(
          icon: Icons.check_circle_rounded,
          value: '$completed',
          label: 'Completed',
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.radio_button_unchecked_rounded,
          value: '$pending',
          label: 'Pending',
          color: Colors.grey,
        ),
        _StatCard(
          icon: Icons.timelapse_rounded,
          value: '$inProgress',
          label: 'In Progress',
          color: cs.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// C: Animated completion progress bar card
// ---------------------------------------------------------------------------

class _CompletionProgressCard extends StatelessWidget {
  final int pct;
  final int completed;
  final int total;
  final Animation<double> progressAnim;
  final double completionRate;

  const _CompletionProgressCard({
    required this.pct,
    required this.completed,
    required this.total,
    required this.progressAnim,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Completion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedBuilder(
                  animation: progressAnim,
                  builder: (_, _) => Text(
                    '${(pct * progressAnim.value).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: progressAnim,
              builder: (_, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionRate * progressAnim.value,
                  minHeight: 14,
                  backgroundColor: cs.primaryContainer.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProgressLegend(
                  color: cs.primary,
                  label: '$completed completed',
                ),
                _ProgressLegend(
                  color: cs.onSurface.withValues(alpha: 0.3),
                  label: '${total - completed} remaining',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ProgressLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// D: Priority distribution
// ---------------------------------------------------------------------------

class _PriorityDistributionCard extends StatelessWidget {
  final int high;
  final int medium;
  final int low;
  final int total;
  final Animation<double> progressAnim;

  const _PriorityDistributionCard({
    required this.high,
    required this.medium,
    required this.low,
    required this.total,
    required this.progressAnim,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = [
      (label: 'High', count: high, color: Colors.red.shade600),
      (label: 'Medium', count: medium, color: Colors.orange.shade600),
      (label: 'Low', count: low, color: Colors.green.shade600),
    ];

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: items.map((item) {
            final fraction = total == 0 ? 0.0 : item.count / total;
            final pct = (fraction * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${item.count} tasks · $pct%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: progressAnim,
                    builder: (_, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fraction * progressAnim.value,
                        minHeight: 10,
                        backgroundColor: item.color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E: Status breakdown
// ---------------------------------------------------------------------------

class _StatusBreakdownCard extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int pending;
  final int total;
  final Animation<double> progressAnim;

  const _StatusBreakdownCard({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.total,
    required this.progressAnim,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = [
      (
        label: 'Completed',
        count: completed,
        color: Colors.green.shade600,
        icon: Icons.check_circle_rounded,
      ),
      (
        label: 'In Progress',
        count: inProgress,
        color: cs.primary,
        icon: Icons.timelapse_rounded,
      ),
      (
        label: 'Pending',
        count: pending,
        color: Colors.grey.shade500,
        icon: Icons.radio_button_unchecked_rounded,
      ),
    ];

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: items.map((item) {
            final fraction = total == 0 ? 0.0 : item.count / total;
            final pct = (fraction * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(item.icon, size: 18, color: item.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${item.count} ($pct%)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: progressAnim,
                          builder: (_, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction * progressAnim.value,
                              minHeight: 7,
                              backgroundColor: item.color.withValues(
                                alpha: 0.12,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                item.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// F: Recent completed tasks
// ---------------------------------------------------------------------------

class _RecentActivityCard extends StatelessWidget {
  final List<Task> tasks;
  final String Function(DateTime) timeAgo;

  const _RecentActivityCard({required this.tasks, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (tasks.isEmpty) {
      return Card(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No completed tasks yet.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.45)),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Column(
        children: tasks.asMap().entries.map((entry) {
          final idx = entry.key;
          final task = entry.value;
          final isLast = idx == tasks.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green.shade50,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ),
                title: Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: task.priority.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${task.priority.label} · ${timeAgo(task.createdAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: cs.onSurface.withValues(alpha: 0.35),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom circular progress painter
// ---------------------------------------------------------------------------

class _CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // top
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, trackPaint);
    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) => old.progress != progress;
}
