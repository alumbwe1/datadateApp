# Simplified Onboarding & Profile Integration Guide

## Overview

The app now has a streamlined onboarding process with real API integration for profiles.

## Key Changes

### 1. Simplified Registration
**File:** `lib/features/auth/presentation/pages/register_page.dart`

- Only requires: **Name, Email, Password**
- No more age, gender, or university during registration
- Auto-login after successful registration
- Navigates to onboarding to complete profile

### 2. Auto-Login on App Start
**Files:** 
- `lib/features/auth/presentation/pages/splash_page.dart`
- `lib/core/router/app_router.dart`

- App starts with splash screen
- Checks if user has valid auth token
- If logged in + onboarding complete → Go to home
- If logged in + onboarding incomplete → Go to onboarding
- If not logged in → Go to login

### 3. Profile API Integration
**New Files:**
- `lib/features/profile/domain/entities/user_profile.dart`
- `lib/features/profile/data/models/user_profile_model.dart`
- `lib/features/profile/data/datasources/profile_remote_datasource.dart`
- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/presentation/providers/profile_provider.dart`

**API Endpoints Used:**
- `GET /api/v1.0/profiles/me/` - Get current user's profile
- `PATCH /api/v1.0/profiles/me/` - Update profile
- `POST /api/v1.0/profiles/me/photo/` - Upload profile photo

### 4. Updated Profile Page
**File:** `lib/features/profile/presentation/pages/profile_page.dart`

- Fetches real profile data from API
- Shows loading state
- Shows error state with retry
- Pull-to-refresh support
- Displays:
  - Profile photo
  - Name & age
  - University
  - Relationship goal
  - Bio
  - Interests
  - Course & graduation year
  - Gender

### 5. Reusable UI Components
**New Files:**
- `lib/core/widgets/custom_snackbar.dart` - Professional snackbars (success, error, warning, info)
- `lib/core/widgets/error_widget.dart` - Reusable error display with retry

### 6. Updated Onboarding Provider
**File:** `lib/features/onboarding/presentation/providers/onboarding_provider.dart`

- Simplified to only collect profile completion data
- Updates profile via API when onboarding completes
- No longer stores registration data (handled by auth)

## User Flow

### New User Registration
```
1. Open App → Splash Screen
2. Not logged in → Login Page
3. Click "Sign Up" → Register Page
4. Enter: Name, Email, Password → Submit
5. Auto-login → Onboarding Welcome
6. Complete onboarding steps (gender, preferences, interests, etc.)
7. Click "Start Exploring" → Profile updated via API
8. Navigate to Home (Encounters)
```

### Returning User
```
1. Open App → Splash Screen
2. Check auth token → Valid
3. Check onboarding status → Complete
4. Navigate directly to Home (Encounters)
```

### Incomplete Onboarding
```
1. Open App → Splash Screen
2. Check auth token → Valid
3. Check onboarding status → Incomplete
4. Navigate to Onboarding Welcome
5. Complete remaining steps
6. Navigate to Home
```

## API Data Flow

### Registration
```dart
POST /auth/users/
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123",
  "university": 1,  // Default
  "gender": "male",  // Default
  "preferred_genders": ["female"],  // Default
  "intent": "dating"  // Default
}
```

### Profile Update (During Onboarding)
```dart
PATCH /api/v1.0/profiles/me/
{
  "bio": "Love hiking and coffee",
  "course": "Computer Science",
  "date_of_birth": "2003-01-01",
  "interests": ["hiking", "coffee", "coding"]
}
```

### Get Profile
```dart
GET /api/v1.0/profiles/me/

Response:
{
  "id": 1,
  "display_name": "John Doe",
  "bio": "Love hiking and coffee",
  "course": "Computer Science",
  "age": 21,
  "interests": ["hiking", "coffee", "coding"],
  "profile_photo": "https://...",
  "user": {
    "id": 1,
    "display_name": "John Doe",
    "university": {
      "name": "Stanford University"
    },
    "gender": "male",
    "intent": "dating"
  }
}
```

## Error Handling

### Custom Snackbar Usage
```dart
import '../../../../core/widgets/custom_snackbar.dart';

