import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatLocalStorageService {
  static const String _chatRoomsKey = 'cached_chat_rooms';
  static const String _messagesKeyPrefix = 'cached_messages_';
  static const String _lastUpdateKey = 'chat_last_update';

  // Chat rooms caching
  static Future<void> saveChatRooms(List<ChatRoomModel> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = rooms.map((room) => room.toJson()).toList();
    await prefs.setString(_chatRoomsKey, jsonEncode(roomsJson));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<ChatRoomModel>> getCachedChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getString(_chatRoomsKey);
    if (roomsJson == null) return [];

    final List<dynamic> roomsList = jsonDecode(roomsJson);
    return roomsList.map((json) => ChatRoomModel.fromJson(json)).toList();
  }

  // Messages caching
  static Future<void> saveMessages(
    int roomId,
    List<MessageModel> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString(
      '$_messagesKeyPrefix$roomId',
      jsonEncode(messagesJson),
    );
  }

  static Future<List<MessageModel>> getCachedMessages(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('$_messagesKeyPrefix$roomId');
    if (messagesJson == null) return [];

    final List<dynamic> messagesList = jsonDecode(messagesJson);
    return messagesList.map((json) => MessageModel.fromJson(json)).toList();
  }

  // Add or update a single message in cache
  static Future<void> addMessageToCache(
    int roomId,
    MessageModel message,
  ) async {
    final messages = await getCachedMessages(roomId);

    // Check if message already exists (by ID)
    final existingIndex = messages.indexWhere((msg) => msg.id == message.id);

    if (existingIndex != -1) {
      // Update existing message
      messages[existingIndex] = message;
    } else {
      // Add new message and sort by creation time
      messages.add(message);
      messages.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );
    }

    await saveMessages(roomId, messages);

    // Update room's last message
    await updateRoomLastMessage(roomId, message);
  }

  // Update room's last message
  static Future<void> updateRoomLastMessage(
    int roomId,
    MessageModel message,
  ) async {
    final rooms = await getCachedChatRooms();
    final roomIndex = rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex != -1) {
      final updatedRoom = rooms[roomIndex].copyWith(lastMessage: message);
      rooms[roomIndex] = updatedRoom;
      await saveChatRooms(rooms);
    }
  }

  // Cache metadata
  static Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUpdateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // Cache management
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where(
          (key) =>
              key.startsWith(_messagesKeyPrefix) ||
              key == _chatRoomsKey ||
              key == _lastUpdateKey,
        )
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Clear messages cache for a specific room
  static Future<void> clearMessagesCache(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_messagesKeyPrefix$roomId');
  }

  // Get cache size information
  static Future<Map<String, int>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    int roomsCount = 0;
    int messagesCount = 0;

    for (final key in keys) {
      if (key == _chatRoomsKey) {
        final roomsJson = prefs.getString(key);
        if (roomsJson != null) {
          final List<dynamic> roomsList = jsonDecode(roomsJson);
          roomsCount = roomsList.length;
        }
      } else if (key.startsWith(_messagesKeyPrefix)) {
        final messagesJson = prefs.getString(key);
        if (messagesJson != null) {
          final List<dynamic> messagesList = jsonDecode(messagesJson);
          messagesCount += messagesList.length;
        }
      }
    }

    return {'rooms': roomsCount, 'messages': messagesCount};
  }
}
