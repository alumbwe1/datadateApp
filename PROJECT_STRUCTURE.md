# DataDate - Project Structure & Architecture

## Overview

DataDate is a student-focused dating app built with Flutter, following Clean Architecture principles and using Riverpod for state management.

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Widgets, State Management)    │
├─────────────────────────────────────┤
│       Domain Layer                  │
│  (Entities, Repository Interfaces)  │
├─────────────────────────────────────┤
│        Data Layer                   │
│  (Models, Data Sources, Repos)      │
└─────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── core/                           # Shared utilities and configurations
│   ├── constants/
│   │   ├── app_colors.dart        # Color palette for light/dark themes
│   │   └── app_constants.dart     # App-wide constants (API URLs, limits, etc.)
│   ├── errors/
│   │   └── failures.dart          # Error handling classes
│   ├── router/
│   │   └── app_router.dart        # GoRouter configuration
│   ├── theme/
│   │   └── app_theme.dart         # Light and dark theme definitions
│   ├── utils/
│   │   └── validators.dart        # Form validation utilities
│   └── widgets/
│       ├── custom_button.dart     # Reusable button widget
│       ├── custom_text_field.dart # Reusable text field widget
│       ├── loading_shimmer.dart   # Shimmer loading effects
│       └── main_navigation.dart   # Bottom navigation bar
│
├── features/                       # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart    # Local storage operations
│   │   │   │   └── auth_remote_datasource.dart   # API calls (mock)
│   │   │   ├── models/
│   │   │   │   └── user_model.dart               # User data model
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart     # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart                     # User entity
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart          # Repository interface
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart               # Login UI
│   │       │   └── register_page.dart            # Registration UI
│   │       └── providers/
│   │           └── auth_provider.dart            # Riverpod state management
│   │
│   ├── encounters/                # Swiping/matching feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── profile.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── encounters_page.dart          # Swipe UI
│   │       ├── providers/
│   │       │   └── encounters_provider.dart
│   │       └── widgets/
│   │           └── profile_card.dart             # Profile card widget
│   │
│   └── profile/                   # User profile feature
│       └── presentation/
│           └── pages/
│               └── profile_page.dart             # Profile view UI
│
└── main.dart                      # App entry point
```

## Key Features by Module

### 1. Core Module

**Purpose**: Shared utilities, configurations, and reusable components

**Key Files**:
- `app_theme.dart`: Defines light/dark themes using Google Fonts (Poppins)
- `app_colors.dart`: Color constants for consistent theming
- `app_constants.dart`: API URLs, storage keys, limits
- `validators.dart`: Email, password, age validation
- `failures.dart`: Error handling with specific failure types

**Widgets**:
- `CustomButton`: Styled button with loading state
- `CustomTextField`: Styled text input with validation
- `LoadingShimmer`: Skeleton loading screens
- `MainNavigation`: Bottom navigation bar with 5 tabs

### 2. Auth Feature

**Purpose**: User authentication and registration

**Flow**:
```
User Input → Presentation (UI) → Provider (State) → Repository → Data Source → Storage/API
```

**Components**:

**Domain Layer**:
- `User` entity: Core user data structure
- `AuthRepository` interface: Defines auth operations

**Data Layer**:
- `UserModel`: JSON serializable user model
- `AuthLocalDataSource`: Manages tokens (flutter_secure_storage) and user data (SharedPreferences)
- `AuthRemoteDataSource`: Mock API calls for login/register
- `AuthRepositoryImpl`: Implements repository interface

**Presentation Layer**:
- `LoginPage`: Email/password login form
- `RegisterPage`: Multi-step registration with university selection
- `AuthProvider`: Riverpod StateNotifier managing auth state

**State Management**:
```dart
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
}
```

### 3. Encounters Feature

**Purpose**: Tinder-style profile swiping and matching

**Flow**:
```
Load Profiles → Display Cards → Swipe → Like/Skip → Update State
```

**Components**:

**Domain Layer**:
- `Profile` entity: User profile data
- `ProfileRepository` interface: Profile operations

**Data Layer**:
- `ProfileModel`: JSON serializable profile
- `ProfileRemoteDataSource`: Fetches profiles from randomuser.me API
- `ProfileRepositoryImpl`: Implements profile operations

**Presentation Layer**:
- `EncountersPage`: Main swipe interface with CardSwiper
- `ProfileCard`: Beautiful profile card with gradient overlay
- `EncountersProvider`: Manages profile list and swipe actions

**Features**:
- Card swiping with flutter_card_swiper
- Like/skip buttons
- Profile info display (name, age, university, location)
- Online status indicator
- Interest tags
- Shimmer loading states

### 4. Profile Feature

**Purpose**: Display and manage user profile

**Components**:
- `ProfilePage`: Shows user info, allows logout
- Displays profile picture, university, email, relationship goal
- Edit button (UI only, functionality pending)

## State Management with Riverpod

### Provider Types Used

1. **Provider**: Immutable dependencies (Dio, repositories)
2. **StateNotifierProvider**: Mutable state (auth, encounters)
3. **FutureProvider**: Async initialization (SharedPreferences)

### Example Provider Structure

```dart
// Data source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// State notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
```

## Navigation with GoRouter

### Route Structure

```
/login                  → LoginPage
/register               → RegisterPage
/encounters (shell)     → EncountersPage + BottomNav
/profile (shell)        → ProfilePage + BottomNav
```

### Shell Route

Uses `ShellRoute` to maintain bottom navigation across pages:

```dart
ShellRoute(
  builder: (context, state, child) => MainNavigation(child: child),
  routes: [
    GoRoute(path: '/encounters', ...),
    GoRoute(path: '/profile', ...),
  ],
)
```

## Data Flow Examples

### Login Flow

```
1. User enters email/password in LoginPage
2. Taps login button
3. LoginPage calls ref.read(authProvider.notifier).login()
4. AuthNotifier updates state to loading
5. AuthNotifier calls repository.login()
6. Repository calls remoteDataSource.login() (mock API)
7. On success, repository saves token via localDataSource
8. Repository returns User entity
9. AuthNotifier updates state with user
10. LoginPage watches state change
11. LoginPage navigates to /encounters
```

### Profile Loading Flow

```
1. EncountersPage loads
2. Calls ref.read(encountersProvider.notifier).loadProfiles()
3. EncountersNotifier updates state to loading
4. Shows ProfileCardShimmer
5. Repository calls remoteDataSource.getProfiles()
6. Data source makes HTTP request to randomuser.me
7. Parses JSON to ProfileModel list
8. Repository returns Profile entities
9. EncountersNotifier updates state with profiles
10. UI rebuilds with profile cards
```

## Mock Data Integration

### randomuser.me API

**Endpoint**: `https://randomuser.me/api/`