// Success
CustomSnackbar.show(
  context,
  message: 'Profile updated successfully!',
  type: SnackbarType.success,
);

// Error
CustomSnackbar.show(
  context,
  message: 'Failed to update profile',
  type: SnackbarType.error,
);

// Warning
CustomSnackbar.show(
  context,
  message: 'Please complete your profile',
  type: SnackbarType.warning,
);

// Info
CustomSnackbar.show(
  context,
  message: 'Feature coming soon!',
  type: SnackbarType.info,
);
```

### Custom Error Widget Usage
```dart
import '../../../../core/widgets/error_widget.dart';

CustomErrorWidget(
  message: 'Failed to load profile',
  onRetry: () {
    // Retry logic
    ref.read(profileProvider.notifier).loadProfile();
  },
)
```

## Testing

### Test Registration Flow
1. Run app
2. Click "Sign Up"
3. Enter name, email, password
4. Click "Continue"
5. Should auto-login and navigate to onboarding

### Test Auto-Login
1. Complete registration and onboarding
2. Close app
3. Reopen app
4. Should go directly to home (no login screen)

### Test Profile Loading
1. Login
2. Navigate to Profile tab
3. Should see real data from API
4. Pull down to refresh
5. Should reload data

### Test Profile Update
1. Complete onboarding
2. Profile should be updated via API
3. Check profile page to see updated data

## Next Steps

### Recommended Enhancements
1. **Edit Profile Page** - Allow users to edit their profile
2. **Photo Upload** - Implement profile photo upload
3. **Gallery Management** - Add/remove gallery photos
4. **University Selection** - Add during onboarding
5. **Age Input** - Add during onboarding
6. **Gender Selection** - Add during onboarding
7. **Validation** - Add more robust validation
8. **Offline Support** - Cache profile data locally

### Optional Features
- Profile completion progress bar
- Profile preview before publishing
- Skip onboarding option (with warnings)
- Edit individual profile fields
- Profile visibility settings

## Files Modified

### New Files
- `lib/features/profile/domain/entities/user_profile.dart`
- `lib/features/profile/data/models/user_profile_model.dart`
- `lib/features/profile/data/datasources/profile_remote_datasource.dart`
- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/presentation/providers/profile_provider.dart`
- `lib/features/auth/presentation/pages/splash_page.dart`
- `lib/core/widgets/custom_snackbar.dart`
- `lib/core/widgets/error_widget.dart`

### Modified Files
- `lib/features/auth/presentation/pages/register_page.dart` - Simplified
- `lib/features/profile/presentation/pages/profile_page.dart` - Real API data
- `lib/features/onboarding/presentation/providers/onboarding_provider.dart` - Profile updates
- `lib/features/onboarding/presentation/pages/onboarding_welcome_page.dart` - Simplified
- `lib/features/onboarding/presentation/pages/onboarding_complete_page.dart` - API integration
- `lib/features/auth/domain/repositories/auth_repository.dart` - Simplified register
- `lib/features/auth/data/repositories/auth_repository_impl.dart` - Simplified register
- `lib/features/auth/presentation/providers/auth_provider.dart` - Simplified register
- `lib/core/router/app_router.dart` - Added splash screen
- `lib/core/constants/api_endpoints.dart` - Added profile endpoints
- `lib/core/network/api_client.dart` - Exposed Dio instance
- `lib/core/providers/api_providers.dart` - Added Dio provider

## Summary

✅ **Registration simplified** - Only name, email, password
✅ **Auto-login implemented** - Valid token = direct to home
✅ **Profile API integrated** - Real data from backend
✅ **Reusable UI components** - Snackbars and error widgets
✅ **Onboarding updates profile** - Via API calls
✅ **Professional error handling** - With retry functionality
✅ **Pull-to-refresh** - On profile page
✅ **Loading states** - Throughout the app

The app now provides a smooth, professional onboarding experience with real API integration!
