class UserPrivacy {
  final String uid;
  final String dmAccess; // all | none
  final String profileVisibility; // public | shared_group | private
  final List<String> blockedUsers;

  const UserPrivacy({
    required this.uid,
    required this.dmAccess,
    required this.profileVisibility,
    required this.blockedUsers,
  });

  factory UserPrivacy.fromFirestore(String uid, Map<String, dynamic>? data) {
    final raw = data ?? const <String, dynamic>{};
    return UserPrivacy(
      uid: uid,
      dmAccess: raw['dmAccess'] as String? ?? 'all',
      profileVisibility: raw['profileVisibility'] as String? ?? 'public',
      blockedUsers: List<String>.from(raw['blockedUsers'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dmAccess': dmAccess,
      'profileVisibility': profileVisibility,
      'blockedUsers': blockedUsers,
    };
  }
}
