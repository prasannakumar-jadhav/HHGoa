import 'package:flutter/material.dart';
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

  /// Reload whenever the app resumes from background.
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
    // Write the updated status back to storage.
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

    // Add to storage first, then reload so both screens stay in sync.
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

    // Today's tasks = all non-completed tasks (pending + in-progress)
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
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // ── App bar ───────────────────────────────────────────
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: false,
                    backgroundColor: cs.primaryContainer,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    titleSpacing: 16,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            color: cs.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VoxPilot',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'AI Developer Companion',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: cs.onPrimaryContainer,
                          size: 22,
                        ),
                        onPressed: () => showNotificationsSheet(context),
                        tooltip: 'Notifications',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: GestureDetector(
                          onTap: () => showProfileSheet(context),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: cs.primary,
                            child: Text(
                              'D',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ── Content ───────────────────────────────────────────
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
      ),
    );
  }
}
