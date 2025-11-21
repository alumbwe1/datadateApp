import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';

abstract class ChatRepository {
  Future<List<ChatRoomModel>> getChatRooms();
  Future<ChatRoomModel> getChatRoomDetail(int roomId);
  Future<Map<String, dynamic>> getMessages({
    required int roomId,
    int page = 1,
    int pageSize = 50,
  });
  Future<MessageModel> sendMessage({
    required int roomId,
    required String content,
  });
  Future<MessageModel> markMessageAsRead(int messageId);
}
