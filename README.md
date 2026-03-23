# CampusCollab

A Flutter study-group messaging app for university students.

> **Current phase:** UI/UX prototype — all screens use dummy data. No backend connected yet.

---

## Project Structure

```
lib/
├── main.dart                        # App entry point & route registration
│
├── theme/
│   └── app_theme.dart               # Colors, text styles & MaterialTheme
│
├── constants/
│   └── app_routes.dart              # Named route strings ('/login', '/home', …)
│
├── models/                          # Plain Dart data classes
│   ├── user.dart
│   ├── message.dart
│   └── study_group.dart
│
├── data/
│   └── dummy_data.dart              # Hardcoded fake data for prototyping
│
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── chats/
│   │   ├── chats_screen.dart
│   │   └── chat_detail_screen.dart
│   └── profile/
│       └── profile_screen.dart
│
└── widgets/                         # Reusable UI components
    ├── group_chat_card.dart
    ├── message_bubble.dart
    └── chat_input_bar.dart
```

---

## Navigation

All routes are defined in `constants/app_routes.dart` and registered in `main.dart`.

```dart
Navigator.pushNamed(context, AppRoutes.home);
Navigator.pushReplacementNamed(context, AppRoutes.home);
Navigator.pushNamed(context, AppRoutes.chat, arguments: group);
```

| Constant | Screen |
|----------|--------|
| `AppRoutes.login` | Login |
| `AppRoutes.home` | Home |
| `AppRoutes.chats` | Group chat list |
| `AppRoutes.chat` | Individual chat (requires `StudyGroup` argument) |
| `AppRoutes.profile` | User profile |

---

## Theme

Use `AppTheme` constants instead of hardcoding colors or sizes.

```dart
import '../../theme/app_theme.dart';

AppTheme.primary        // deep blue
AppTheme.primaryLight   // medium blue
AppTheme.background     // page background
AppTheme.surface        // white
AppTheme.headingStyle   // 22px bold
AppTheme.titleStyle     // 16px semibold
AppTheme.bodyStyle      // 14px regular
AppTheme.captionStyle   // 12px grey
```

---

## Tips

- To skip login during development, change `initialRoute` to `AppRoutes.home` in `main.dart`.
- Hot reload: `r` — Hot restart: `R`
- Dummy data is in `data/dummy_data.dart` — edit freely to test UI states.
