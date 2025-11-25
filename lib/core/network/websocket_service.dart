import 'dart:async';
import 'dart:convert';
import 'package:datadate/core/utils/custom_logs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Connect to chat room WebSocket
  Future<void> connect(int roomId) async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      if (token == null) {
        throw Exception('No authentication token found');
      }

      String base = 'ws://10.0.2.2:7000';

      final uri = Uri.parse(
        '$base${ApiEndpoints.chatWebSocket(roomId)}?token=$token',
      );

      _channel = WebSocketChannel.connect(uri);

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(message);
          } catch (e) {
            CustomLogs.error('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          CustomLogs.info('❌ WebSocket error: $error');
          _messageController.addError(error);
        },
        onDone: () {
          CustomLogs.info('🔌 WebSocket connection closed');
        },
      );

      CustomLogs.info('✅ WebSocket connected to room $roomId');
    } catch (e) {
      CustomLogs.error('❌ Failed to connect WebSocket: $e');
      rethrow;
    }
  }

  /// Send a chat message
  void sendMessage(String content) {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    final message = jsonEncode({'type': 'chat_message', 'message': content});

    _channel!.sink.add(message);
  }

  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_channel == null) return;

    final message = jsonEncode({'type': 'typing', 'is_typing': isTyping});

    _channel!.sink.add(message);
  }

  /// Mark message as read
  void markAsRead(int messageId) {
    if (_channel == null) return;

    final message = jsonEncode({'type': 'mark_read', 'message_id': messageId});

    _channel!.sink.add(message);
  }

  /// Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    CustomLogs.info('🔌 WebSocket disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
