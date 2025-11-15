import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomModel>> getChatRooms();
  Future<ChatRoomModel> getChatRoomDetail(int roomId);
  Future<PaginatedResponse<MessageModel>> getMessages({
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

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await apiClient.get<List<dynamic>>(ApiEndpoints.chatRooms);

    return response
        .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatRoomModel> getChatRoomDetail(int roomId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.chatRoomDetail(roomId),
    );

    return ChatRoomModel.fromJson(response);
  }

  @override
  Future<PaginatedResponse<MessageModel>> getMessages({
    required int roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.chatMessages(roomId),
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    return PaginatedResponse.fromJson(
      response,
      (json) => MessageModel.fromJson(json),
    );
  }

  @override
  Future<MessageModel> sendMessage({
    required int roomId,
    required String content,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.chatMessages(roomId),
      data: {'content': content},
    );

    return MessageModel.fromJson(response);
  }

  @override
  Future<MessageModel> markMessageAsRead(int messageId) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.markMessageRead(messageId),
    );

    return MessageModel.fromJson(response);
  }
}
