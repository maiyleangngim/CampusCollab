import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  String _template = 'general';
  double _maxMembers = 20;
  bool _isPublic = true;
  List<String> _tags = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _courseCtrl.dispose();
    _subjectCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final val = _tagInputCtrl.text.trim().toUpperCase();
    if (val.isEmpty || _tags.contains(val) || _tags.length >= 8) return;
    setState(() => _tags.add(val));
    _tagInputCtrl.clear();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final id = await FirestoreService().createGroup(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        courseCode: _courseCtrl.text.trim().toUpperCase(),
        subject: _subjectCtrl.text.trim(),
        template: _template,
        maxMembers: _maxMembers.round(),
        isPublic: _isPublic,
        tags: List.from(_tags),
      );
      if (!mounted) return;
      Navigator.pop(context, id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Study Group', style: AppTheme.titleStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                  : Text('Create',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
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
              // ── BASIC INFO ────────────────────────────────────────────────
              _sectionLabel('GROUP INFO'),
              _card([
                _field(
                  controller: _nameCtrl,
                  label: 'Group Name',
                  icon: Icons.group_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                _divider(),
                _field(
                  controller: _descCtrl,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  maxLines: 2,
                ),
                _divider(),
                _field(
                  controller: _courseCtrl,
                  label: 'Course Code (e.g. CS108B)',
                  icon: Icons.code_outlined,
                ),
                _divider(),
                _field(
                  controller: _subjectCtrl,
                  label: 'Subject / Major',
                  icon: Icons.school_outlined,
                ),
              ]),
              const SizedBox(height: 24),

              // ── TEMPLATE ─────────────────────────────────────────────────
              _sectionLabel('GROUP TYPE'),
              Row(
                children: [
                  _templateCard('general', Icons.groups_outlined, 'General\nStudy', const Color(0xFF1565C0)),
                  const SizedBox(width: 10),
                  _templateCard('exam_prep', Icons.quiz_outlined, 'Exam\nPrep', const Color(0xFF7C3AED)),
                  const SizedBox(width: 10),
                  _templateCard('assignment', Icons.assignment_outlined, 'Assignment\nHelp', const Color(0xFFF97316)),
                ],
              ),
              const SizedBox(height: 24),

              // ── TAGS ──────────────────────────────────────────────────────
              _sectionLabel('TAGS'),
              _card([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags
                              .map((t) => _tagChip(t))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagInputCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Add tag (e.g. ALGORITHMS)',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _addTag,
                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── SETTINGS ─────────────────────────────────────────────────
              _sectionLabel('SETTINGS'),
              _card([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Max members
                      Row(
                        children: [
                          Icon(Icons.people_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Max Members: ${_maxMembers.round()}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface),
                                ),
                                Slider(
                                  value: _maxMembers,
                                  min: 2,
                                  max: 50,
                                  divisions: 48,
                                  activeColor: AppTheme.primary,
                                  onChanged: (v) => setState(() => _maxMembers = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1, color: AppTheme.divider),
                      // Public / Private
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isPublic,
                        onChanged: (v) => setState(() => _isPublic = v),
                        activeThumbColor: AppTheme.primary,
                        activeTrackColor: AppTheme.accent,
                        title: Text(
                          'Public Group',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          'Anyone can find and join this group',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 40),

              // ── CREATE BUTTON ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('Create Group',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          filled: false,
        ),
        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, color: AppTheme.divider);

  Widget _templateCard(String value, IconData icon, String label, Color color) {
    final isSelected = _template == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _template = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppTheme.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag,
              style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => setState(() => _tags.remove(tag)),
            child: Icon(Icons.close, size: 13, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}




