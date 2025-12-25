# DataDate - Developer Quick Reference

## 🚀 Quick Start Commands

### Development Setup
```bash
# Clone and setup
git clone <repository-url>
cd datadate
flutter pub get

# Run development
flutter run --debug
flutter run --flavor development

# Build for testing
flutter build apk --debug
flutter build ios --debug
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📁 Project Structure Quick Reference

```
lib/
├── main.dart                           # App entry point
├── core/                              # Shared components
│   ├── constants/                     # App constants
│   │   ├── api_endpoints.dart         # API URLs
│   │   ├── app_colors.dart           # Color palette
│   │   └── app_constants.dart        # General constants
│   ├── network/                      # Network layer
│   │   ├── api_client.dart           # HTTP client
│   │   ├── api_response.dart         # Response wrapper
│   │   └── websocket_service.dart    # WebSocket client
│   ├── services/                     # Core services
│   │   ├── analytics_service.dart    # Analytics
│   │   ├── logout_service.dart       # Secure logout
│   │   └── connectivity_service.dart # Network monitoring
│   ├── widgets/                      # Reusable widgets
│   │   ├── custom_button.dart        # Themed buttons
│   │   ├── custom_text_field.dart    # Input fields
│   │   └── loading_indicator.dart    # Loading states
│   ├── providers/                    # Global providers
│   │   ├── theme_provider.dart       # Theme management
│   │   └── connectivity_provider.dart # Network status
│   ├── router/                       # Navigation
│   │   └── app_router.dart           # Route configuration
│   └── utils/                        # Utilities
│       ├── validators.dart           # Input validation
│       └── date_time_utils.dart      # Date formatting
└── features/                         # Feature modules
    ├── auth/                         # Authentication
    ├── onboarding/                   # User onboarding
    ├── encounters/                   # Swiping feature
    ├── chat/                         # Messaging
    ├── profile/                      # User profiles
    ├── likes/                        # Like management
    ├── reels/                        # Video content
    └── universities/                 # University data
```

## 🔧 Common Development Patterns

### Creating a New Feature
```bash
# 1. Create feature directory structure
mkdir -p lib/features/new_feature/{data,domain,presentation}
mkdir -p lib/features/new_feature/data/{datasources,models,repositories}
mkdir -p lib/features/new_feature/domain/{entities,repositories}
mkdir -p lib/features/new_feature/presentation/{pages,widgets,providers}

# 2. Create basic files
touch lib/features/new_feature/data/models/new_feature_model.dart
touch lib/features/new_feature/domain/entities/new_feature.dart
touch lib/features/new_feature/presentation/providers/new_feature_provider.dart
```

### Provider Pattern Template
```dart
// State class
class FeatureState {
  final List<Item> items;
  final bool isLoading;
  final String? error;
  
  const FeatureState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
  
  FeatureState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return FeatureState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider definition
final featureProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) {
  return FeatureNotifier(ref.read(featureRepositoryProvider));
});

// Notifier class
class FeatureNotifier extends StateNotifier<FeatureState> {
  final FeatureRepository _repository;
  
  FeatureNotifier(this._repository) : super(const FeatureState());
  
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repository.getItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### API Integration Template
```dart
// Remote data source
class FeatureRemoteDataSource {
  final ApiClient _apiClient;
  
  FeatureRemoteDataSource(this._apiClient);
  
  Future<List<FeatureModel>> getFeatures() async {
    final response = await _apiClient.get('/api/v1.0/features/');
    return (response.data['results'] as List)
        .map((json) => FeatureModel.fromJson(json))
        .toList();
  }
  
  Future<FeatureModel> createFeature(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/v1.0/features/', data: data);
    return FeatureModel.fromJson(response.data);
  }
}

// Repository implementation
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureRemoteDataSource _remoteDataSource;
  final FeatureLocalDataSource _localDataSource;
  
  FeatureRepositoryImpl(this._remoteDataSource, this._localDataSource);
  
  @override
  Future<List<Feature>> getFeatures() async {
    try {
      final features = await _remoteDataSource.getFeatures();
      await _localDataSource.cacheFeatures(features);
      return features.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to cached data
      final cachedFeatures = await _localDataSource.getCachedFeatures();
      return cachedFeatures.map((model) => model.toEntity()).toList();
    }
  }
}
```

## 🎨 UI Development Quick Reference

### Theme Usage
```dart
// Access theme colors
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final primaryColor = Theme.of(context).primaryColor;
final backgroundColor = isDarkMode ? Colors.black : Colors.white;

// Custom app style
Text(
  'Hello World',
  style: appStyle(16, Colors.black, FontWeight.w600),
)

// Responsive sizing
Container(
  width: 200.w,  // 200 logical pixels
  height: 100.h, // 100 logical pixels
  padding: EdgeInsets.all(16.r), // 16 radius
)
```

### Common Widget Patterns
```dart
// Loading state
if (state.isLoading)
  const Center(child: LottieLoadingIndicator())
else if (state.error != null)
  CustomErrorWidget(
    message: state.error!,
    onRetry: () => ref.read(provider.notifier).retry(),
  )
else
  // Content widget

// Empty state
if (items.isEmpty)
  const EmptyStateWidget(
    title: 'No Items',
    subtitle: 'Add some items to get started',
    actionText: 'Add Item',
    onAction: _addItem,
  )

// Shimmer loading
ListView.builder(
  itemCount: 10,
  itemBuilder: (context, index) => const ShimmerLoadingCard(),
)
```

### Navigation Patterns
```dart
// Go to page
context.go('/profile');
context.push('/edit-profile');

// Navigate with data
context.pushNamed('chat-detail', extra: {'roomId': roomId});

// Replace current page
context.go('/login');

// Pop with result
Navigator.of(context).pop(result);
```

## 🔌 API Quick Reference

### Authentication Headers
```dart
// Add to all authenticated requests
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

### Common API Endpoints
```dart
class ApiEndpoints {
  // Auth
  static const login = '/api/v1.0/auth/login/';
  static const register = '/api/v1.0/auth/register/';
  static const refresh = '/api/v1.0/auth/refresh/';
  
