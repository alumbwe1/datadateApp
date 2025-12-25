import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatLocalStorageService {
  static const String _chatRoomsKey = 'cached_chat_rooms';
  static const String _messagesKeyPrefix = 'cached_messages_';
  static const String _lastUpdateKey = 'chat_last_update';

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

  static Future<void> addMessageToCache(
    int roomId,
    MessageModel message,
  ) async {
    final messages = await getCachedMessages(roomId);

    // Check if message already exists
    if (!messages.any((msg) => msg.id == message.id)) {
      messages.insert(0, message); // Add to beginning (newest first in cache)
      await saveMessages(roomId, messages);
    }

    // Update room's last message
    await updateRoomLastMessage(roomId, message);
  }

  static Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUpdateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

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
}
