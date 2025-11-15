# API Quick Reference Card

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run with development API
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Run with production API
flutter run --dart-define=API_BASE_URL=https://api.datadate.com
```

## 📦 Core Imports

```dart
// API Client
import 'package:datadate/core/providers/api_providers.dart';
import 'package:datadate/core/network/api_client.dart';
import 'package:datadate/core/constants/api_endpoints.dart';

// Response wrappers
import 'package:datadate/core/network/api_response.dart';

// WebSocket
import 'package:datadate/core/network/websocket_service.dart';
```

## 🔌 Using API Client

### In Provider
```dart
final myDataSourceProvider = Provider<MyDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MyDataSourceImpl(apiClient: apiClient);
});
```

### In Data Source
```dart
class MyDataSourceImpl implements MyDataSource {
  final ApiClient apiClient;
  
  MyDataSourceImpl({required this.apiClient});
  
  @override
  Future<MyModel> getData() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.myEndpoint,
    );
    return MyModel.fromJson(response);
  }
}
```

## 📡 HTTP Methods

### GET
```dart
final data = await apiClient.get<Map<String, dynamic>>(
  '/api/endpoint/',
  queryParameters: {'page': 1, 'filter': 'value'},
);
```

### POST
```dart
final response = await apiClient.post<Map<String, dynamic>>(
  '/api/endpoint/',
  data: {'key': 'value'},
);
```

### PATCH
```dart
final updated = await apiClient.patch<Map<String, dynamic>>(
  '/api/endpoint/1/',
  data: {'field': 'new_value'},
);
```

### DELETE
```dart
await apiClient.delete('/api/endpoint/1/');
```

### File Upload
```dart
final formData = FormData.fromMap({
  'image': await MultipartFile.fromFile(imagePath),
  'field': 'value',
});

final result = await apiClient.uploadFile<Map<String, dynamic>>(
  '/api/endpoint/',
  formData: formData,
);
```

## 🔄 Pagination

```dart
final response = await apiClient.get<Map<String, dynamic>>(
  ApiEndpoints.profiles,
  queryParameters: {'page': 1},
);

final paginated = PaginatedResponse.fromJson(
  response,
  (json) => ProfileModel.fromJson(json),
);

print(paginated.count);      // Total items
print(paginated.hasMore);    // Has next page?
print(paginated.results);    // Current page items
```

## 💬 WebSocket (Chat)

```dart
// Get service
final wsService = ref.watch(webSocketServiceProvider);

// Connect
await wsService.connect(roomId);

// Listen to messages
wsService.messages.listen((message) {
  switch (message['type']) {
    case 'chat_message':
      handleNewMessage(message['message']);
      break;
    case 'typing':
      handleTyping(message['user_id'], message['is_typing']);
      break;
    case 'message_read':
      handleReadReceipt(message['message_id']);
      break;
  }
});

// Send message
wsService.sendMessage('Hello!');

// Typing indicator
wsService.sendTypingIndicator(true);

// Mark as read
wsService.markAsRead(messageId);

// Disconnect
wsService.disconnect();
```

## 🔐 Authentication

### Login
```dart
final tokens = await authDataSource.login(email, password);
// Tokens automatically stored by ApiClient
```

### Get Current User
```dart
final user = await authDataSource.getCurrentUser();
```

### Logout
```dart
await apiClient.clearTokens();
```

## 🎯 Common Endpoints

```dart
// Auth
ApiEndpoints.login                    // POST /auth/jwt/create/
ApiEndpoints.register                 // POST /auth/users/
ApiEndpoints.refreshToken             // POST /auth/jwt/refresh/

// Users
ApiEndpoints.currentUser              // GET /api/users/me/
ApiEndpoints.updateUser()             // PATCH /api/users/me/

// Profiles
ApiEndpoints.profiles                 // GET /api/profiles/
ApiEndpoints.profileDetail(id)        // GET /api/profiles/{id}/
ApiEndpoints.likeProfile(id)          // POST /api/profiles/{id}/like/

