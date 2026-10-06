import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';
import 'package:voxpilot/widgets/task_card.dart';
import 'package:voxpilot/widgets/add_task_dialog.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _TaskItem {
  final Task task;
  final String category;
  _TaskItem({required this.task, required this.category});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Active category filter — null means "All"
  String? _activeCategory;

  static const List<String> _categories = ['Work', 'Learning', 'Personal'];

  final List<_TaskItem> _items = [
    _TaskItem(
      task: Task(
        id: 't1',
        title: 'Refactor auth module',
        description: 'Clean up JWT token validation and refresh logic',
        time: '9:00 AM',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 10, 5, 8, 0),
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't2',
        title: 'Read Clean Code chapter 5',
        description: 'Book study session — formatting and naming conventions',
        time: '11:00 AM',
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 10, 5, 7, 30),
      ),
      category: 'Learning',
    ),
    _TaskItem(
      task: Task(
        id: 't3',
        title: 'Grocery shopping',
        description: 'Weekly groceries — check the list in Notes',
        time: '1:00 PM',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 10, 4, 18, 0),
      ),
      category: 'Personal',
    ),
    _TaskItem(
      task: Task(
        id: 't4',
        title: 'Write API documentation',
        description: 'Document all REST endpoints for the v2 release',
        time: '2:00 PM',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 10, 5, 9, 0),
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't5',
        title: 'Morning workout',
        description: '30 min cardio + stretching',
        time: '7:00 AM',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 10, 5, 6, 0),
      ),
      category: 'Personal',
    ),
    _TaskItem(
      task: Task(
        id: 't6',
        title: 'Review Flutter PR #88',
        description: 'Check UI changes and leave review comments',
        time: '3:00 PM',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 10, 5, 10, 0),
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't7',
        title: 'Study state management',
        description: 'Riverpod deep dive — providers and notifiers',
        time: '5:00 PM',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 10, 5, 11, 0),
      ),
      category: 'Learning',
    ),
    _TaskItem(
      task: Task(
        id: 't8',
        title: 'Call dentist',
        description: 'Schedule bi-annual appointment',
        time: '10:00 AM',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 10, 4, 9, 0),
      ),
      category: 'Personal',
    ),
    _TaskItem(
      task: Task(
        id: 't9',
        title: 'Set up CI/CD pipeline',
        description: 'Configure GitHub Actions for automated deployments',
        time: '4:00 PM',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 10, 5, 13, 0),
      ),
      category: 'Work',
    ),
    _TaskItem(
      task: Task(
        id: 't10',
        title: 'Watch Flutter Forward talks',
        description: 'Review session recordings on new rendering engine',
        time: '6:00 PM',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 10, 5, 15, 0),
      ),
      category: 'Learning',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<_TaskItem> _filtered(TaskStatus? statusFilter) {
    return _items.where((item) {
      final categoryMatch =
          _activeCategory == null || item.category == _activeCategory;
      final statusMatch =
          statusFilter == null || item.task.status == statusFilter;
      return categoryMatch && statusMatch;
    }).toList();
  }

  void _toggleTask(String id) {
    setState(() {
      _items.firstWhere((i) => i.task.id == id).task.toggleDone();
    });
  }

  void _changeStatus(String id, TaskStatus newStatus) {
    setState(() {
      _items.firstWhere((i) => i.task.id == id).task.status = newStatus;
    });
  }

  void _openAddTaskDialog() async {
    final result = await showAddTaskDialog(context);
    if (result == null) return;

    final hour = result.time.hour;
    final minute = result.time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final timeLabel = '$displayHour:$minute $period';

    setState(() {
      _items.add(
        _TaskItem(
          task: Task(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            title: result.title,
            description: result.description,
            time: timeLabel,
            priority: result.priority,
            status: result.status,
            createdAt: DateTime.now(),
          ),
          category: result.category,
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${result.title}" added'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category filter chips
              _CategoryFilterRow(
                categories: _categories,
                active: _activeCategory,
                onSelected: (cat) => setState(() => _activeCategory = cat),
              ),
              // Status tabs
              TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  _buildTab('All', null),
                  _buildTab('In Progress', TaskStatus.inProgress),
                  _buildTab('Completed', TaskStatus.completed),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(
            items: _filtered(null),
            onToggle: _toggleTask,
            onStatusChanged: _changeStatus,
            emptyMessage: 'No tasks yet.',
          ),
          _TaskList(
            items: _filtered(TaskStatus.inProgress),
            onToggle: _toggleTask,
            onStatusChanged: _changeStatus,
            emptyMessage: 'No tasks in progress.',
          ),
          _TaskList(
            items: _filtered(TaskStatus.completed),
            onToggle: _toggleTask,
            onStatusChanged: _changeStatus,
            emptyMessage: 'No completed tasks yet.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }

  Tab _buildTab(String label, TaskStatus? status) {
    final count = _filtered(status).length;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          _CountBadge(count: count),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category filter row
// ---------------------------------------------------------------------------

class _CategoryFilterRow extends StatelessWidget {
  final List<String> categories;
  final String? active;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterRow({
    required this.categories,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: active == null,
              onSelected: (_) => onSelected(null),
              showCheckmark: false,
              selectedColor: cs.primaryContainer,
              labelStyle: TextStyle(
                color: active == null ? cs.onPrimaryContainer : null,
                fontWeight: active == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: active == cat,
                onSelected: (_) => onSelected(active == cat ? null : cat),
                showCheckmark: false,
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(
                  color: active == cat ? cs.onPrimaryContainer : null,
                  fontWeight: active == cat
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task list view
// ---------------------------------------------------------------------------

class _TaskList extends StatelessWidget {
  final List<_TaskItem> items;
  final ValueChanged<String> onToggle;
  final void Function(String id, TaskStatus status) onStatusChanged;
  final String emptyMessage;

  const _TaskList({
    required this.items,
    required this.onToggle,
    required this.onStatusChanged,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TaskCard(
          task: item.task,
          category: item.category,
          onToggle: () => onToggle(item.task.id),
          onStatusChanged: (s) => onStatusChanged(item.task.id, s),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Count badge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}
