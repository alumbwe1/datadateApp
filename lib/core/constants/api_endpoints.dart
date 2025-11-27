/// API Endpoints - Single source of truth for all API URLs
class ApiEndpoints {
  // Base URL - should be loaded from environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:7000',
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
  static const String discoverProfiles = '/api/v1.0/profiles/discover/';

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
  static String editMessage(int messageId) =>
      '/api/v1.0/chat/messages/$messageId/';
  static String deleteMessage(int messageId) =>
      '/api/v1.0/chat/messages/$messageId/';

  // WebSocket
  static String chatWebSocket(int roomId) => '/ws/chat/$roomId/';

  // Payments
  static const String subscriptions = '/api/v1.0/payments/subscriptions/';
  static const String transactions = '/api/v1.0/payments/transactions/';
  static String transactionDetail(int id) =>
      '/api/v1.0/payments/transactions/$id/';

  // System Configuration
  static const String systemStatus = '/api/v1.0/profiles/system/status/';
  static const String systemConfig = '/api/v1.0/profiles/system-config/';
  static String updateSystemConfig(int id) =>
      '/api/v1.0/profiles/system-config/$id/';
  static const String setTrialMode =
      '/api/v1.0/profiles/system-config/set_trial_mode/';
  static const String setActiveMode =
      '/api/v1.0/profiles/system-config/set_active_mode/';
  static const String setMaintenanceMode =
      '/api/v1.0/profiles/system-config/set_maintenance_mode/';
  static const String toggleFeature =
      '/api/v1.0/profiles/system-config/toggle_feature/';

  // Profile Boost
  static const String boostPricing = '/api/v1.0/profiles/boosts/pricing/';
  static const String createBoost = '/api/v1.0/profiles/boosts/';
  static String activateBoost(int id) =>
      '/api/v1.0/profiles/boosts/$id/activate/';
  static const String activeBoost = '/api/v1.0/profiles/boosts/active/';
  static const String boostHistory = '/api/v1.0/profiles/boosts/history/';

  // Advanced Discovery
  static const String discover = '/api/v1.0/profiles/discover/';
  static const String discoverRecommended =
      '/api/v1.0/profiles/discover/recommended/';
  static const String discoverNearby = '/api/v1.0/profiles/discover/nearby/';
  static const String discoverStudents =
      '/api/v1.0/profiles/discover/students/';
  static const String discoverBoosted = '/api/v1.0/profiles/discover/boosted/';

  // Blocking & Reporting
  static const String blockedUsers = '/api/v1.0/profiles/blocked-users/';
  static String unblockUser(int id) => '/api/v1.0/profiles/blocked-users/$id/';
  static const String checkBlockStatus =
      '/api/v1.0/profiles/blocked-users/check/';
  static const String reports = '/api/v1.0/profiles/reports/';
  static const String myReports = '/api/v1.0/profiles/reports/my_reports/';
  static const String pendingReports = '/api/v1.0/profiles/reports/pending/';
  static String resolveReport(int id) =>
      '/api/v1.0/profiles/reports/$id/resolve/';
  static String dismissReport(int id) =>
      '/api/v1.0/profiles/reports/$id/dismiss/';

  // Crush Messages
  static const String crushMessages = '/api/v1.0/interactions/crush-messages/';
  static const String sentCrushMessages =
      '/api/v1.0/interactions/crush-messages/sent/';
  static const String receivedCrushMessages =
      '/api/v1.0/interactions/crush-messages/received/';
  static const String pendingCrushMessages =
      '/api/v1.0/interactions/crush-messages/pending/';
  static String markCrushMessageRead(int id) =>
      '/api/v1.0/interactions/crush-messages/$id/mark_read/';
  static String respondToCrushMessage(int id) =>
      '/api/v1.0/interactions/crush-messages/$id/respond/';

  // Likes - Additional endpoints
  static const String receivedLikes = '/api/v1.0/interactions/likes/received/';
  static String unlikeUser(int id) => '/api/v1.0/interactions/likes/$id/';

  // Profile Views - Additional endpoints
  static const String receivedProfileViews =
      '/api/v1.0/interactions/profile-views/received/';
}
