import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/chat/data/models/chat_room_model.dart';
import '../../features/chat/data/models/message_model.dart';
import '../../features/encounters/data/models/profile_model.dart';
import '../../features/interactions/data/models/match_model.dart';
import '../utils/custom_logs.dart';

class OfflineDataService {
  static const String _profilesKey = 'cached_profiles';
  static const String _matchesKey = 'cached_matches';
  static const String _chatRoomsKey = 'cached_chat_rooms';
  static const String _messagesKeyPrefix = 'cached_messages_';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Profile caching
  static Future<void> saveProfiles(List<ProfileModel> profiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = profiles.map((profile) => profile.toJson()).toList();
      await prefs.setString(_profilesKey, jsonEncode(profilesJson));
      await _updateLastSync();
    } catch (e) {
      CustomLogs.info('❌ Error saving profiles: $e');
    }
  }

  static Future<List<ProfileModel>> getCachedProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getString(_profilesKey);
      if (profilesJson == null) return [];

      final List<dynamic> profilesList = jsonDecode(profilesJson);
      return profilesList.map((json) => ProfileModel.fromJson(json)).toList();
    } catch (e) {
      CustomLogs.info('❌ Error loading cached profiles: $e');
      return [];
    }
  }

  // Matches caching
  static Future<void> saveMatches(List<MatchModel> matches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchesJson = matches.map((match) => match.toJson()).toList();
      await prefs.setString(_matchesKey, jsonEncode(matchesJson));
      await _updateLastSync();
    } catch (e) {
      CustomLogs.info('❌ Error saving matches: $e');
    }
  }

  static Future<List<MatchModel>> getCachedMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchesJson = prefs.getString(_matchesKey);
      if (matchesJson == null) return [];

      final List<dynamic> matchesList = jsonDecode(matchesJson);
      return matchesList.map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      CustomLogs.info('❌ Error loading cached matches: $e');
      return [];
    }
  }

  // Chat rooms caching
  static Future<void> saveChatRooms(List<ChatRoomModel> rooms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = rooms.map((room) => room.toJson()).toList();
      await prefs.setString(_chatRoomsKey, jsonEncode(roomsJson));
      await _updateLastSync();
    } catch (e) {
      CustomLogs.info('❌ Error saving chat rooms: $e');
    }
  }

  static Future<List<ChatRoomModel>> getCachedChatRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_chatRoomsKey);
      if (roomsJson == null) return [];

      final List<dynamic> roomsList = jsonDecode(roomsJson);
      return roomsList.map((json) => ChatRoomModel.fromJson(json)).toList();
    } catch (e) {
      CustomLogs.info('❌ Error loading cached chat rooms: $e');
      return [];
    }
  }

  // Messages caching
  static Future<void> saveMessages(
    int roomId,
    List<MessageModel> messages,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      await prefs.setString(
        '$_messagesKeyPrefix$roomId',
        jsonEncode(messagesJson),
      );
    } catch (e) {
      CustomLogs.info('❌ Error saving messages for room $roomId: $e');
    }
  }

  static Future<List<MessageModel>> getCachedMessages(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('$_messagesKeyPrefix$roomId');
      if (messagesJson == null) return [];

      final List<dynamic> messagesList = jsonDecode(messagesJson);
      return messagesList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      CustomLogs.info('❌ Error loading cached messages for room $roomId: $e');
      return [];
    }
  }

  // Utility methods
  static Future<void> _updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<bool> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) > maxAge;
  }

  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where(
            (key) =>
                key.startsWith(_messagesKeyPrefix) ||
                key == _profilesKey ||
                key == _matchesKey ||
                key == _chatRoomsKey ||
                key == _lastSyncKey,
          )
          .toList();

      for (final key in keys) {
        await prefs.remove(key);
      }
      CustomLogs.info('✅ All offline cache cleared');
    } catch (e) {
      CustomLogs.info('❌ Error clearing cache: $e');
    }
  }

  // Emergency fallback data
  static Future<Map<String, dynamic>> getEmergencyFallbackData() async {
    return {
      'profiles': await getCachedProfiles(),
      'matches': await getCachedMatches(),
      'chatRooms': await getCachedChatRooms(),
      'lastSync': await getLastSyncTime(),
    };
  }
}
