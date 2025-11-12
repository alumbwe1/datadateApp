# DataDate Setup Guide

## Quick Start

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

This will install all required packages including:
- Riverpod for state management
- GoRouter for navigation
- Dio for HTTP requests
- Agora for voice calls
- And many more...

### 2. Run the App

```bash
flutter run
```

The app will start on your connected device or emulator.

## First Time Setup

### Default Login Credentials

Since we're using mock authentication, you can use any email/password combination:

- **Email**: test@example.com
- **Password**: password123

Or simply register a new account - it will be stored locally.

### Navigation Flow

1. **Login/Register** → Start here
2. **Encounters** → Swipe through profiles
3. **Profile** → View your profile and logout

## Features to Test

### 1. Authentication
- Register with any email/password
- Login with the same credentials
- Logout from profile page

### 2. Encounters (Swiping)
- Swipe right to like
- Swipe left to skip
- Use bottom buttons for actions
- Profiles are fetched from randomuser.me API

### 3. Profile
- View your profile information
- See your university and relationship goal
- Logout functionality

## Mock Data Sources

The app uses these APIs for mock data:

1. **randomuser.me** - Profile pictures and user data
   - Automatically fetches opposite gender profiles
   - Includes realistic photos and names

2. **Local Mock** - Authentication and user management
   - Stores tokens in flutter_secure_storage
   - User data in SharedPreferences

## Customization

### Change Theme Colors

Edit `lib/core/constants/app_colors.dart`:

```dart
static const Color primaryLight = Color(0xFFFF6B6B); // Your color
static const Color primaryDark = Color(0xFFFF6B6B);  // Your color
```

### Add Universities

Edit `lib/features/auth/presentation/pages/register_page.dart`:

```dart
final List<String> _universities = [
  'MIT',
  'Stanford',
  'Your University', // Add here
];
```

### Configure Agora for Voice Calls

1. Sign up at https://www.agora.io/
2. Create a project and get your App ID
3. Update `lib/core/constants/app_constants.dart`:

```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
```

## Troubleshooting

### Issue: "SharedPreferences not initialized"

**Solution**: The app initializes SharedPreferences asynchronously. If you see this error, restart the app.

### Issue: "Failed to load profiles"

**Solution**: Check your internet connection. The app needs internet to fetch profiles from randomuser.me.

### Issue: Build errors after pub get

**Solution**: Try these commands:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Agora permissions on Android

**Solution**: The app requests microphone permissions automatically. Make sure to grant them when prompted.

## Development Tips

### Hot Reload

Press `r` in the terminal or use your IDE's hot reload button to see changes instantly.

### State Management

The app uses Riverpod. To access state:

```dart
// In a ConsumerWidget
final authState = ref.watch(authProvider);

// To modify state
ref.read(authProvider.notifier).login(email, password);
```

### Adding New Features

Follow the clean architecture pattern:

1. **Domain Layer**: Create entities and repository interfaces
2. **Data Layer**: Implement repositories and data sources
3. **Presentation Layer**: Create UI and providers

### Navigation

Use GoRouter for navigation:

```dart
context.go('/encounters');  // Replace current route
context.push('/profile');   // Push new route
context.pop();              // Go back
```

## Next Steps

### Implement Chat Feature

1. Set up WebSocket connection
2. Create chat models and repository
3. Build chat UI with message bubbles
4. Add typing indicators and read receipts

### Add Voice Calls

1. Configure Agora App ID
2. Implement call signaling
3. Create call UI
4. Handle permissions

### Add Filters

1. Create filter UI
2. Add filter state management
3. Update profile fetching with filters
4. Save filter preferences

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Agora Documentation](https://docs.agora.io/)

## Support

For issues or questions, check the code comments or refer to the package documentation.
