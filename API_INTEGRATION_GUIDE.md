# API Integration Guide

This guide explains how the DataDate app integrates with the Django backend API.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│              (UI, Widgets, Providers)                    │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                   Repository Layer                       │
│         (Business Logic, Error Handling)                 │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                  Data Source Layer                       │
│         (API Calls, Data Transformation)                 │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                     API Client                           │
│    (HTTP Client, Interceptors, Token Management)         │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### 1. API Client (`lib/core/network/api_client.dart`)

The `ApiClient` is a generic HTTP client built on top of Dio with:

- **Automatic token injection**: Reads JWT token from secure storage and adds to headers
- **Token refresh**: Automatically refreshes expired tokens on 401 errors
- **Error handling**: Converts HTTP errors to domain-specific failures
- **Request logging**: Logs all requests and responses for debugging
- **Generic methods**: GET, POST, PATCH, PUT, DELETE, and file upload

**Usage:**
```dart
final apiClient = ApiClient();

// GET request
final data = await apiClient.get<Map<String, dynamic>>('/api/users/me/');

// POST request
final response = await apiClient.post<Map<String, dynamic>>(
  '/auth/jwt/create/',
  data: {'email': 'user@example.com', 'password': 'password'},
);

// File upload
final formData = FormData.fromMap({
  'image': await MultipartFile.fromFile(imagePath),
});
final result = await apiClient.uploadFile('/api/gallery/', formData: formData);
```

### 2. API Endpoints (`lib/core/constants/api_endpoints.dart`)

Single source of truth for all API URLs. Never hardcode URLs in data sources.

**Usage:**
```dart
ApiEndpoints.login           // '/auth/jwt/create/'
ApiEndpoints.currentUser     // '/api/users/me/'
ApiEndpoints.profiles        // '/api/profiles/'
ApiEndpoints.profileDetail(5) // '/api/profiles/5/'
```

### 3. API Response Wrappers (`lib/core/network/api_response.dart`)

- **PaginatedResponse<T>**: For paginated list endpoints
- **ApiResponse<T>**: For single item responses
- **ApiError**: For error responses

**Usage:**
```dart
final response = await apiClient.get<Map<String, dynamic>>('/api/profiles/');
final paginated = PaginatedResponse.fromJson(
  response,
  (json) => ProfileModel.fromJson(json),
);

print(paginated.count);      // Total count
print(paginated.hasMore);    // Has next page?
print(paginated.results);    // List of profiles
```

### 4. WebSocket Service (`lib/core/network/websocket_service.dart`)

Real-time chat using WebSockets.

**Usage:**
```dart
final wsService = WebSocketService();

// Connect to chat room
await wsService.connect(roomId);

// Listen to messages
wsService.messages.listen((message) {
  if (message['type'] == 'chat_message') {
    print('New message: ${message['message']['content']}');
  }
});

// Send message
wsService.sendMessage('Hello!');

// Send typing indicator
wsService.sendTypingIndicator(true);

// Disconnect
wsService.disconnect();
```

## Feature Implementation

### Authentication

**Files:**
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/models/user_model.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`

**Flow:**
1. User enters credentials
2. `AuthNotifier.login()` called
3. `AuthRepository.login()` delegates to `AuthRemoteDataSource`
4. `AuthRemoteDataSource` calls API via `ApiClient`
5. Tokens stored in secure storage
6. User model returned and stored in state

**Example:**
```dart
// In UI
ref.read(authProvider.notifier).login(email, password);

// In data source
@override
Future<Map<String, String>> login(String email, String password) async {
  final response = await apiClient.post<Map<String, dynamic>>(
    ApiEndpoints.login,
    data: {'email': email, 'password': password},
  );
  
  return {
    'access': response['access'] as String,
    'refresh': response['refresh'] as String,
  };
}
```

### Profiles (Encounters)

**Files:**
- `lib/features/encounters/data/datasources/profile_remote_datasource.dart`
- `lib/features/encounters/data/models/profile_model.dart`
- `lib/features/encounters/presentation/providers/encounters_provider.dart`

**Features:**
- Fetch profiles with filters (gender, intent, university)
- Get profile details
- Like profiles
- Create profiles

**Example:**
```dart
// Fetch profiles
final profiles = await profileDataSource.getProfiles(
  gender: 'female',
  intent: 'dating',
  university: 1,
  page: 1,
);

// Like a profile
final result = await profileDataSource.likeProfile(profileId);
if (result['matched']) {
  // Show match animation
  showMatchDialog(result['match_id']);
}
```

### Chat

**Files:**
- `lib/features/chat/data/datasources/chat_remote_datasource.dart`
- `lib/features/chat/data/models/chat_room_model.dart`
- `lib/features/chat/data/models/message_model.dart`

**Features:**
- List chat rooms
- Get chat room details
- Fetch messages (paginated)
- Send messages (HTTP and WebSocket)
- Mark messages as read

**Example:**
```dart
// Get chat rooms
final rooms = await chatDataSource.getChatRooms();

