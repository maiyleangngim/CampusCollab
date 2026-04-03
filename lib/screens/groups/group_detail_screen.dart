import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../models/study_group.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late StudyGroup _group;
  List<Map<String, dynamic>> _members = [];
  bool _loadingMembers = true;
  String _myRole = 'member';
  bool _regenerating = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _loadData();
  }

  Future<void> _loadData() async {
    final members = await FirestoreService().getGroupMembers(_group.id);
    final role = await FirestoreService().getUserRole(_group.id);
    if (!mounted) return;
    setState(() {
      _members = members;
      _myRole = role;
      _loadingMembers = false;
    });
  }

  String get _inviteLink => 'campuscollab://join/${_group.inviteCode}';

  bool get _isAdminOrOwner => _myRole == 'owner' || _myRole == 'admin';

  Future<void> _regenerateCode() async {
    setState(() => _regenerating = true);
    final newCode = await FirestoreService().regenerateInviteCode(_group.id);
    if (!mounted) return;
    setState(() {
      _group = StudyGroup.fromFirestore({
        'id': _group.id,
        'name': _group.name,
        'description': _group.description,
        'courseCode': _group.courseCode,
        'subject': _group.subject,
        'template': _group.template,
        'memberCount': _group.memberCount,
        'maxMembers': _group.maxMembers,
        'isOnline': _group.isOnline,
        'isPublic': _group.isPublic,
        'lastMessage': _group.lastMessage,
        'lastMessageTime': _group.lastMessageTime,
        'inviteCode': newCode,
        'tags': _group.tags,
        'createdBy': _group.createdBy,
        'memberRoles': _group.memberRoles,
      });
      _regenerating = false;
    });
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Leave Group'),
        content: Text('Leave "${_group.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await FirestoreService().leaveGroup(_group.id);
    if (!mounted) return;
    Navigator.pop(context, 'left');
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        title: Text('Group Info', style: AppTheme.titleStyle),
        leading: const BackButton(color: AppTheme.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GROUP HEADER ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _templateColor(_group.template).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_templateIcon(_group.template), color: _templateColor(_group.template), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_group.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            if (_group.courseCode.isNotEmpty)
                              Text(_group.courseCode,
                                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                      _templateBadge(_group.template),
                    ],
                  ),
                  if (_group.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_group.description, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.5)),
                  ],
                  if (_group.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _group.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text(t, style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${_group.memberCount} / ${_group.maxMembers} members',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── INVITE ────────────────────────────────────────────────────
            _sectionLabel('INVITE MEMBERS'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                    ),
                    child: QrImageView(
                      data: _inviteLink,
                      version: QrVersions.auto,
                      size: 160,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1565C0)),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1565C0)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Invite code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_group.inviteCode,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                                color: AppTheme.primary)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _group.inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied!'), behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: Icon(Icons.copy, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Share.share(
                            'Join my study group "${_group.name}" on CampusCollab!\nInvite code: ${_group.inviteCode}',
                          ),
                          icon: Icon(Icons.share, size: 18),
                          label: Text('Share Invite'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_isAdminOrOwner) ...[
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _regenerating ? null : _regenerateCode,
                          icon: _regenerating
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.refresh, size: 18),
                          label: Text('New Code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── MEMBERS ───────────────────────────────────────────────────
            _sectionLabel('MEMBERS (${_members.length})'),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: _loadingMembers
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: _members.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        final isMe = m['uid'] == uid;
                        return Column(
                          children: [
                            if (i > 0) const Divider(height: 1, indent: 60, color: AppTheme.divider),
                            ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                backgroundImage: m['avatarUrl'] != null
                                    ? NetworkImage(m['avatarUrl'])
                                    : null,
                                child: m['avatarUrl'] == null
                                    ? Icon(Icons.person, color: AppTheme.primary, size: 22)
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    m['displayName'] ?? 'Unknown',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('You', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(m['major'] ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                              trailing: _roleBadge(m['role'] ?? 'member'),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // ── LEAVE GROUP ───────────────────────────────────────────────
            if (_myRole != 'owner')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _leaveGroup,
                  icon: Icon(Icons.exit_to_app, color: Colors.red),
                  label: Text('Leave Group', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
    );
  }

  Color _templateColor(String t) {
    if (t == 'exam_prep') return const Color(0xFF7C3AED);
    if (t == 'assignment') return const Color(0xFFF97316);
    return AppTheme.primary;
  }

  IconData _templateIcon(String t) {
    if (t == 'exam_prep') return Icons.quiz_outlined;
    if (t == 'assignment') return Icons.assignment_outlined;
    return Icons.groups_outlined;
  }

  Widget _templateBadge(String t) {
    final color = _templateColor(t);
    final label = t == 'exam_prep' ? 'EXAM PREP' : t == 'assignment' ? 'ASSIGNMENT' : 'GENERAL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _roleBadge(String role) {
    Color color;
    if (role == 'owner') {
      color = const Color(0xFFD4AF37);
    } else if (role == 'admin') {
      color = AppTheme.primary;
    } else if (role == 'mentor') {
      color = const Color(0xFF059669);
    } else {
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}




