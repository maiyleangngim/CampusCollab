import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Data class passed to and returned from EditProfileScreen.
class ProfileData {
  final String name;
  final String studentId;
  final String university;
  final String location;
  final String major;
  final String bio;
  final List<String> courses;
  final bool isLookingForGroup;
  final String? avatarUrl;

  const ProfileData({
    required this.name,
    required this.studentId,
    required this.university,
    required this.location,
    required this.major,
    required this.bio,
    required this.courses,
    required this.isLookingForGroup,
    this.avatarUrl,
  });

  ProfileData copyWith({
    String? name,
    String? studentId,
    String? university,
    String? location,
    String? major,
    String? bio,
    List<String>? courses,
    bool? isLookingForGroup,
    String? avatarUrl,
  }) {
    return ProfileData(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      location: location ?? this.location,
      major: major ?? this.major,
      bio: bio ?? this.bio,
      courses: courses ?? this.courses,
      isLookingForGroup: isLookingForGroup ?? this.isLookingForGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final ProfileData initial;

  const EditProfileScreen({super.key, required this.initial});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _majorCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _courseInputCtrl;

  late List<String> _courses;
  late bool _isLookingForGroup;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _nameCtrl = TextEditingController(text: d.name);
    _idCtrl = TextEditingController(text: d.studentId);
    _universityCtrl = TextEditingController(text: d.university);
    _locationCtrl = TextEditingController(text: d.location);
    _majorCtrl = TextEditingController(text: d.major);
    _bioCtrl = TextEditingController(text: d.bio);
    _courseInputCtrl = TextEditingController();
    _courses = List.from(d.courses);
    _isLookingForGroup = d.isLookingForGroup;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _universityCtrl.dispose();
    _locationCtrl.dispose();
    _majorCtrl.dispose();
    _bioCtrl.dispose();
    _courseInputCtrl.dispose();
    super.dispose();
  }

  void _addCourse() {
    final val = _courseInputCtrl.text.trim().toUpperCase();
    if (val.isEmpty || _courses.contains(val)) return;
    setState(() => _courses.add(val));
    _courseInputCtrl.clear();
  }

  void _removeCourse(String course) {
    setState(() => _courses.remove(course));
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.initial.copyWith(
      name: _nameCtrl.text.trim(),
      studentId: _idCtrl.text.trim(),
      university: _universityCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      major: _majorCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      courses: List.from(_courses),
      isLookingForGroup: _isLookingForGroup,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: AppTheme.titleStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AVATAR ────────────────────────────────────────────────────
              _buildAvatarSection(),
              const SizedBox(height: 32),

              // ── BASIC INFO ────────────────────────────────────────────────
              _buildSectionLabel('BASIC INFO'),
              _buildCard([
                _buildField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                _buildDivider(),
                _buildField(
                  controller: _idCtrl,
                  label: 'Student ID',
                  icon: Icons.badge_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Student ID is required' : null,
                ),
                _buildDivider(),
                _buildField(
                  controller: _universityCtrl,
                  label: 'University',
                  icon: Icons.school_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'University is required' : null,
                ),
                _buildDivider(),
                _buildField(
                  controller: _majorCtrl,
                  label: 'Major',
                  icon: Icons.menu_book_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Major is required' : null,
                ),
                _buildDivider(),
                _buildField(
                  controller: _locationCtrl,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ]),
              const SizedBox(height: 24),

              // ── BIO ───────────────────────────────────────────────────────
              _buildSectionLabel('BIO'),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextFormField(
                    controller: _bioCtrl,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      hintText: 'Tell others about yourself...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      border: InputBorder.none,
                      counterStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── COURSES ───────────────────────────────────────────────────
              _buildSectionLabel('COURSES & SUBJECTS'),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag chips
                      if (_courses.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _courses
                              .map((c) => _buildCourseChip(c))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Add course input
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _courseInputCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Add course (e.g. CS110)',
                                hintStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: AppTheme.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              onFieldSubmitted: (_) => _addCourse(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _addCourse,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── AVAILABILITY ──────────────────────────────────────────────
              _buildSectionLabel('AVAILABILITY'),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isLookingForGroup,
                    onChanged: (val) => setState(() => _isLookingForGroup = val),
                    activeThumbColor: AppTheme.primary,
                    activeTrackColor: AppTheme.accent,
                    title: const Text(
                      'Looking for a Group',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Let others know you\'re available to join a study group',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 40),

              // ── SAVE BUTTON ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── AVATAR SECTION ──────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFFE3F2FD),
                  image: widget.initial.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.initial.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.initial.avatarUrl == null
                    ? const Icon(Icons.person, size: 56, color: AppTheme.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: wire up image_picker + Firebase Storage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo upload will be available after Firebase setup'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo upload will be available after Firebase setup'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Change Profile Photo',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 11),
        ),
        style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: AppTheme.divider);
  }

  Widget _buildCourseChip(String course) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            course,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeCourse(course),
            child: const Icon(Icons.close, size: 14, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