// Chat
ApiEndpoints.chatRooms                // GET /api/chat/rooms/
ApiEndpoints.chatMessages(roomId)     // GET /api/chat/rooms/{id}/messages/
ApiEndpoints.chatWebSocket(roomId)    // WS /ws/chat/{id}/

// Interactions
ApiEndpoints.matches                  // GET /api/matches/
ApiEndpoints.likes                    // GET /api/likes/
ApiEndpoints.profileViews             // GET /api/profile-views/

// Gallery
ApiEndpoints.gallery                  // GET/POST /api/gallery/
ApiEndpoints.deleteGalleryPhoto(id)   // DELETE /api/gallery/{id}/
```

## ⚠️ Error Handling

```dart
try {
  final data = await apiClient.get('/api/endpoint/');
  // Handle success
} on NetworkFailure catch (e) {
  // No internet or timeout
  showError('Check your connection');
} on AuthFailure catch (e) {
  // 401/403 - redirect to login
  navigateToLogin();
} on ValidationFailure catch (e) {
  // 400 - show validation errors
  showError(e.message);
} on ServerFailure catch (e) {
  // 500+ - server error
  showError('Server error, try again');
} catch (e) {
  // Unknown error
  showError('Something went wrong');
}
```

## 📝 Model Mapping

### From JSON
```dart
class MyModel {
  final int id;
  final String name;
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
```

### To JSON
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
  };
}
```

### Update JSON (PATCH)
```dart
Map<String, dynamic> toUpdateJson({String? name}) {
  final data = <String, dynamic>{};
  if (name != null) data['name'] = name;
  return data;
}
```

## 🧪 Testing

### Mock Data Source
```dart
class MockMyDataSource implements MyDataSource {
  @override
  Future<MyModel> getData() async {
    return MyModel(id: 1, name: 'Test');
  }
}
```

### Test with Mock
```dart
void main() {
  test('should fetch data', () async {
    final dataSource = MockMyDataSource();
    final result = await dataSource.getData();
    expect(result.name, 'Test');
  });
}
```

## 🎨 UI Integration

### With Riverpod
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    
    return state.when(
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
      data: (data) => Text('Data: $data'),
    );
  }
}
```

### Manual Loading
```dart
Future<void> loadData() async {
  setState(() => isLoading = true);
  
  try {
    final data = await dataSource.getData();
    setState(() {
      this.data = data;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}
```

## 🔧 Debugging

### Enable Logging
ApiClient automatically logs all requests/responses:
```
🌐 REQUEST[POST] => https://api.datadate.com/auth/jwt/create/
📦 Data: {email: user@example.com, password: ****}
✅ RESPONSE[200] => https://api.datadate.com/auth/jwt/create/
```

### Check Token
```dart
final token = await secureStorage.read(key: AppConstants.keyAuthToken);
print('Token: $token');
```

### Test Endpoint
```dart
final response = await apiClient.get('/api/test/');
print(response);
```

## 📚 Resources

- **Full Guide**: `API_INTEGRATION_GUIDE.md`
- **Implementation**: `API_IMPLEMENTATION_SUMMARY.md`
- **API Spec**: `API_DATA_FORMATS.md`
- **Project Structure**: `PROJECT_STRUCTURE.md`

## 🆘 Common Issues

### "No authentication token"
- User not logged in
- Token expired and refresh failed
- Check secure storage

### "Connection timeout"
- Backend not running
- Wrong base URL
- Network issues

### "401 Unauthorized"
- Token expired
- Invalid token
- Check token refresh logic

### "WebSocket connection failed"
- Wrong WebSocket URL format
- Token not passed correctly
- Backend WebSocket not configured

## 💡 Pro Tips

1. Always use `ApiEndpoints` for URLs
2. Let `ApiClient` handle token management
3. Use `PaginatedResponse` for lists
4. Handle all error types
5. Test with mock data first
6. Use WebSocket for real-time features
7. Log requests during development
8. Clear tokens on logout
9. Validate data before sending
10. Use FormData for file uploads
