import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../models/chat_folder.dart';
import '../../models/study_group.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/group_chat_card.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // null = 'All', 'unread' = Unread, otherwise a folder id
  String? _activeFolderId;
  final FirestoreService _firestore = FirestoreService();

  void _openCreateGroup() async {
    final result = await Navigator.pushNamed(context, AppRoutes.createGroup);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group created! It will appear in your chats.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showJoinByCode() {
    final codeCtrl = TextEditingController();
    bool joining = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Join by Invite Code',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Enter the 8-character code shared by a group member.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    color: AppTheme.primary),
                decoration: InputDecoration(
                  hintText: 'ABC12345',
                  hintStyle: const TextStyle(
                      color: AppTheme.textSecondary, letterSpacing: 4, fontSize: 18),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: joining
                      ? null
                      : () async {
                          final code = codeCtrl.text.trim();
                          if (code.length != 8) return;
                          setModal(() => joining = true);
                          try {
                            await FirestoreService().joinGroupByCode(code);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Joined group successfully!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            setModal(() => joining = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: joining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Join Group',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Add a Group',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ),
              const SizedBox(height: 16),
              _MenuItem(
                icon: Icons.group_add_outlined,
                iconBg: Color(0xFFE8F0FE),
                iconColor: Color(0xFF1A73E8),
                label: 'Create New Group',
                subtitle: 'Start a study group for your course',
                onTap: () {
                  Navigator.pop(ctx);
                  _openCreateGroup();
                },
              ),
              const SizedBox(height: 10),
              _MenuItem(
                icon: Icons.vpn_key_outlined,
                iconBg: Color(0xFFFFF3E0),
                iconColor: Color(0xFFF57C00),
                label: 'Join by Invite Code',
                subtitle: 'Enter an 8-character code to join',
                onTap: () {
                  Navigator.pop(ctx);
                  _showJoinByCode();
                },
              ),
              const SizedBox(height: 10),
              _MenuItem(
                icon: Icons.explore_outlined,
                iconBg: Color(0xFFE8F5E9),
                iconColor: Color(0xFF2E7D32),
                label: 'Browse Groups',
                subtitle: 'Discover public groups to join',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.discover);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFolder() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Folder',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Folder name',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await _firestore.createFolder(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(ChatFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Folder',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        content: Text(
            'Delete "${folder.name}"? Groups inside won\'t be removed.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              await _firestore.deleteFolder(folder.id);
              if (mounted) setState(() => _activeFolderId = null);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddToFolder(StudyGroup group, List<ChatFolder> folders) {
    if (folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Create a folder first using the + chip.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Create',
            onPressed: _showCreateFolder,
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add "${group.name}" to folder',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              ...folders.map((folder) {
                final inFolder = folder.groupIds.contains(group.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: inFolder
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      inFolder ? Icons.folder : Icons.folder_outlined,
                      color: inFolder
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(folder.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: inFolder
                              ? AppTheme.primary
                              : AppTheme.textPrimary)),
                  trailing: inFolder
                      ? const Icon(Icons.check_circle,
                          color: AppTheme.primary, size: 20)
                      : null,
                  onTap: () async {
                    if (inFolder) {
                      await _firestore.removeGroupFromFolder(
                          folder.id, group.id);
                    } else {
                      await _firestore.addGroupToFolder(folder.id, group.id);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatFolder>>(
      stream: _firestore.foldersStream(),
      builder: (context, folderSnap) {
        final folders = folderSnap.data ?? [];

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0.5,
            title: const Text('Chats',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textPrimary),
                onPressed: () {},
              ),
              IconButton(
                icon:
                    const Icon(Icons.edit_outlined, color: AppTheme.textPrimary),
                onPressed: _showCreateMenu,
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Filter chips ────────────────────────────────────────────────
              Container(
                color: AppTheme.background,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Fixed: All
                      _FilterChip(
                        label: 'All',
                        active: _activeFolderId == null,
                        onTap: () =>
                            setState(() => _activeFolderId = null),
                      ),
                      const SizedBox(width: 8),

                      // Dynamic folders
                      ...folders.map((folder) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onLongPress: () =>
                                  _confirmDeleteFolder(folder),
                              child: _FilterChip(
                                label: folder.name,
                                icon: Icons.folder_outlined,
                                active: _activeFolderId == folder.id,
                                onTap: () => setState(
                                    () => _activeFolderId = folder.id),
                              ),
                            ),
                          )),

                      // + New folder
                      GestureDetector(
                        onTap: _showCreateFolder,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.divider,
                                style: BorderStyle.solid),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 15, color: AppTheme.textSecondary),
                              SizedBox(width: 4),
                              Text('New Folder',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Group list ──────────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<StudyGroup>>(
                  stream: _firestore.myGroupsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allGroups = snapshot.data ?? [];

                    // Filter by active folder
                    final activeFolder = _activeFolderId == null
                        ? null
                        : folders
                            .where((f) => f.id == _activeFolderId)
                            .firstOrNull;
                    final groups = activeFolder == null
                        ? allGroups
                        : allGroups
                            .where((g) =>
                                activeFolder.groupIds.contains(g.id))
                            .toList();

                    if (allGroups.isEmpty) {
                      return _EmptyState(
                        onCreateGroup: _openCreateGroup,
                        onJoinByCode: _showJoinByCode,
                        onBrowse: () =>
                            Navigator.pushNamed(context, AppRoutes.discover),
                      );
                    }

                    if (groups.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_open,
                                size: 48,
                                color: AppTheme.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No groups in "${activeFolder?.name}"',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Long-press a group chat to add it here.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const Divider(
                          height: 1, indent: 72, color: AppTheme.divider),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Container(
                          color: AppTheme.surface,
                          child: GroupChatCard(
                            group: group,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChatDetailScreen(group: group)),
                            ),
                            onLongPress: () =>
                                _showAddToFolder(group, folders),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateMenu,
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppTheme.primary : AppTheme.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: active ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppTheme.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinByCode;
  final VoidCallback onBrowse;

  const _EmptyState({
    required this.onCreateGroup,
    required this.onJoinByCode,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          // ── Illustration ───────────────────────────────────────────────
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_outlined,
                size: 48, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('No study groups yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Create a group, join one with an invite\ncode, or browse public groups.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),

          // ── Action cards ───────────────────────────────────────────────
          _ActionCard(
            icon: Icons.group_add_outlined,
            iconBg: const Color(0xFFE8F0FE),
            iconColor: const Color(0xFF1A73E8),
            label: 'Create a New Group',
            subtitle: 'Set up a study group for your course',
            onTap: onCreateGroup,
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallActionCard(
                  icon: Icons.vpn_key_outlined,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF57C00),
                  label: 'Join by Code',
                  onTap: onJoinByCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallActionCard(
                  icon: Icons.explore_outlined,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  label: 'Browse Groups',
                  onTap: onBrowse,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppTheme.primary : AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon,
                    color: isPrimary ? Colors.white : iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isPrimary
                                ? Colors.white
                                : AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: isPrimary
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  size: 14,
                  color:
                      isPrimary ? Colors.white : AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SmallActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
