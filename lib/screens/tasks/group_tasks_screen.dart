import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/task.dart';
import '../../services/firestore_service.dart';

class GroupTasksScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupTasksScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupTasksScreen> createState() => _GroupTasksScreenState();
}

class _GroupTasksScreenState extends State<GroupTasksScreen> {
  final _taskCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _adding = true);
    await FirestoreService().addTask(widget.groupId, title: title);
    _taskCtrl.clear();
    if (mounted) setState(() => _adding = false);
  }

  void _openAddSheet() {
    final prefill = _taskCtrl.text.trim();
    if (prefill.isNotEmpty) _taskCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => _TaskDetailSheet(
        groupId: widget.groupId,
        prefillTitle: prefill,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        leading: const BackButton(color: AppTheme.primary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group Tasks',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4)),
            Text(
              widget.groupName,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Add task bar ────────────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskCtrl,
                    decoration: InputDecoration(
                      hintText: 'Quick add a task...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                    ),
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    onSubmitted: (_) => _addTask(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                // Advanced add (tune icon)
                GestureDetector(
                  onTap: _openAddSheet,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                // Quick add (+)
                GestureDetector(
                  onTap: _adding ? null : _addTask,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: _adding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // ── Task list ───────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: FirestoreService().tasksStream(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checklist_outlined,
                            size: 56,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No tasks yet',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Add one above to get started',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }
                final pending =
                    tasks.where((t) => !t.isCompleted).toList();
                final done =
                    tasks.where((t) => t.isCompleted).toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _sectionLabel('TO DO (${pending.length})'),
                      const SizedBox(height: 8),
                      ...pending.map(
                          (t) => _TaskTile(task: t, groupId: widget.groupId)),
                      const SizedBox(height: 20),
                    ],
                    if (done.isNotEmpty) ...[
                      _sectionLabel('DONE (${done.length})'),
                      const SizedBox(height: 8),
                      ...done.map(
                          (t) => _TaskTile(task: t, groupId: widget.groupId)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2));
  }
}

// ── TASK TILE ──────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final Task task;
  final String groupId;

  const _TaskTile({required this.task, required this.groupId});

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return AppTheme.error;
      case 'medium':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Med';
      default:
        return 'Low';
    }
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => _TaskDetailSheet(groupId: groupId, existingTask: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: InkWell(
        onTap: () => _openEditSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => FirestoreService()
                    .toggleTask(groupId, task.id, !task.isCompleted),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppTheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 13)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    ],
                    if (task.priority != null || task.dueDate != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (task.priority != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _priorityColor(task.priority!)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                              ),
                              child: Text(
                                _priorityLabel(task.priority!),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _priorityColor(task.priority!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (task.dueDate != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 11,
                                  color: isOverdue
                                      ? AppTheme.error
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _formatDate(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOverdue
                                        ? AppTheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Delete
              GestureDetector(
                onTap: () => FirestoreService().deleteTask(groupId, task.id),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.delete_outline,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

// ── TASK DETAIL SHEET ──────────────────────────────────────────────────────────

class _TaskDetailSheet extends StatefulWidget {
  final String groupId;
  final Task? existingTask;
  final String? prefillTitle;

  const _TaskDetailSheet({
    required this.groupId,
    this.existingTask,
    this.prefillTitle,
  });

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String? _priority;
  DateTime? _dueDate;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleCtrl =
        TextEditingController(text: task?.title ?? widget.prefillTitle ?? '');
    _descCtrl = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final svc = FirestoreService();
      final desc =
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
      if (_isEdit) {
        final old = widget.existingTask!;
        await svc.updateTask(
          widget.groupId,
          old.id,
          title: title,
          description: desc,
          clearDescription: desc == null,
          priority: _priority,
          clearPriority: _priority == null,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        );
      } else {
        await svc.addTask(
          widget.groupId,
          title: title,
          description: desc,
          priority: _priority,
          dueDate: _dueDate,
        );
      }
      nav.pop();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              behavior: SnackBarBehavior.floating),
        );
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirestoreService()
          .deleteTask(widget.groupId, widget.existingTask!.id);
      nav.pop();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              behavior: SnackBarBehavior.floating),
        );
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                _isEdit ? 'Edit Task' : 'Add Task Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleCtrl,
            autofocus: !_isEdit,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Task title *',
              labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Description (optional)',
              hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 14),

          // Priority
          Text('Priority',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              _PriorityChip(
                label: 'Low',
                selected: _priority == 'low',
                color: AppTheme.success,
                onTap: () => setState(
                    () => _priority = _priority == 'low' ? null : 'low'),
              ),
              const SizedBox(width: 8),
              _PriorityChip(
                label: 'Medium',
                selected: _priority == 'medium',
                color: AppTheme.warning,
                onTap: () => setState(() =>
                    _priority = _priority == 'medium' ? null : 'medium'),
              ),
              const SizedBox(width: 8),
              _PriorityChip(
                label: 'High',
                selected: _priority == 'high',
                color: AppTheme.error,
                onTap: () => setState(
                    () => _priority = _priority == 'high' ? null : 'high'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Due date
          Text('Deadline',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16,
                      color: _dueDate != null
                          ? AppTheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _dueDate != null
                          ? _fmtDate(_dueDate!)
                          : 'No deadline (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _dueDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _dueDate = null),
                      child: Icon(Icons.close,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              if (_isEdit) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _delete,
                    icon: _deleting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.error))
                        : const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: _isEdit ? 2 : 1,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isEdit ? 'Save Changes' : 'Add Task',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── PRIORITY CHIP ──────────────────────────────────────────────────────────────

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: selected
                ? color
                : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? color
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
