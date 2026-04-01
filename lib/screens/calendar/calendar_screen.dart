// =============================================================================
// CALENDAR SCREEN  —  two tabs: Notifications | Calendar
// =============================================================================

import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../data/dummy_data.dart';
import '../../models/app_notification.dart';
import '../../models/deadline.dart';
import '../../theme/app_theme.dart';

// =============================================================================
// SCREEN
// =============================================================================

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0.5,
        leading: const BackButton(color: AppTheme.primary),
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 26),
            const SizedBox(width: 8),
            const Text('CampusCollab', style: AppTheme.titleStyle),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NotificationsTab(),
          _CalendarTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// =============================================================================
// NOTIFICATIONS TAB
// =============================================================================

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        const Text('Notifications',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
        const SizedBox(height: 20),
        const _SectionLabel('EARLIER'),
        const SizedBox(height: 8),
        ...dummyNotifications.map((n) => _NotifTile(notif: n)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ));
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: notif.isRead
            ? Colors.transparent
            : AppTheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 20),
            ),
            if (!notif.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500),
            children: [
              TextSpan(text: notif.title),
              const TextSpan(text: ' '),
              TextSpan(
                text: notif.body,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(notif.timeLabel,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: AppTheme.textSecondary, size: 18),
      ),
    );
  }
}

// =============================================================================
// CALENDAR TAB
// =============================================================================

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focusedMonth = DateTime(2026, 4);
  DateTime? _selectedDay;

  Set<int> get _deadlineDays => dummyDeadlines
      .where((d) =>
          d.date.year == _focusedMonth.year &&
          d.date.month == _focusedMonth.month)
      .map((d) => d.date.day)
      .toSet();

  Map<int, Color> get _deadlineDayColors {
    final map = <int, Color>{};
    for (final d in dummyDeadlines) {
      if (d.date.year == _focusedMonth.year &&
          d.date.month == _focusedMonth.month) {
        map[d.date.day] = d.color;
      }
    }
    return map;
  }

  List<Deadline> get _selectedDeadlines {
    if (_selectedDay == null) return [];
    return dummyDeadlines
        .where((d) =>
            d.date.year == _selectedDay!.year &&
            d.date.month == _selectedDay!.month &&
            d.date.day == _selectedDay!.day)
        .toList();
  }

  List<Deadline> get _upcomingDeadlines {
    final now = DateTime.now();
    return dummyDeadlines
        .where((d) => !d.date.isBefore(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        _selectedDay = null;
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        _selectedDay = null;
      });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MonthHeader(
                  month: _focusedMonth,
                  onPrev: _prevMonth,
                  onNext: _nextMonth),
              const SizedBox(height: 12),
              _WeekdayRow(),
              const SizedBox(height: 4),
              _DayGrid(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                deadlineDays: _deadlineDays,
                deadlineColors: _deadlineDayColors,
                onDayTap: (day) => setState(() => _selectedDay = day),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (_selectedDeadlines.isNotEmpty) ...[
          Text(
            _formatDate(_selectedDay!),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ..._selectedDeadlines.map((d) => _DeadlineTile(deadline: d)),
          const SizedBox(height: 16),
        ],

        const Text('Upcoming Deadlines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
        const SizedBox(height: 12),
        ..._upcomingDeadlines.map((d) => _DeadlineTile(deadline: d)),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// =============================================================================
// CALENDAR SUB-WIDGETS
// =============================================================================

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader(
      {required this.month, required this.onPrev, required this.onNext});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text('${_months[month.month - 1]} ${month.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      )),
                ),
              ))
          .toList(),
    );
  }
}

class _DayGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Set<int> deadlineDays;
  final Map<int, Color> deadlineColors;
  final void Function(DateTime) onDayTap;

  const _DayGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.deadlineDays,
    required this.deadlineColors,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = firstDay.weekday % 7;
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final today = DateTime.now();
    final cells = <Widget>[];

    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = selectedDay != null &&
          date.year == selectedDay!.year &&
          date.month == selectedDay!.month &&
          date.day == selectedDay!.day;
      final hasDeadline = deadlineDays.contains(day);

      cells.add(
        GestureDetector(
          onTap: () => onDayTap(date),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : isToday
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday || isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                      )),
                ),
              ),
              const SizedBox(height: 2),
              if (hasDeadline)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: deadlineColors[day] ?? AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: cells,
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final Deadline deadline;

  const _DeadlineTile({required this.deadline});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: deadline.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  months[deadline.date.month - 1].toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: deadline.color),
                ),
                Text(
                  '${deadline.date.day}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: deadline.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deadline.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    )),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.group_outlined,
                        size: 13, color: deadline.color),
                    const SizedBox(width: 4),
                    Text(deadline.groupName,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: deadline.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED BOTTOM NAV
// =============================================================================

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
        if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.discover);
        if (i == 2) Navigator.pushNamed(context, AppRoutes.chats);
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
    );
  }
}