  // Profiles
  static const profiles = '/api/v1.0/encounters/profiles/';
  static const like = '/api/v1.0/encounters/like/';
  static const pass = '/api/v1.0/encounters/pass/';
  
  // Chat
  static const chatRooms = '/api/v1.0/chat/rooms/';
  static const messages = '/api/v1.0/chat/messages/';
  static String chatRoom(int id) => '/api/v1.0/chat/rooms/$id/';
  
  // WebSocket
  static String chatWebSocket(int roomId) => '/ws/chat/$roomId/';
}
```

### Error Handling Pattern
```dart
try {
  final result = await apiCall();
  return result;
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Token expired, refresh and retry
    await _refreshToken();
    return await apiCall();
  } else if (e.response?.statusCode == 404) {
    throw NotFoundException('Resource not found');
  } else {
    throw ApiException('API call failed: ${e.message}');
  }
} catch (e) {
  throw UnknownException('Unexpected error: $e');
}
```

## 🧪 Testing Quick Reference

### Unit Test Template
```dart
void main() {
  group('FeatureNotifier', () {
    late FeatureNotifier notifier;
    late MockFeatureRepository mockRepository;
    
    setUp(() {
      mockRepository = MockFeatureRepository();
      notifier = FeatureNotifier(mockRepository);
    });
    
    test('should load items successfully', () async {
      // Arrange
      final items = [Item(id: 1, name: 'Test')];
      when(() => mockRepository.getItems()).thenAnswer((_) async => items);
      
      // Act
      await notifier.loadItems();
      
      // Assert
      expect(notifier.state.items, equals(items));
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
    });
  });
}
```

### Widget Test Template
```dart
void main() {
  testWidgets('should display items correctly', (tester) async {
    // Arrange
    final items = [Item(id: 1, name: 'Test Item')];
    
    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsProvider.overrideWith((ref) => items),
        ],
        child: MaterialApp(home: ItemsPage()),
      ),
    );
    
    // Assert
    expect(find.text('Test Item'), findsOneWidget);
    expect(find.byType(ItemCard), findsOneWidget);
  });
}
```

## 🔍 Debugging Tips

### Common Debug Commands
```dart
// Print debug info
debugPrint('Debug message: $variable');

// Log network requests
curl -X POST https://api.example.com/endpoint \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'

// Check widget tree
flutter inspector

// Performance profiling
flutter run --profile
```

### Common Issues & Solutions

#### State Not Updating
```dart
// ❌ Wrong - mutating state directly
state.items.add(newItem);

// ✅ Correct - creating new state
state = state.copyWith(items: [...state.items, newItem]);
```

#### Memory Leaks
```dart
// ❌ Wrong - not disposing controllers
class _PageState extends State<Page> {
  final controller = TextEditingController();
}

// ✅ Correct - proper disposal
class _PageState extends State<Page> {
  late final TextEditingController controller;
  
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

#### WebSocket Connection Issues
```dart
// Check connection status
if (_channel.closeCode != null) {
  // Connection closed, attempt reconnect
  _reconnect();
}

// Handle connection errors
_channel.stream.listen(
  _handleMessage,
  onError: (error) {
    debugPrint('WebSocket error: $error');
    _handleConnectionError(error);
  },
  onDone: () {
    debugPrint('WebSocket connection closed');
    _handleDisconnection();
  },
);
```

## 📦 Build & Deployment

### Build Commands
```bash
# Debug builds
flutter build apk --debug
flutter build ios --debug

# Release builds
flutter build apk --release
flutter build ios --release
flutter build web --release

# Build with flavor
flutter build apk --flavor production --release
```

### Environment Configuration
```dart
// .env files
.env.development    # Development environment
.env.staging       # Staging environment
.env.production    # Production environment

// Access environment variables
final apiUrl = Environment.apiUrl;
final isDebug = Environment.isDebug;
```

### Performance Optimization
```bash
# Analyze bundle size
flutter build apk --analyze-size

# Profile performance
flutter run --profile

# Check for unused dependencies
flutter deps
```

This quick reference provides the most commonly used patterns, commands, and solutions for developing the DataDate application efficiently.