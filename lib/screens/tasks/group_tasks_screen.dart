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
    await FirestoreService().addTask(widget.groupId, title);
    _taskCtrl.clear();
    if (mounted) setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0.5,
        leading: const BackButton(color: AppTheme.primary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Group Tasks', style: AppTheme.titleStyle),
            Text(widget.groupName,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Add task bar ──────────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _adding ? null : _addTask,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _adding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // ── Task list ─────────────────────────────────────────────────────
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
                        Icon(Icons.checklist_outlined, size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('No tasks yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Add one above to get started', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                }
                final pending = tasks.where((t) => !t.isCompleted).toList();
                final done = tasks.where((t) => t.isCompleted).toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _sectionLabel('TO DO (${pending.length})'),
                      const SizedBox(height: 8),
                      ...pending.map((t) => _TaskTile(task: t, groupId: widget.groupId)),
                      const SizedBox(height: 20),
                    ],
                    if (done.isNotEmpty) ...[
                      _sectionLabel('DONE (${done.length})'),
                      const SizedBox(height: 8),
                      ...done.map((t) => _TaskTile(task: t, groupId: widget.groupId)),
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
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.2));
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final String groupId;

  const _TaskTile({required this.task, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => FirestoreService().toggleTask(groupId, task.id, !task.isCompleted),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted ? AppTheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? AppTheme.primary : AppTheme.textSecondary,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: task.dueDate != null
            ? Text(
                'Due ${_formatDate(task.dueDate!)}',
                style: TextStyle(
                    fontSize: 11,
                    color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                        ? Colors.red
                        : AppTheme.textSecondary),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary, size: 20),
          onPressed: () => FirestoreService().deleteTask(groupId, task.id),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}