**Parameters**:
- `results`: Number of profiles to fetch
- `gender`: Filter by gender (opposite of user)

**Mapping**:
```dart
ProfileModel.fromRandomUser(json) {
  name: json['name']['first'] + json['name']['last']
  age: json['dob']['age']
  photo: json['picture']['large']
  location: json['location']['city']
  // + random university, interests, relationship goal
}
```

## Theme System

### Color Scheme

**Light Theme**:
- Primary: #FF6B6B (Coral red)
- Secondary: #FFD93D (Yellow)
- Background: #FAFAFA (Light gray)
- Surface: #FFFFFF (White)

**Dark Theme**:
- Primary: #FF6B6B (Coral red)
- Secondary: #FFD93D (Yellow)
- Background: #121212 (Dark gray)
- Surface: #1E1E1E (Darker gray)

### Typography

- Font Family: Poppins (Google Fonts)
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

## Error Handling

### Failure Types

```dart
ServerFailure    → API/network errors
CacheFailure     → Local storage errors
NetworkFailure   → Connection errors
AuthFailure      → Authentication errors
ValidationFailure → Form validation errors
```

### Usage with Either

```dart
final result = await repository.login(email, password);

result.fold(
  (failure) => handleError(failure.message),
  (user) => handleSuccess(user),
);
```

## Future Enhancements

### Planned Features

1. **Chat Module**
   - WebSocket integration
   - Message models and repository
   - Chat UI with bubbles
   - Typing indicators
   - Read receipts

2. **Call Module**
   - Agora SDK integration
   - Call signaling
   - Call UI (mute, speaker, end)
   - Permission handling

3. **Nearby Module**
   - Location-based filtering
   - Distance calculation
   - Map integration

4. **Likes Module**
   - View who liked you
   - Match notifications
   - Lottie match animations

5. **Subscription**
   - Premium features
   - Payment integration
   - Unlimited swipes

## Best Practices Followed

1. ✅ Clean Architecture separation
2. ✅ Repository pattern
3. ✅ Dependency injection via Riverpod
4. ✅ Immutable entities with Equatable
5. ✅ Error handling with Either
6. ✅ Const constructors for performance
7. ✅ Reusable widgets
8. ✅ Responsive design
9. ✅ Theme consistency
10. ✅ Code organization by feature

## Testing Strategy

### Unit Tests
- Test repositories with mock data sources
- Test validators
- Test state notifiers

### Widget Tests
- Test individual widgets
- Test form validation
- Test navigation

### Integration Tests
- Test complete user flows
- Test API integration
- Test state persistence

## Performance Optimizations

1. **Image Caching**: CachedNetworkImage for profile pictures
2. **Lazy Loading**: Profiles loaded in batches
3. **Shimmer Loading**: Better perceived performance
4. **Const Widgets**: Reduced rebuilds
5. **Provider Scoping**: Efficient state management

## Security Considerations

1. **Token Storage**: flutter_secure_storage for auth tokens
2. **Input Validation**: All forms validated
3. **Error Messages**: Generic messages to prevent info leakage
4. **HTTPS**: All API calls use HTTPS (when integrated)

---

This architecture provides a solid foundation for scaling the app with additional features while maintaining code quality and testability.
