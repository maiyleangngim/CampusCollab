class AppRoutes {
  AppRoutes._();

  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String discover      = '/discover';
  static const String calendar      = '/calendar';
  static const String chats         = '/chats';
  static const String chat          = '/chat';          // arg: StudyGroup
  static const String profile       = '/profile';
  static const String createGroup   = '/create-group';
  static const String groupDetail   = '/group-detail';  // arg: StudyGroup
  static const String groupTasks    = '/group-tasks';   // arg: StudyGroup
  static const String resourceVault = '/resource-vault';// arg: StudyGroup
  static const String pomodoro      = '/pomodoro';      // arg: StudyGroup
  static const String directMessages = '/direct-messages';
  static const String directMessageDetail = '/direct-message-detail'; // arg: Map<String, dynamic>
  static const String userProfile = '/user-profile'; // arg: String uid
  static const String privacySettings = '/privacy-settings';
  static const String userSearch = '/user-search';
}
