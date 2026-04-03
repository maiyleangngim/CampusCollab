import 'dart:io';
import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../models/study_group.dart';
import '../../models/message.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final StudyGroup group;
  const ChatDetailScreen({super.key, required this.group});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText(String text) async {
    await _firestore.sendTextMessage(widget.group.id, text);
    _scrollToBottom();
  }

  Future<void> _sendImage(File file) async {
    try {
      final url = await _storage.uploadChatImage(widget.group.id, file);
      await _firestore.sendImageMessage(widget.group.id, url);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send image: $e'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Color get _templateColor {
    if (widget.group.template == 'exam_prep') return const Color(0xFF7C3AED);
    if (widget.group.template == 'assignment') return const Color(0xFFF97316);
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _templateColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_outlined, color: _templateColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.group.memberCount} members',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: AppTheme.primary),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.groupDetail,
              arguments: widget.group,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Quick Action Bar ──────────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.checklist_outlined,
                  label: 'Tasks',
                  color: AppTheme.primary,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.groupTasks,
                    arguments: widget.group,
                  ),
                ),
                _ActionButton(
                  icon: Icons.folder_outlined,
                  label: 'Resources',
                  color: const Color(0xFF059669),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.resourceVault,
                    arguments: widget.group,
                  ),
                ),
                _ActionButton(
                  icon: Icons.timer_outlined,
                  label: 'Pomodoro',
                  color: const Color(0xFFDC2626),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.pomodoro,
                    arguments: widget.group,
                  ),
                ),
                _ActionButton(
                  icon: Icons.people_outline,
                  label: 'Members',
                  color: const Color(0xFF7C3AED),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.groupDetail,
                    arguments: widget.group,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // ── Messages ──────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _firestore.messagesStream(widget.group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No messages yet',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Say hello to your group!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  );
                }
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      MessageBubble(message: messages[index]),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          ChatInputBar(
            onSend: _sendText,
            onImagePick: _sendImage,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}




