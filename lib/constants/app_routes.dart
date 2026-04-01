// AppRoutes — All named route strings in one place.
//
// HOW TO USE:
//   Navigator.pushNamed(context, AppRoutes.login);
//   Navigator.pushReplacementNamed(context, AppRoutes.home);
//
// ADDING A NEW ROUTE:
//   1. Add a constant here.
//   2. Register it in main.dart under the `routes:` map.

class AppRoutes {
  AppRoutes._();

  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';
  static const String discover  = '/discover';
  static const String calendar  = '/calendar';
  static const String chats   = '/chats';
  static const String chat    = '/chat';        // passes StudyGroup as argument
  static const String profile = '/profile';
}
