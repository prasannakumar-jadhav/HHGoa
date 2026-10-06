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

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _activeCategory; // null = all categories
  TaskStatus? _activeStatus; // null = all statuses

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

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// All items matching the current search query + category + status filters.
  List<_TaskItem> get _filtered => _applyFilters(_activeStatus);

  /// Count of items matching a specific [status] (plus search + category).
  int _countFor(TaskStatus? status) => _applyFilters(status).length;

  List<_TaskItem> _applyFilters(TaskStatus? status) {
    final query = _searchQuery.toLowerCase().trim();
    return _items.where((item) {
      final categoryMatch =
          _activeCategory == null || item.category == _activeCategory;
      final statusMatch = status == null || item.task.status == status;
      final searchMatch =
          query.isEmpty ||
          item.task.title.toLowerCase().contains(query) ||
          item.task.description.toLowerCase().contains(query);
      return categoryMatch && statusMatch && searchMatch;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _toggleTask(String id) {
    setState(() => _items.firstWhere((i) => i.task.id == id).task.toggleDone());
  }

  void _changeStatus(String id, TaskStatus newStatus) {
    setState(
      () => _items.firstWhere((i) => i.task.id == id).task.status = newStatus,
    );
  }

  Future<void> _deleteTask(String id) async {
    final item = _items.firstWhere((i) => i.task.id == id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(ctx).colorScheme.error,
          size: 32,
        ),
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${item.task.title}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _items.removeWhere((i) => i.task.id == id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.task.title}" deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAddTaskDialog() async {
    final result = await showAddTaskDialog(context);
    if (result == null) return;
    final h = result.time.hour;
    final m = result.time.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    setState(() {
      _items.add(
        _TaskItem(
          task: Task(
            id: 't${DateTime.now().millisecondsSinceEpoch}',
            title: result.title,
            description: result.description,
            time: '$displayH:$m $period',
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search field ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by title or description…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            tooltip: 'Clear',
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: cs.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              // ── Filter chips ─────────────────────────────────────────
              _FilterChipRow(
                categories: _categories,
                activeCategory: _activeCategory,
                activeStatus: _activeStatus,
                onCategorySelected: (c) => setState(() => _activeCategory = c),
                onStatusSelected: (s) => setState(() => _activeStatus = s),
                countFor: _countFor,
              ),
            ],
          ),
        ),
      ),
      body: _TaskList(
        items: _filtered,
        onToggle: _toggleTask,
        onStatusChanged: _changeStatus,
        onDelete: _deleteTask,
        emptyMessage: _searchQuery.isNotEmpty
            ? 'No tasks match "$_searchQuery".'
            : 'No tasks found.',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row — status (All/Pending/In Progress/Completed) + categories
// ---------------------------------------------------------------------------

class _FilterChipRow extends StatelessWidget {
  final List<String> categories;
  final String? activeCategory;
  final TaskStatus? activeStatus;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<TaskStatus?> onStatusSelected;
  final int Function(TaskStatus?) countFor;

  const _FilterChipRow({
    required this.categories,
    required this.activeCategory,
    required this.activeStatus,
    required this.onCategorySelected,
    required this.onStatusSelected,
    required this.countFor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Status filter definitions: (TaskStatus?, label, icon)
    const statusFilters = [
      (null, 'All', Icons.all_inbox_rounded),
      (TaskStatus.pending, 'Pending', Icons.radio_button_unchecked),
      (TaskStatus.inProgress, 'In Progress', Icons.timelapse),
      (TaskStatus.completed, 'Completed', Icons.check_circle_outline),
    ];

    // Category colors
    const categoryColors = {
      'Work': Colors.indigo,
      'Learning': Colors.purple,
      'Personal': Colors.teal,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // ── Status filter chips ───────────────────────────────────────
          ...statusFilters.map((entry) {
            final status = entry.$1;
            final label = entry.$2;
            final icon = entry.$3;
            final count = countFor(status);
            final selected = activeStatus == status;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? cs.onPrimaryContainer
                      : cs.onSurface.withValues(alpha: 0.55),
                ),
                label: Text('$label  $count'),
                selected: selected,
                onSelected: (_) => onStatusSelected(selected ? null : status),
                showCheckmark: false,
                selectedColor: cs.primaryContainer,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? cs.onPrimaryContainer : null,
                ),
              ),
            );
          }),

          // ── Divider ───────────────────────────────────────────────────
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            color: cs.outlineVariant,
          ),

          // ── Category chips ────────────────────────────────────────────
          ...categories.map((cat) {
            final selected = activeCategory == cat;
            final color = categoryColors[cat] ?? Colors.blueGrey;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) => onCategorySelected(selected ? null : cat),
                showCheckmark: false,
                selectedColor: Color.alphaBlend(
                  (color as Color).withValues(alpha: 0.25),
                  cs.surface,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? color : null,
                ),
              ),
            );
          }),
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
  final void Function(String id) onDelete;
  final String emptyMessage;

  const _TaskList({
    required this.items,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onDelete,
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
              Icons.search_off_rounded,
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
              textAlign: TextAlign.center,
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
          onDelete: () => onDelete(item.task.id),
        );
      },
    );
  }
}
