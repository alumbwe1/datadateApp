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
        '$base${ApiEndpoints.chatWebSocket(roomId)}',
      ).replace(queryParameters: {'token': token});

      CustomLogs.info('🔌 Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);

      // Add connection timeout
      final connectionTimeout = Timer(const Duration(seconds: 10), () {
        if (_isConnecting) {
          CustomLogs.error('❌ WebSocket connection timeout');
          _handleConnectionError(roomId);
        }
      });

      // Listen to incoming messages
      _channel!.stream.listen(
        (data) {
          connectionTimeout.cancel(); // Cancel timeout on successful connection
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(message);
            _resetReconnectAttempts();
          } catch (e) {
            CustomLogs.error('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          connectionTimeout.cancel();
          CustomLogs.error('❌ WebSocket error: $error');
          _handleConnectionError(roomId);
        },
        onDone: () {
          connectionTimeout.cancel();
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
      // Stop trying to reconnect to prevent crashes
      _shouldReconnect = false;
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
    // Exponential backoff with jitter to avoid thundering herd
    final baseDelay = _reconnectDelay.inSeconds * _reconnectAttempts;
    final jitter = (baseDelay * 0.1 * (DateTime.now().millisecond / 1000));
    final delay = Duration(seconds: (baseDelay + jitter).round());

    CustomLogs.info(
      '🔄 Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && _reconnectAttempts <= _maxReconnectAttempts) {
        CustomLogs.info(
          '🔄 Attempting reconnection $_reconnectAttempts/$_maxReconnectAttempts',
        );
        connect(roomId).catchError((e) {
          CustomLogs.error(
            '❌ Reconnection attempt $_reconnectAttempts failed: $e',
          );
          // If it's a network error, don't keep trying immediately
          if (e.toString().contains('Failed host lookup') ||
              e.toString().contains('No address associated with hostname') ||
              e.toString().contains('SocketException')) {
            CustomLogs.info(
              '🌐 Network/DNS error detected, pausing reconnection attempts',
            );
            _shouldReconnect = false;
          }
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
  void sendMessage(String content, {String? localId}) {
    try {
      final messageData = {
        'type': 'chat_message',
        'message': content,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Include local ID if provided for tracking
      if (localId != null) {
        messageData['local_id'] = localId;
      }

      _sendRawMessage(messageData);
      CustomLogs.info(
        '📤 Message sent via WebSocket${localId != null ? ' (localId: $localId)' : ''}',
      );
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
