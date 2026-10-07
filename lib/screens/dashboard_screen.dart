import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voxpilot/models/task_model.dart';
import 'package:voxpilot/services/task_storage_service.dart';
import 'package:voxpilot/widgets/add_task_dialog.dart';
import 'package:voxpilot/widgets/notifications_sheet.dart';
import 'package:voxpilot/widgets/profile_sheet.dart';
import 'package:voxpilot/widgets/voice_input_sheet.dart';
import 'package:voxpilot/widgets/ai_assist_sheet.dart';
import 'package:voxpilot/widgets/welcome_banner.dart';
import 'package:voxpilot/widgets/stats_row.dart';
import 'package:voxpilot/widgets/quick_actions_card.dart';
import 'package:voxpilot/widgets/todays_tasks_section.dart';

// ── App bar header height ──────────────────────────────────────────────────
const double _kHeaderHeight = 230.0;

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTasks;
  final VoidCallback? onNavigateToInsights;

  const DashboardScreen({
    super.key,
    this.onNavigateToTasks,
    this.onNavigateToInsights,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  List<Task> _tasks = [];
  bool _loading = true;

  final _storage = TaskStorageService.instance;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadTasks();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadTasks() async {
    final items = await _storage.loadItems();
    if (!mounted) return;
    setState(() {
      _tasks = items.map((i) => i.task).toList();
      _loading = false;
    });
  }

  Future<void> _toggleTask(String id) async {
    setState(() => _tasks.firstWhere((t) => t.id == id).toggleDone());
    final items = await _storage.loadItems();
    final updated = items.map((i) {
      if (i.task.id == id) {
        return (
          task: _tasks.firstWhere((t) => t.id == id),
          category: i.category,
        );
      }
      return i;
    }).toList();
    await _storage.saveItems(updated);
  }

  Future<void> _openAddTaskDialog() async {
    final result = await showAddTaskDialog(context);
    if (result == null) return;

    final h = result.time.hour;
    final m = result.time.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;

    final newTask = Task(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      title: result.title,
      description: result.description,
      time: '$displayH:$m $period',
      priority: result.priority,
      status: result.status,
      createdAt: DateTime.now(),
    );

    final existing = await _storage.loadItems();
    await _storage.saveItems([
      ...existing,
      (task: newTask, category: result.category),
    ]);
    await _loadTasks();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${result.title}" added'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final todaysTasks = _tasks
        .where((t) => t.status != TaskStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskDialog,
        icon: const Icon(Icons.mic_rounded),
        label: const Text('Add Task'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Image header AppBar ────────────────────────────────
                SliverPersistentHeader(
                  pinned: false,
                  floating: false,
                  delegate: _ImageHeaderDelegate(
                    onNotifications: () => showNotificationsSheet(context),
                    onProfile: () => showProfileSheet(context),
                  ),
                ),

                // ── Content — unchanged ────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      WelcomeBanner(pendingCount: todaysTasks.length),
                      const SizedBox(height: 20),
                      StatsRow(tasks: _tasks),
                      const SizedBox(height: 16),
                      QuickActionsCard(
                        onNewTask: _openAddTaskDialog,
                        onVoice: () => showVoiceInputSheet(context),
                        onAiAssist: () => showAiAssistSheet(context),
                        onAnalytics: widget.onNavigateToInsights,
                      ),
                      const SizedBox(height: 20),
                      TodaysTasksSection(
                        tasks: todaysTasks,
                        onToggle: _toggleTask,
                        onSeeAll: widget.onNavigateToTasks,
                      ),
                      const SizedBox(height: 88),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image header delegate
// Renders a full-bleed background image with:
//  - dark gradient overlay
//  - top action bar (icon + name + notification + avatar)
//  - large greeting + tagline bottom-left
//  - rounded white scoop at the bottom edge
// ---------------------------------------------------------------------------

class _ImageHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _ImageHeaderDelegate({
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  double get minExtent => _kHeaderHeight;
  @override
  double get maxExtent => _kHeaderHeight;

  @override
  bool shouldRebuild(_ImageHeaderDelegate old) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Background image ─────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ── Gradient overlay ─────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xBB000000), // stronger at top for readability
                    Color(0x55000000), // lighter at bottom
                  ],
                ),
              ),
            ),
          ),

          // ── Rounded white scoop at the bottom ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
            ),
          ),

          // ── Top action bar ───────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            left: 16,
            right: 12,
            child: Row(
              children: [
                // App icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/voxpilot_logo.svg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // App name + tagline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VoxPilot',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 25,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'AI Developer Companion',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Notification bell
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: onNotifications,
                    tooltip: 'Notifications',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 8),
                // Avatar
                GestureDetector(
                  onTap: onProfile,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    child: Text(
                      'D',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
  }
}
