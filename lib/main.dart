import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'constants/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chats/chats_screen.dart';
import 'screens/chats/chat_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'models/study_group.dart';

void main() {
  runApp(const CampusCollabApp());
}

class CampusCollabApp extends StatelessWidget {
  const CampusCollabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusCollab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // ── Initial route ──────────────────────────────────────────────────────
      // Change to AppRoutes.home to skip login during UI development.
      initialRoute: AppRoutes.login,

      // ── Named routes ───────────────────────────────────────────────────────
      routes: {
        AppRoutes.login:   (_) => const LoginScreen(),
        AppRoutes.home:    (_) => const HomeScreen(),
        AppRoutes.chats:   (_) => const ChatsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },

      // ── Routes that require arguments ──────────────────────────────────────
      // AppRoutes.chat passes a StudyGroup object via Navigator arguments.
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.chat) {
          final group = settings.arguments as StudyGroup;
          return MaterialPageRoute(
            builder: (_) => ChatDetailScreen(group: group),
          );
        }
        return null;
      },
    );
  }
}
