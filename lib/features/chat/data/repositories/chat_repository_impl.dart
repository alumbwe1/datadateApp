import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource();

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    return await _remoteDataSource.getChatRooms();
  }

  @override
  Future<ChatRoomModel> getChatRoomDetail(int roomId) async {
    return await _remoteDataSource.getChatRoomDetail(roomId);
  }

  @override
  Future<Map<String, dynamic>> getMessages({
    required int roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    return await _remoteDataSource.getMessages(
      roomId: roomId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<MessageModel> sendMessage({
    required int roomId,
    required String content,
  }) async {
    return await _remoteDataSource.sendMessage(
      roomId: roomId,
      content: content,
    );
  }

  @override
  Future<MessageModel> markMessageAsRead(int messageId) async {
    return await _remoteDataSource.markMessageAsRead(messageId);
  }

  @override
  Future<MessageModel> editMessage({
    required int messageId,
    required String content,
  }) async {
    return await _remoteDataSource.editMessage(
      messageId: messageId,
      content: content,
    );
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    return await _remoteDataSource.deleteMessage(messageId);
  }
}
