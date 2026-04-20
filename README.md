# CampusCollab

CampusCollab is a Flutter + Firebase campus collaboration app focused on study groups, real-time chat, shared tasks, calendar planning, and productivity tools.

## Current Status

Fully backend-connected — no UI-only placeholder screens remain.

- Firebase Authentication is integrated (email/password, Google, anonymous).
- Firestore powers groups, chat, folders, tasks, resources, sessions, and user profile data.
- OTP verification (SHA-256 hashed) and password-reset OTP flows are fully implemented.
- Calendar integrates both study sessions and group task deadlines.
- Chat supports edit/delete/reactions and attachment/link workflows.
- Light and dark theme with persistence via SharedPreferences.
- Chat quick-action bar gives one-tap access to Tasks, Resources, Pomodoro, and Member management from within each group chat.

## Implemented Features

- Auth flows:
    - Register + OTP email verification
    - Login (email/password, Google, anonymous)
    - Forgot password + OTP identity verification + Firebase reset link flow
- Study groups:
    - Create, join (including invite code), leave
    - Owner/moderator role controls
    - Member management and role assignment
- Group chat:
    - Real-time messages
    - Edit and delete (with role permissions)
    - Emoji reactions
    - Image and file attachments via Firebase Storage
    - Link embeds (including YouTube previews)
- Tasks:
    - Advanced task fields (description, priority, optional deadline)
    - Task editing and status tracking
    - Cross-group deadline visibility in Calendar
- Group management:
    - QR code + invite link generation
    - Moderator promotion / demotion / kick
    - Owner-only group edit and delete (danger zone)
- Other modules:
    - Resource Vault (link sharing per group)
    - Pomodoro timer (25/5 focus-break cycle, per group)
    - Profile and settings with light/dark/system theme persistence
    - Discover screen for browsing and joining public groups

## Tech Stack

- Flutter (Dart)
- Firebase Core / Auth / Firestore / Storage
- Provider for app state
- SharedPreferences for local settings
- URL Launcher, Image Picker, File Picker, QR, Share utilities

## Project Layout (High Level)

```
lib/
    constants/
    models/
    providers/
    screens/
        auth/
        calendar/
        chats/
        discover/
        groups/
        home/
        profile/
        resources/
        study/
        tasks/
    services/
    theme/
    widgets/
```

For the full repository conventions and architecture notes, see `CLAUDE.md`.

## Setup

### 1. Prerequisites

- Flutter SDK installed
- A Firebase project configured
- Android Studio / VS Code toolchain

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

- Place your Android Firebase config at `android/app/google-services.json`.
- Configure `lib/firebase_options.dart` with your actual Firebase values.
- If adding iOS, include `GoogleService-Info.plist` in the iOS Runner project.

### 4. Configure EmailJS (for OTP emails)

Update these constants in `lib/services/email_service.dart`:

- `_publicKey`
- `_serviceId`
- `_verifyTplId`
- `_resetTplId`

### 5. Run

```bash
flutter run
```

## Security Notes

- Do not commit real API keys, service IDs, or private credentials.
- Keep local handoff notes and secret-bearing local files out of commits via `.gitignore`.
- If secrets were ever committed in history, rotate them immediately.

## Development Notes

- The repository includes both production-backed screens and some legacy placeholders.
- `lib/data/dummy_data.dart` is legacy-only and should not be used for new production features.
- Route constants live in `lib/constants/app_routes.dart`.
