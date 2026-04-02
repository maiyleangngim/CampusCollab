import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_routes.dart';
import '../../services/firestore_service.dart';
import 'package:campuscollab/screens/profile/settings_screen.dart';
import 'package:campuscollab/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 4;

  String _name = "";
  String _id = "";
  String _university = "";
  String _location = "";
  String _major = "";
  String _bio = "";
  List<String> _courses = [];
  bool _isLookingForGroup = false;
  String? _avatarUrl;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    final data = await FirestoreService().getUser(uid);
    if (!mounted) return;
    setState(() {
      _loadingProfile = false;
      if (data != null) {
        _name = data['displayName'] ?? '';
        _id = data['studentId'] ?? '';
        _university = data['university'] ?? '';
        _location = data['location'] ?? '';
        _major = data['major'] ?? '';
        _bio = data['bio'] ?? '';
        _courses = List<String>.from(data['subjects'] ?? []);
        _isLookingForGroup = data['isLookingForGroup'] ?? false;
        _avatarUrl = data['avatarUrl'];
      }
    });
  }

  void _openEditProfile() async {
    final result = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initial: ProfileData(
            name: _name,
            studentId: _id,
            university: _university,
            location: _location,
            major: _major,
            bio: _bio,
            courses: _courses,
            isLookingForGroup: _isLookingForGroup,
            avatarUrl: _avatarUrl,
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _name = result.name;
        _id = result.studentId;
        _university = result.university;
        _location = result.location;
        _major = result.major;
        _bio = result.bio;
        _courses = result.courses;
        _isLookingForGroup = result.isLookingForGroup;
        _avatarUrl = result.avatarUrl;
      });
    }
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE3F2FD),
                backgroundImage: _avatarUrl != null
                    ? NetworkImage(_avatarUrl!)
                    : (_name.isNotEmpty
                        ? NetworkImage(
                            'https://ui-avatars.com/api/?name=$_name&background=1565C0&color=fff')
                        : null),
                child: _avatarUrl == null && _name.isEmpty
                    ? const Icon(Icons.person, color: AppTheme.primary, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildGroupsSummaryCard(),
                  const SizedBox(height: 24),
                  _buildCurrentFocusSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image with Edit Button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFE3F2FD),
                  image: _avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _avatarUrl == null
                    ? const Icon(Icons.person, size: 56, color: AppTheme.primary)
                    : null,
              ),
              Positioned(
                bottom: -10,
                right: -10,
                child: GestureDetector(
                  onTap: _openEditProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "EDIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Name and Role Icon
          Row(
            children: [
              Text(
                _name.isEmpty ? 'Your Name' : _name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, color: AppTheme.primary, size: 18),
              ),
            ],
          ),

          if (_id.isNotEmpty)
            Text(
              'ID: ${_id.replaceFirst('ID: ', '')}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 16),

          if (_university.isNotEmpty) _buildIconInfo(Icons.location_on_outlined, _university),
          if (_university.isNotEmpty) const SizedBox(height: 8),
          if (_major.isNotEmpty) _buildIconInfo(Icons.menu_book_outlined, _major),
          if (_major.isNotEmpty) const SizedBox(height: 8),
          if (_location.isNotEmpty) _buildIconInfo(Icons.directions_walk, _location),

          if (_bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _bio,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],

          if (_isLookingForGroup) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                  SizedBox(width: 6),
                  Text(
                    'Looking for a group',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (_courses.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _courses.map(_buildTag).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGroupsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "14 Groups",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "ACTIVE MEMBERSHIPS",
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome_motion, color: AppTheme.primary, size: 22),
            SizedBox(width: 10),
            Text(
              "Current Focus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFocusCard(
          "CS110",
          "Systems Programming",
          "Advanced memory management and concurrent process execution.",
          [Colors.orange, Colors.blue, Colors.green],
        ),
        const SizedBox(height: 16),
        _buildFocusCard(
          "SIS400",
          "Interaction Design",
          "Human-centered design principles and high-fidelity prototyping.",
          [Colors.purple, Colors.red],
        ),
      ],
    );
  }

  Widget _buildFocusCard(String code, String title, String desc, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Icon(Icons.star, color: Color(0xFFD4AF37), size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 70,
                height: 24,
                child: Stack(
                  children: List.generate(colors.length, (index) {
                    return Positioned(
                      left: index * 16.0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.surface,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: colors[index],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (colors.length > 2)
                const Text(
                  "+2",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
        if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.discover);
        if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.chats);
        if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.calendar);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      backgroundColor: AppTheme.surface,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
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
