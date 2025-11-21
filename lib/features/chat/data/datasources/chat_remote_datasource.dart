import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all chat rooms for the current user
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chatRooms);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to fetch chat rooms',
      );
    }
  }

  /// Get chat room details by ID
  Future<ChatRoomModel> getChatRoomDetail(int roomId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatRoomDetail(roomId),
      );
      return ChatRoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to fetch chat room details',
      );
    }
  }

  /// Get messages for a specific chat room with pagination
  Future<Map<String, dynamic>> getMessages({
    required int roomId,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;

      return {
        'count': data['count'] as int,
        'next': data['next'] as String?,
        'previous': data['previous'] as String?,
        'messages': results
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch messages');
    }
  }

  /// Send a message via HTTP (for offline/fallback)
  Future<MessageModel> sendMessage({
    required int roomId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatMessages(roomId),
        data: {'content': content},
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to send message');
    }
  }

  /// Mark a message as read
  Future<MessageModel> markMessageAsRead(int messageId) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.markMessageRead(messageId),
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to mark message as read',
      );
    }
  }
}
