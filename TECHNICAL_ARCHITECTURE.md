# DataDate - Technical Architecture

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│  Flutter UI Components & Pages                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │   Auth UI   │ │Encounters UI│ │   Chat UI   │ │ Profile UI  ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │  Reels UI   │ │  Likes UI   │ │Onboarding UI│ │  Core UI    ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
├─────────────────────────────────────────────────────────────────┤
│                      STATE MANAGEMENT                          │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Riverpod Providers                             ││
│  │  AuthProvider │ ChatProvider │ ProfileProvider │ etc.       ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        BUSINESS LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Domain Entities & Use Cases                                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │    User     │ │   Profile   │ │   Message   │ │    Match    ││
│  │   Entity    │ │   Entity    │ │   Entity    │ │   Entity    ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Repository Interfaces                         ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  Repository Implementations                                    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Data Sources                                   ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           ││
│  │  │   Remote    │ │    Local    │ │  WebSocket  │           ││
│  │  │ DataSource  │ │ DataSource  │ │ DataSource  │           ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘           ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       EXTERNAL SERVICES                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │  REST API   │ │  WebSocket  │ │Local Storage│ │  Analytics  ││
│  │   Server    │ │   Server    │ │   (SQLite)  │ │   Service   ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Architecture

### Request Flow
```
UI Widget → Provider → Repository → DataSource → API/Local Storage
                ↓
UI Update ← State Change ← Response ← Data Processing ← Response
```

### Real-time Flow (Chat)
```
WebSocket Server → WebSocket Service → Chat Provider → UI Update
                                    ↓
Local Cache ← Message Processing ← Real-time Event
```

## 🏛️ Feature Architecture

### Authentication Feature
```
auth/
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── splash_page.dart
│   └── providers/
│       └── auth_provider.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   └── repositories/
│       └── auth_repository.dart
└── data/
    ├── models/
    │   └── user_model.dart
    ├── repositories/
    │   └── auth_repository_impl.dart
    └── datasources/
        ├── auth_remote_datasource.dart
        └── auth_local_datasource.dart
```

### Chat Feature Architecture
```
chat/
├── presentation/
│   ├── pages/
│   │   ├── chat_page.dart
│   │   └── chat_detail_page.dart
│   ├── widgets/
│   │   ├── message_bubble.dart
│   │   ├── typing_indicator.dart
│   │   └── chat_input.dart
│   └── providers/
│       ├── chat_provider.dart
│       └── chat_detail_provider.dart
├── domain/
│   ├── entities/
│   │   ├── message.dart
│   │   └── chat_room.dart
│   └── repositories/
│       └── chat_repository.dart
└── data/
    ├── models/
    │   ├── message_model.dart
    │   └── chat_room_model.dart
    ├── repositories/
    │   └── chat_repository_impl.dart
    ├── datasources/
    │   └── chat_remote_datasource.dart
    └── services/
        └── chat_local_storage_service.dart
```

## 🔧 Core Services Architecture

### Service Layer
```
core/services/
├── analytics_service.dart      # User behavior tracking
├── connectivity_service.dart   # Network monitoring
├── image_cache_service.dart    # Image optimization
├── logout_service.dart         # Secure logout
├── message_queue_service.dart  # Message queuing
├── offline_data_manager.dart   # Offline functionality
├── performance_service.dart    # Performance monitoring
└── state_persistence_service.dart # State management
```

### Network Layer
```
core/network/
├── api_client.dart            # HTTP client configuration
├── api_response.dart          # Response wrapper
└── websocket_service.dart     # Real-time communication
```

### Utility Layer
```
core/utils/
├── date_time_utils.dart       # Date formatting
├── validators.dart            # Input validation
├── accessibility_utils.dart   # Accessibility helpers
└── environments.dart          # Environment configuration
```

## 📱 UI Architecture

### Widget Hierarchy
```
MaterialApp
├── GoRouter (Navigation)
├── Theme Provider (Dark/Light Mode)
├── Connectivity Provider (Network Status)
└── Main Navigation
    ├── Encounters Page
    ├── Chat Page
    ├── Reels Page
    ├── Likes Page
    └── Profile Page
```

### Component Structure
```
Custom Widgets/
├── Buttons/
│   ├── custom_button.dart
│   └── animated_action_button.dart
├── Forms/
│   ├── custom_text_field.dart
│   └── password_error_bottom_sheet.dart
├── Loading/
│   ├── loading_indicator.dart
│   ├── loading_shimmer.dart
│   └── adaptive_loading_state.dart
├── Navigation/
│   ├── main_navigation.dart
│   └── theme_toggle_button.dart
└── Feedback/
    ├── custom_snackbar.dart
    ├── error_widget.dart
    └── connectivity_indicator.dart
```