// Get messages
final messages = await chatDataSource.getMessages(
  roomId: roomId,
  page: 1,
  pageSize: 50,
);

// Send message via HTTP
final message = await chatDataSource.sendMessage(
  roomId: roomId,
  content: 'Hello!',
);

// Real-time via WebSocket
final wsService = WebSocketService();
await wsService.connect(roomId);
wsService.sendMessage('Hello in real-time!');
```

### Interactions (Matches, Likes)

**Files:**
- `lib/features/interactions/data/datasources/interactions_remote_datasource.dart`
- `lib/features/interactions/data/models/match_model.dart`
- `lib/features/interactions/data/models/like_model.dart`
- `lib/features/interactions/data/models/profile_view_model.dart`

**Features:**
- Get matches
- Get likes (sent/received)
- Create likes
- Get profile views
- Record profile views

**Example:**
```dart
// Get matches
final matches = await interactionsDataSource.getMatches();

// Get received likes
final likes = await interactionsDataSource.getLikes(type: 'received');

// Record profile view
await interactionsDataSource.recordProfileView(viewedUserId);
```

### Gallery

**Files:**
- `lib/features/gallery/data/datasources/gallery_remote_datasource.dart`
- `lib/features/gallery/data/models/gallery_photo_model.dart`

**Features:**
- Get user's gallery photos
- Upload photos
- Delete photos

**Example:**
```dart
// Get photos
final photos = await galleryDataSource.getGalleryPhotos();

// Upload photo
final photo = await galleryDataSource.uploadPhoto(
  imagePath: '/path/to/image.jpg',
  order: 1,
);

// Delete photo
await galleryDataSource.deletePhoto(photoId);
```

## Error Handling

All API errors are converted to domain failures:

- **NetworkFailure**: Connection issues, timeouts
- **ServerFailure**: 500, 502, 503 errors
- **AuthFailure**: 401, 403 errors
- **ValidationFailure**: 400 errors with validation details

**Usage:**
```dart
final result = await repository.login(email, password);

result.fold(
  (failure) {
    if (failure is AuthFailure) {
      showError('Invalid credentials');
    } else if (failure is NetworkFailure) {
      showError('No internet connection');
    } else {
      showError(failure.message);
    }
  },
  (user) {
    navigateToHome();
  },
);
```

## Environment Configuration

Set the API base URL via environment variable:

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Production
flutter run --dart-define=API_BASE_URL=https://api.datadate.com
```

Or use `.env` files with `flutter_dotenv`:

```env
# .env.development
API_BASE_URL=http://localhost:8000

# .env.production
API_BASE_URL=https://api.datadate.com
```

## Testing

### Mock Data Sources

For testing without backend:

```dart
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<List<ProfileModel>> getProfiles({...}) async {
    return [
      ProfileModel(id: '1', name: 'Test User', ...),
    ];
  }
}
```

### Integration Tests

```dart
void main() {
  late ApiClient apiClient;
  late ProfileRemoteDataSource dataSource;

  setUp(() {
    apiClient = ApiClient();
    dataSource = ProfileRemoteDataSourceImpl(apiClient: apiClient);
  });

  test('should fetch profiles', () async {
    final profiles = await dataSource.getProfiles(gender: 'female');
    expect(profiles, isNotEmpty);
  });
}
```

## Best Practices

1. **Never hardcode URLs**: Always use `ApiEndpoints`
2. **Use ApiClient**: Don't create Dio instances directly
3. **Handle errors**: Always use Either<Failure, T> in repositories
4. **Separate concerns**: Keep data sources, repositories, and UI separate
5. **Mock for testing**: Create mock implementations for testing
6. **Log requests**: Use ApiClient's built-in logging
7. **Secure tokens**: Always use FlutterSecureStorage for tokens
8. **Refresh tokens**: Let ApiClient handle token refresh automatically
9. **Paginate lists**: Use PaginatedResponse for list endpoints
10. **Real-time updates**: Use WebSocket for chat, HTTP for everything else

## Troubleshooting

### Token not being sent
- Check if token is stored in secure storage
- Verify ApiClient is using the correct storage key
- Check interceptor is adding Authorization header

### 401 errors
- Token might be expired
- Check if refresh token is valid
- Verify token refresh logic in ApiClient

### Connection errors
- Check base URL configuration
- Verify network connectivity
- Check if backend is running

### WebSocket not connecting
- Verify WebSocket URL format (wss:// for HTTPS)
- Check if token is being passed as query parameter
- Verify backend WebSocket endpoint is accessible

## Next Steps

1. Implement remaining features (payments, subscriptions)
2. Add offline support with local caching
3. Implement retry logic for failed requests
4. Add request queuing for offline mode
5. Implement push notifications
6. Add analytics and crash reporting
