import 'dart:async';
import 'dart:convert';

import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  WebSocketService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Connect to chat room WebSocket with retry logic
  Future<void> connect(int roomId) async {
    if (_isConnecting) {
      CustomLogs.info('🔌 Already connecting, skipping...');
      return;
    }

    _isConnecting = true;
    _shouldReconnect = true;

    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final String base = 'wss://heartlink-production.up.railway.app';
      final uri = Uri.parse(
        '$base${ApiEndpoints.chatWebSocket(roomId)}?token=$token',
      );

      CustomLogs.info('🔌 Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(message);
            _resetReconnectAttempts();
          } catch (e) {
            CustomLogs.error('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          CustomLogs.error('❌ WebSocket error: $error');
          _handleConnectionError(roomId);
        },
        onDone: () {
          CustomLogs.info('🔌 WebSocket connection closed');
          _handleConnectionClosed(roomId);
        },
      );

      _startHeartbeat();
      _isConnecting = false;
      CustomLogs.success('✅ WebSocket connected to room $roomId');
    } catch (e) {
      _isConnecting = false;
      CustomLogs.error('❌ Failed to connect WebSocket: $e');
      _handleConnectionError(roomId);
      rethrow;
    }
  }

  void _handleConnectionError(int roomId) {
    _stopHeartbeat();
    _channel = null;
    _isConnecting = false;

    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect(roomId);
    } else {
      CustomLogs.error('❌ Max reconnection attempts reached');
      _messageController.addError(
        'Connection failed after $_maxReconnectAttempts attempts',
      );
    }
  }

  void _handleConnectionClosed(int roomId) {
    _stopHeartbeat();
    _channel = null;
    _isConnecting = false;

    if (_shouldReconnect) {
      _scheduleReconnect(roomId);
    }
  }

  void _scheduleReconnect(int roomId) {
    _reconnectAttempts++;
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );

    CustomLogs.info(
      '🔄 Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect) {
        CustomLogs.info(
          '🔄 Attempting reconnection $_reconnectAttempts/$_maxReconnectAttempts',
        );
        connect(roomId).catchError((e) {
          CustomLogs.error(
            '❌ Reconnection attempt $_reconnectAttempts failed: $e',
          );
        });
      }
    });
  }

  void _resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_channel != null) {
        try {
          _sendRawMessage({
            'type': 'ping',
            'timestamp': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          CustomLogs.error('❌ Heartbeat failed: $e');
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _sendRawMessage(Map<String, dynamic> message) {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    final jsonMessage = jsonEncode(message);
    _channel!.sink.add(jsonMessage);
  }

  /// Send a chat message
  void sendMessage(String content) {
    try {
      _sendRawMessage({
        'type': 'chat_message',
        'message': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
      CustomLogs.info('📤 Message sent via WebSocket');
    } catch (e) {
      CustomLogs.error('❌ Failed to send message via WebSocket: $e');
      rethrow;
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    try {
      _sendRawMessage({
        'type': 'typing',
        'is_typing': isTyping,
        'timestamp': DateTime.now().toIso8601String(),
      });
      CustomLogs.info('⌨️ Typing indicator sent: $isTyping');
    } catch (e) {
      CustomLogs.error('❌ Failed to send typing indicator: $e');
      // Don't rethrow for typing indicators - they're not critical
    }
  }

  /// Mark message as read
  void markAsRead(int messageId) {
    try {
      _sendRawMessage({
        'type': 'mark_read',
        'message_id': messageId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      CustomLogs.info('✓✓ Mark as read sent for message $messageId');
    } catch (e) {
      CustomLogs.error('❌ Failed to mark message as read: $e');
      // Don't rethrow for read receipts - they're not critical
    }
  }

  /// Disconnect WebSocket gracefully
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopHeartbeat();

    if (_channel != null) {
      try {
        _channel!.sink.close(1000, 'Client disconnecting');
      } catch (e) {
        CustomLogs.error('❌ Error closing WebSocket: $e');
      }
      _channel = null;
    }

    CustomLogs.info('🔌 WebSocket disconnected gracefully');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    CustomLogs.info('🗑️ WebSocket service disposed');
  }
}
