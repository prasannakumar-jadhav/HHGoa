import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';
import 'package:voxpilot/widgets/welcome_banner.dart';
import 'package:voxpilot/widgets/stats_row.dart';
import 'package:voxpilot/widgets/quick_actions_card.dart';
import 'package:voxpilot/widgets/todays_tasks_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Design system architecture',
      description: 'Plan microservices layout',
      time: '9:00 AM',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      createdAt: DateTime(2026, 10, 5, 8, 45),
    ),
    Task(
      id: '2',
      title: 'Code review PR #42',
      description: 'Flutter dashboard PR',
      time: '10:30 AM',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime(2026, 10, 5, 9, 0),
    ),
    Task(
      id: '3',
      title: 'Fix authentication bug',
      description: 'JWT token expiry issue',
      time: '12:00 PM',
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      createdAt: DateTime(2026, 10, 4, 14, 0),
    ),
    Task(
      id: '4',
      title: 'Write unit tests',
      description: 'Cover auth module',
      time: '2:00 PM',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime(2026, 10, 5, 10, 0),
    ),
    Task(
      id: '5',
      title: 'Update API documentation',
      description: 'Swagger docs for v2',
      time: '3:30 PM',
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      createdAt: DateTime(2026, 10, 5, 11, 0),
    ),
    Task(
      id: '6',
      title: 'Deploy to staging',
      description: 'Push release candidate',
      time: '5:00 PM',
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      createdAt: DateTime(2026, 10, 4, 17, 0),
    ),
  ];

  void _toggleTask(String id) {
    setState(() => _tasks.firstWhere((t) => t.id == id).toggleDone());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.mic_rounded),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
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
                          color: cs.onPrimaryContainer.withValues(alpha: 0.7),
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
                  onPressed: () {},
                  tooltip: 'Notifications',
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
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
              ],
            ),
            // ── Content ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const WelcomeBanner(),
                  const SizedBox(height: 20),
                  StatsRow(tasks: _tasks),
                  const SizedBox(height: 16),
                  const QuickActionsCard(),
                  const SizedBox(height: 20),
                  TodaysTasksSection(tasks: _tasks, onToggle: _toggleTask),
                  // Bottom padding for FAB clearance
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