## 🔄 State Management Flow

### Riverpod Provider Pattern
```dart
// Provider Definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// State Class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  
  AuthState({this.user, this.isLoading = false, this.error});
}

// Notifier Class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  AuthNotifier(this._repository) : super(AuthState());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

## 🌐 API Integration Architecture

### HTTP Client Configuration
```dart
class ApiClient {
  final Dio _dio;
  
  ApiClient() : _dio = Dio() {
    _dio.interceptors.addAll([
      AuthInterceptor(),      // JWT token handling
      LoggingInterceptor(),   // Request/response logging
      ErrorInterceptor(),     // Error handling
      RetryInterceptor(),     // Retry logic
    ]);
  }
}
```

### WebSocket Integration
```dart
class WebSocketService {
  late WebSocketChannel _channel;
  
  void connect(String url, String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$url?token=$token'),
    );
    
    _channel.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
  }
  
  void _handleMessage(dynamic message) {
    final data = jsonDecode(message);
    switch (data['type']) {
      case 'message':
        _chatController.add(MessageModel.fromJson(data));
        break;
      case 'typing':
        _typingController.add(TypingEvent.fromJson(data));
        break;
    }
  }
}
```

## 🗄️ Data Storage Architecture

### Local Storage Strategy
```
Local Storage/
├── Secure Storage (Credentials)
│   ├── JWT Tokens
│   ├── User Credentials
│   └── Sensitive Settings
├── SQLite Database (App Data)
│   ├── Cached Profiles
│   ├── Chat Messages
│   ├── User Preferences
│   └── Offline Data
└── Shared Preferences (Settings)
    ├── Theme Preferences
    ├── App Settings
    └── User Preferences
```

### Caching Strategy
```dart
class CacheManager {
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  Future<T?> getCached<T>(String key) async {
    final cached = await _storage.read(key);
    if (cached != null) {
      final data = CachedData.fromJson(jsonDecode(cached));
      if (data.isExpired) {
        await _storage.delete(key);
        return null;
      }
      return data.value as T;
    }
    return null;
  }
  
  Future<void> cache<T>(String key, T data) async {
    final cachedData = CachedData(
      value: data,
      timestamp: DateTime.now(),
      expiry: _cacheExpiry,
    );
    await _storage.write(key, jsonEncode(cachedData.toJson()));
  }
}
```

## 🔒 Security Architecture

### Authentication Flow
```
1. User Login → JWT Token Generation
2. Token Storage → Secure Storage
3. API Requests → Token Injection
4. Token Refresh → Automatic Renewal
5. Logout → Token Invalidation + Data Cleanup
```

### Data Protection
```dart
class SecurityService {
  // Encrypt sensitive data
  static String encrypt(String data) {
    return _encryptionService.encrypt(data);
  }
  
  // Validate input data
  static bool validateInput(String input, InputType type) {
    return _validators[type]?.call(input) ?? false;
  }
  
  // Sanitize user input
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>\"\'%;()&+]'), '');
  }
}
```

## 📊 Performance Architecture

### Optimization Strategies
```
Performance Optimizations/
├── Image Optimization
│   ├── Cached Network Images
│   ├── Image Compression
│   └── Lazy Loading
├── Memory Management
│   ├── Widget Disposal
│   ├── Stream Cleanup
│   └── Cache Limits
├── Network Optimization
│   ├── Request Batching
│   ├── Response Caching
│   └── Connection Pooling
└── UI Optimization
    ├── Widget Rebuilds
    ├── Animation Performance
    └── List Virtualization
```

### Monitoring & Analytics
```dart
class PerformanceService {
  static void trackPageLoad(String pageName, Duration loadTime) {
    AnalyticsService.logEvent('page_load', {
      'page_name': pageName,
      'load_time_ms': loadTime.inMilliseconds,
    });
  }
  
  static void trackAPICall(String endpoint, Duration responseTime) {
    AnalyticsService.logEvent('api_call', {
      'endpoint': endpoint,
      'response_time_ms': responseTime.inMilliseconds,
    });
  }
}
```

## 🚀 Deployment Architecture

### Build Configuration
```
Build Environments/
├── Development
│   ├── Debug Mode
│   ├── Local API
│   └── Verbose Logging
├── Staging
│   ├── Profile Mode
│   ├── Staging API
│   └── Limited Logging
└── Production
    ├── Release Mode
    ├── Production API
    └── Error Logging Only
```

### CI/CD Pipeline
```yaml
# GitHub Actions Workflow
name: Build and Deploy
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - run: flutter build ios --release
```

This technical architecture provides a comprehensive view of how the DataDate application is structured and how its components interact with each other.