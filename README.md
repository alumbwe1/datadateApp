# DataDate - Student Dating App

A Flutter-based student dating app inspired by Bumble and Badoo, built with clean architecture and modern best practices.

## Features

- 🔐 **Authentication**: JWT-based login/register with Djoser integration (mock for now)
- 💞 **Encounters**: Tinder-style card swiping with like/skip functionality
- 💬 **Chat**: Real-time messaging with WebSockets (coming soon)
- 📞 **Voice Calls**: Agora SDK integration for voice calls (coming soon)
- 🎓 **University Profiles**: Filter by university and relationship goals
- 🌓 **Theme Support**: Light and dark mode with smooth transitions
- 💾 **Local Storage**: SharedPreferences for settings, flutter_secure_storage for tokens

## Tech Stack

- **State Management**: Riverpod (hooks_riverpod + flutter_riverpod)
- **Architecture**: Clean Architecture (domain, data, presentation layers)
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences + flutter_secure_storage
- **HTTP**: Dio
- **Voice Calls**: Agora RTC Engine
- **UI**: Shimmer, Google Fonts, CachedNetworkImage, Lottie
- **Swiping**: flutter_card_swiper

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── validators.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_shimmer.dart
│       └── main_navigation.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── encounters/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       └── presentation/
└── main.dart
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Agora (Optional for Voice Calls)

Update `lib/core/constants/app_constants.dart` with your Agora App ID:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
```

### 3. Run the App

```bash
flutter run
```

## Mock Data

The app currently uses mock data from:
- **randomuser.me** - For profile pictures and user data
- **Local mock implementations** - For authentication and interactions

## Features Implementation Status

### ✅ Completed
- Authentication UI (Login/Register)
- Encounters page with card swiping
- Profile page
- Theme support (light/dark)
- Clean architecture setup
- Navigation with GoRouter
- Mock data integration

### 🚧 In Progress / Coming Soon
- Chat feature with WebSockets
- Voice calls with Agora
- Nearby users
- Likes page
- Match animations with Lottie
- Subscription management
- Profile editing
- Image upload
- Filters (relationship goals, university)

## Design Inspiration

The UI/UX is inspired by Bumble and Badoo with:
- Minimalist layouts
- Rounded image corners
- Floating buttons
- Bold typography
- Clean spacing and elevation

## Development Notes

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Contributing

This is a student project. Feel free to fork and customize for your needs.

## License

MIT License
