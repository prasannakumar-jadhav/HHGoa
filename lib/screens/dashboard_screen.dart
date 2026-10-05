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
    ),
    Task(
      id: '2',
      title: 'Code review PR #42',
      description: 'Flutter dashboard PR',
      time: '10:30 AM',
      priority: TaskPriority.medium,
    ),
    Task(
      id: '3',
      title: 'Fix authentication bug',
      description: 'JWT token expiry issue',
      time: '12:00 PM',
      priority: TaskPriority.high,
    ),
    Task(
      id: '4',
      title: 'Write unit tests',
      description: 'Cover auth module',
      time: '2:00 PM',
      priority: TaskPriority.medium,
    ),
    Task(
      id: '5',
      title: 'Update API documentation',
      description: 'Swagger docs for v2',
      time: '3:30 PM',
      priority: TaskPriority.low,
    ),
    Task(
      id: '6',
      title: 'Deploy to staging',
      description: 'Push release candidate',
      time: '5:00 PM',
      priority: TaskPriority.low,
    ),
  ];

  void _toggleTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isDone = !task.isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.mic),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: theme.colorScheme.primaryContainer,
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.mic, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VoxPilot',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'AI Developer Companion',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
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
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const WelcomeBanner(),
                  const SizedBox(height: 20),
                  StatsRow(tasks: _tasks),
                  const SizedBox(height: 20),
                  const QuickActionsCard(),
                  const SizedBox(height: 20),
                  TodaysTasksSection(tasks: _tasks, onToggle: _toggleTask),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
