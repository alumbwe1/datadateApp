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
      final data = await _apiClient.get<dynamic>(ApiEndpoints.chatRooms);

      // Handle paginated response
      if (data is Map<String, dynamic> && data.containsKey('results')) {
        // Paginated response
        final List<dynamic> results = data['results'] as List<dynamic>;
        return results
            .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is List) {
        // Direct list response
        return data
            .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to fetch chat rooms',
      );
    }
  }

  /// Get chat room details by ID
  Future<ChatRoomModel> getChatRoomDetail(int roomId) async {
    try {
      final data = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.chatRoomDetail(roomId),
      );
      return ChatRoomModel.fromJson(data);
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
      final data = await _apiClient.get<dynamic>(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      // Handle both paginated and non-paginated responses
      if (data is List) {
        // Direct list response (non-paginated)
        return {
          'count': data.length,
          'next': null,
          'previous': null,
          'messages': data
              .map(
                (json) => MessageModel.fromJson(json as Map<String, dynamic>),
              )
              .toList(),
        };
      } else if (data is Map<String, dynamic>) {
        // Paginated response
        final List<dynamic> results = data['results'] as List<dynamic>;
        return {
          'count': data['count'] as int,
          'next': data['next'] as String?,
          'previous': data['previous'] as String?,
          'messages': results
              .map(
                (json) => MessageModel.fromJson(json as Map<String, dynamic>),
              )
              .toList(),
        };
      } else {
        throw Exception('Unexpected response format');
      }
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
      final data = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.sendMessage,
        data: {'room': roomId, 'content': content},
      );
      return MessageModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to send message');
    }
  }

  /// Mark a message as read
  Future<MessageModel> markMessageAsRead(int messageId) async {
    try {
      final data = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.markMessageRead(messageId),
      );
      return MessageModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to mark message as read',
      );
    }
  }

  /// Edit a message
  Future<MessageModel> editMessage({
    required int messageId,
    required String content,
  }) async {
    try {
      final data = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.editMessage(messageId),
        data: {'content': content},
      );
      return MessageModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to edit message');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _apiClient.delete(ApiEndpoints.deleteMessage(messageId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete message');
    }
  }
}
