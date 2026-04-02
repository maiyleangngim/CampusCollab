// =============================================================================
// DISCOVER SCREEN
// =============================================================================

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../models/discover_group.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

const List<String> _filterLabels = [
  'All Groups',
  'Course Code',
  'Subject',
  'Exam Prep',
  'Homework Help',
  'General',
];

// =============================================================================
// SCREEN
// =============================================================================

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _activeFilter = 'All Groups';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<DiscoverGroup> _allGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FirestoreService().getDiscoverGroups().then((groups) {
      if (mounted) setState(() { _allGroups = groups; _loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscoverGroup> get _filtered {
    return _allGroups.where((g) {
      final matchesFilter = _activeFilter == 'All Groups' || g.filterTags.contains(_activeFilter);
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.courseCode.toLowerCase().contains(q) ||
          g.subject.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 28),
            const SizedBox(width: 8),
            const Text('CampusCollab', style: AppTheme.titleStyle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + Search ───────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Discover Groups',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by course, topic, or group name...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary, size: 20),
                    filled: true,
                    fillColor: AppTheme.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Chips ──────────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filterLabels.map((label) {
                  final active = _activeFilter == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppTheme.primary : AppTheme.divider,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Group Cards ───────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(
                    child: Text('No groups found.',
                        style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _GroupCard(group: _filtered[i]),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.chats);
          if (i == 3) Navigator.pushNamed(context, AppRoutes.calendar);
          if (i == 4) Navigator.pushNamed(context, AppRoutes.profile);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: AppTheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// =============================================================================
// GROUP CARD
// =============================================================================

class _GroupCard extends StatelessWidget {
  final DiscoverGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(label: group.courseCode, color: group.subjectColor),
              const SizedBox(width: 6),
              _Tag(label: group.subject, color: group.subjectColor),
              const Spacer(),
              const Icon(Icons.more_horiz,
                  color: AppTheme.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 10),

          Text(group.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 6),

          Text(group.description,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
          const SizedBox(height: 14),

          Row(
            children: [
              SizedBox(
                width: group.memberCount > 9 ? 72 : 52,
                height: 28,
                child: Stack(
                  children: [
                    _Avatar(color: AppTheme.primary, offset: 0),
                    _Avatar(color: AppTheme.accent, offset: 18),
                    if (group.memberCount > 9)
                      Positioned(
                        left: 36,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppTheme.surface, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+${group.memberCount - 2}',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('Active Members',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: group.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPERS
// =============================================================================

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.4,
          )),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Color color;
  final double offset;

  const _Avatar({required this.color, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.surface, width: 2),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 14),
      ),
    );
  }
}
