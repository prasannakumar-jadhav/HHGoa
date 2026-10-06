import 'package:flutter/material.dart';
import 'package:voxpilot/models/task_model.dart';

// ---------------------------------------------------------------------------
// Result object returned when the user submits the form
// ---------------------------------------------------------------------------

class AddTaskResult {
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final String category;
  final TimeOfDay time;

  const AddTaskResult({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
    required this.time,
  });
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

/// Opens a modal bottom sheet styled as a form dialog.
/// Returns an [AddTaskResult] when the user submits, or null if dismissed.
Future<AddTaskResult?> showAddTaskDialog(BuildContext context) {
  return showModalBottomSheet<AddTaskResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _AddTaskSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet content
// ---------------------------------------------------------------------------

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  String _category = 'Work';
  TimeOfDay _time = TimeOfDay.now();

  static const _categories = ['Work', 'Learning', 'Personal'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      AddTaskResult(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        status: _status,
        category: _category,
        time: _time,
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Shift the sheet up when the keyboard is open
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
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

            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_task_rounded,
                    color: cs.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'New Task',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cancel',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'What needs to be done?',
                prefixIcon: const Icon(Icons.title_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerLow,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),

            // ── Description ───────────────────────────────────────────────
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Add more details…',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 14),

            // ── Priority + Status row ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DropdownField<TaskPriority>(
                    label: 'Priority',
                    icon: Icons.flag_rounded,
                    value: _priority,
                    items: TaskPriority.values,
                    labelOf: (p) => p.label,
                    colorOf: (p) => p.color,
                    onChanged: (p) => setState(() => _priority = p),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField<TaskStatus>(
                    label: 'Status',
                    icon: Icons.track_changes_rounded,
                    value: _status,
                    items: TaskStatus.values,
                    labelOf: (s) => s.label,
                    colorOf: (s) => s.color,
                    onChanged: (s) => setState(() => _status = s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Category + Time row ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DropdownField<String>(
                    label: 'Category',
                    icon: Icons.label_outline_rounded,
                    value: _category,
                    items: _categories,
                    labelOf: (c) => c,
                    colorOf: (_) => cs.primary,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(time: _time, onTap: _pickTime),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Submit button ─────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Add Task',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable dropdown field
// ---------------------------------------------------------------------------

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final Color Function(T) colorOf;
  final ValueChanged<T> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.colorOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      selectedItemBuilder: (_) => items
          .map(
            (item) => Text(
              labelOf(item),
              style: TextStyle(
                color: colorOf(item),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
          .toList(),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorOf(item),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(labelOf(item), style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Time picker field
// ---------------------------------------------------------------------------

class _TimeField extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeField({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = time.format(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: cs.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}
