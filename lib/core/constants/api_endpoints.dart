/// API Endpoints - Single source of truth for all API URLs
class ApiEndpoints {
  // Base URL - should be loaded from environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.240.145:7000',
  );

  // Authentication
  static const String login = '/auth/jwt/create/';
  static const String register = '/auth/users/';
  static const String refreshToken = '/auth/jwt/refresh/';
  static const String updateFcmToken = '/auth/fcm-token/';

  // Universities (No authentication required)
  static const String universities = '/api/v1.0/profiles/universities/';
  static String universityBySlug(String slug) =>
      '/api/v1.0/profiles/universities/$slug/';

  // Users
  static const String currentUser = '/auth/users/me/';
  static String updateUser() => '/auth/users/me/';

  // Profiles
  static const String profiles = '/api/v1.0/profiles/profiles/';
  static String profileDetail(int id) => '/api/v1.0/profiles/profiles/$id/';
  static const String myProfile = '/api/v1.0/profiles/profiles/me/';

  static const String uploadProfilePhotos =
      '/api/v1.0/profiles/profiles/upload_photos/';

  // Gallery
  static const String gallery = '/api/v1.0/gallery/';
  static String deleteGalleryPhoto(int id) => '/api/gallery/$id/';

  // Interactions
  static const String matches = '/api/v1.0/interactions/matches/';
  static const String likes = '/api/v1.0/interactions/likes/';
  static const String profileViews = '/api/v1.0/profile-views/';

  // Chat
  static const String chatRooms = '/api/v1.0/chat/rooms/';
  static String chatRoomDetail(int id) => '/api/v1.0/chat/rooms/$id/';
  static String chatMessages(int roomId) =>
      '/api/v1.0/chat/rooms/$roomId/messages/'; // GET only - read messages
  static const String sendMessage =
      '/api/v1.0/chat/messages/'; // POST only - send message
  static String markMessageRead(int messageId) =>
      '/api/v1.0/chat/messages/$messageId/mark_read/';

  // WebSocket
  static String chatWebSocket(int roomId) => '/ws/chat/$roomId/';

  // Payments
  static const String subscriptions = '/api/v1.0/payments/subscriptions/';
  static const String transactions = '/api/v1.0/payments/transactions/';
  static String transactionDetail(int id) =>
      '/api/v1.0/payments/transactions/$id/';
}
