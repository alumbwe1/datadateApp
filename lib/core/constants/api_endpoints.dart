/// API Endpoints - Single source of truth for all API URLs
class ApiEndpoints {
  // Base URL - should be loaded from environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:7000',
  );

  // Authentication
  static const String login = '/auth/jwt/create/';
  static const String register = '/auth/users/';
  static const String refreshToken = '/auth/jwt/refresh/';

  // Universities (No authentication required)
  static const String universities = '/api/universities/';
  static String universityBySlug(String slug) => '/api/universities/$slug/';

  // Users
  static const String currentUser = '/api/users/me/';
  static String updateUser() => '/api/users/me/';

  // Profiles
  static const String profiles = '/api/profiles/';
  static String profileDetail(int id) => '/api/profiles/$id/';
  static String likeProfile(int id) => '/api/profiles/$id/like/';

  // Gallery
  static const String gallery = '/api/gallery/';
  static String deleteGalleryPhoto(int id) => '/api/gallery/$id/';

  // Interactions
  static const String matches = '/api/matches/';
  static const String likes = '/api/likes/';
  static const String profileViews = '/api/profile-views/';

  // Chat
  static const String chatRooms = '/api/chat/rooms/';
  static String chatRoomDetail(int id) => '/api/chat/rooms/$id/';
  static String chatMessages(int roomId) => '/api/chat/rooms/$roomId/messages/';
  static String markMessageRead(int messageId) =>
      '/api/chat/messages/$messageId/mark_read/';

  // WebSocket
  static String chatWebSocket(int roomId) => '/ws/chat/$roomId/';

  // Payments
  static const String subscriptions = '/api/payments/subscriptions/';
  static const String transactions = '/api/payments/transactions/';
  static String transactionDetail(int id) => '/api/payments/transactions/$id/';
}
