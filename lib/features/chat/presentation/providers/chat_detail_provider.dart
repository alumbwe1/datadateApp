import 'dart:async';
import 'dart:convert';

import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/websocket_service.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/connectivity_service.dart'
    show ConnectionInfo;
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_local_storage_service.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_provider.dart';

// Queued message for offline sending
class QueuedMessage {
  final String tempId;
  final String content;
  final DateTime timestamp;
  final int retryCount;

  QueuedMessage({
    required this.tempId,
    required this.content,
    required this.timestamp,
    this.retryCount = 0,
  });

  QueuedMessage copyWith({
    String? tempId,
    String? content,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return QueuedMessage(
      tempId: tempId ?? this.tempId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tempId': tempId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory QueuedMessage.fromJson(Map<String, dynamic> json) {
    return QueuedMessage(
      tempId: json['tempId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

// Chat detail state
class ChatDetailState {
  final ChatRoomModel? room;
  final List<MessageModel> messages;
  final List<QueuedMessage> queuedMessages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool isTyping; // Simplified - just one user typing
  final bool isConnected;
  final bool isOnline;
  final bool isSendingQueued;
  final DateTime? lastTypingTime;

  ChatDetailState({
    this.room,
    this.messages = const [],
    this.queuedMessages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.isTyping = false,
    this.isConnected = false,
    this.isOnline = true,
    this.isSendingQueued = false,
    this.lastTypingTime,
  });

  ChatDetailState copyWith({
    ChatRoomModel? room,
    List<MessageModel>? messages,
    List<QueuedMessage>? queuedMessages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isTyping,
    bool? isConnected,
    bool? isOnline,
    bool? isSendingQueued,
    DateTime? lastTypingTime,
  }) {
    return ChatDetailState(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      queuedMessages: queuedMessages ?? this.queuedMessages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      isConnected: isConnected ?? this.isConnected,
      isOnline: isOnline ?? this.isOnline,
      isSendingQueued: isSendingQueued ?? this.isSendingQueued,
      lastTypingTime: lastTypingTime ?? this.lastTypingTime,
    );
  }

  bool get hasQueuedMessages => queuedMessages.isNotEmpty;
}

// Chat detail notifier
class ChatDetailNotifier extends StateNotifier<ChatDetailState> {
  final ChatRepository _repository;
  final WebSocketService _webSocketService;
  final Ref _ref;
  final int roomId;
  StreamSubscription? _wsSubscription;
  Timer? _typingTimer;
  Timer? _queueRetryTimer;
  Timer? _typingIndicatorTimer;
  SharedPreferences? _prefs;

  ChatDetailNotifier(
    this._repository,
    this._webSocketService,
    this._ref,
    this.roomId,
  ) : super(ChatDetailState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadQueuedMessages();
    await loadRoomDetails();
    await loadMessages();
    _listenToConnectivity();
    await _connectWebSocket();
  }

  void _listenToConnectivity() {
    // Listen to connectivity changes using ref.listen
    _ref.listen<AsyncValue<ConnectionInfo>>(connectionInfoProvider, (
      previous,
      next,
    ) {
      next.whenData((connection) {
        final wasOnline = state.isOnline;
        final isNowOnline = connection.isConnected;

        state = state.copyWith(isOnline: isNowOnline);

        CustomLogs.info(
          '🌐 Connectivity changed: $isNowOnline (was: $wasOnline)',
        );

        // If we just came back online, try to send queued messages
        if (!wasOnline && isNowOnline && state.hasQueuedMessages) {
          CustomLogs.info(
            '📤 Back online! Sending ${state.queuedMessages.length} queued messages',
          );
          _sendQueuedMessages();
        }

        // Reconnect WebSocket if needed
        if (isNowOnline && !state.isConnected) {
          _connectWebSocket();
        }
      });
    });
  }

  Future<void> _loadQueuedMessages() async {
    try {
      final queuedJson = _prefs?.getString('queued_messages_$roomId');
      if (queuedJson != null) {
        final List<dynamic> queuedList = jsonDecode(queuedJson);
        final queuedMessages = queuedList
            .map((json) => QueuedMessage.fromJson(json))
            .toList();

        state = state.copyWith(queuedMessages: queuedMessages);
        CustomLogs.info(
          '📥 Loaded ${queuedMessages.length} queued messages from storage',
        );
      }
    } catch (e) {
      CustomLogs.error('❌ Error loading queued messages: $e');
    }
  }

  Future<void> _saveQueuedMessages() async {
    try {
      final queuedJson = jsonEncode(
        state.queuedMessages.map((msg) => msg.toJson()).toList(),
      );
      await _prefs?.setString('queued_messages_$roomId', queuedJson);
    } catch (e) {
      CustomLogs.error('❌ Error saving queued messages: $e');
    }
  }

  Future<void> loadRoomDetails() async {
    try {
      final room = await _repository.getChatRoomDetail(roomId);
      state = state.copyWith(room: room);
    } catch (e) {
      // Continue even if room details fail
      CustomLogs.info('⚠️ Failed to load room details: $e');
    }
  }

  Future<void> loadMessages({bool isLoadMore = false}) async {
    CustomLogs.info(
      '📥 loadMessages called for room $roomId (isLoadMore: $isLoadMore)',
    );

    if (isLoadMore) {
      if (!state.hasMore || state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);

      // Load cached messages first for instant display
      final cachedMessages = await ChatLocalStorageService.getCachedMessages(
        roomId,
      );
      if (cachedMessages.isNotEmpty) {
        // Sort messages: oldest first (for proper display order)
        cachedMessages.sort(
          (a, b) => DateTime.parse(
            a.createdAt,
          ).compareTo(DateTime.parse(b.createdAt)),
        );
        state = state.copyWith(messages: cachedMessages);
        CustomLogs.info('📱 Loaded ${cachedMessages.length} cached messages');
      }
    }

    try {
      // Check connectivity before making request
      if (!state.isOnline) {
        throw Exception('No internet connection');
      }

      CustomLogs.info('   🌐 Fetching messages from API...');
      final result = await _repository.getMessages(
        roomId: roomId,
        page: isLoadMore ? state.currentPage + 1 : 1,
        pageSize: 50,
      );

      final newMessages = result['messages'] as List<MessageModel>;
      final hasMore = result['next'] != null;

      CustomLogs.info('   ✅ Received ${newMessages.length} messages from API');
      CustomLogs.info('   📊 Has more pages: $hasMore');

      // Sort messages: oldest first for proper display
      newMessages.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );

      if (isLoadMore) {
        // For load more, add older messages to the beginning
        final combinedMessages = [...newMessages, ...state.messages];
        state = state.copyWith(
          messages: combinedMessages,
          isLoadingMore: false,
          hasMore: hasMore,
          currentPage: state.currentPage + 1,
        );
        CustomLogs.info(
          '   ✅ Added to existing messages. Total: ${combinedMessages.length}',
        );
      } else {
        state = state.copyWith(
          messages: newMessages,
          isLoading: false,
          hasMore: hasMore,
          currentPage: 1,
        );
        CustomLogs.info('   ✅ Set messages. Total: ${newMessages.length}');

        // Cache the messages
        await ChatLocalStorageService.saveMessages(roomId, newMessages);
      }
    } catch (e) {
      CustomLogs.info('   ❌ Error loading messages: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Provide user-friendly error messages
      if (errorMessage.contains('No internet connection')) {
        errorMessage = 'No internet connection. Showing cached messages.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
      } else if (errorMessage.contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
      } else {
        errorMessage = 'Failed to load messages. Pull down to retry.';
      }

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: errorMessage,
      );
    }
  }

  Future<void> _connectWebSocket() async {
    if (!state.isOnline) {
      CustomLogs.info('🔌 Skipping WebSocket connection - offline');
      return;
    }

    CustomLogs.info('🔌 Attempting to connect WebSocket for room $roomId...');
    try {
      await _webSocketService.connect(roomId);
      state = state.copyWith(isConnected: true);
      CustomLogs.info('✅ WebSocket connected successfully');

      _wsSubscription = _webSocketService.messages.listen(
        (data) {
          CustomLogs.info('📨 WebSocket message received: $data');
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          CustomLogs.error('❌ WebSocket error: $error');
          state = state.copyWith(isConnected: false);
          _scheduleReconnect();
        },
        onDone: () {
          CustomLogs.info('🔌 WebSocket connection closed');
          state = state.copyWith(isConnected: false);
          _scheduleReconnect();
        },
      );
    } catch (e) {
      CustomLogs.info('❌ WebSocket connection failed: $e');
      state = state.copyWith(isConnected: false);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!state.isOnline) return;

    Timer(const Duration(seconds: 5), () {
      if (!state.isConnected && state.isOnline) {
        CustomLogs.info('🔄 Attempting WebSocket reconnection...');
        _connectWebSocket();
      }
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    CustomLogs.info('🔄 Handling WebSocket message type: $type');

    switch (type) {
      case 'chat_message':
        CustomLogs.info('   💬 New chat message received');
        final messageData = data['message'] as Map<String, dynamic>;
        final message = MessageModel.fromJson(messageData);
        CustomLogs.info('   Adding message to UI: ${message.content}');
        _addNewMessage(message);
        break;

      case 'typing':
        final isTyping = data['is_typing'] as bool? ?? false;
        CustomLogs.info('   ⌨️ Typing indicator: $isTyping');
        state = state.copyWith(isTyping: isTyping);

        // Auto-clear typing indicator after 5 seconds
        if (isTyping) {
          Timer(const Duration(seconds: 5), () {
            if (mounted) {
              state = state.copyWith(isTyping: false);
            }
          });
        }
        break;

      case 'message_read':
        final messageId = data['message_id'] as int;
        CustomLogs.info('   ✓✓ Message $messageId marked as read');
        _markMessageAsRead(messageId);
        break;

      case 'user_status_change':
        final userId = data['user_id']?.toString() ?? '';
        final isOnline = data['is_online'] as bool? ?? false;
        CustomLogs.info(
          '   👤 User $userId status changed: ${isOnline ? 'online' : 'offline'}',
        );
        // Update room participant status if needed
        break;

      default:
        CustomLogs.info('   ⚠️ Unknown message type: $type');
    }
  }

  void _addNewMessage(MessageModel message) {
    // Check if message already exists (prevent duplicates from WebSocket echo)
    final exists = state.messages.any((msg) => msg.id == message.id);
    if (exists) {
      CustomLogs.info(
        '   ⚠️ Message ${message.id} already exists, skipping duplicate',
      );
      return;
    }

    // Add new message to the end (newest messages at bottom)
    final updatedMessages = [...state.messages, message];
    state = state.copyWith(messages: updatedMessages);
    CustomLogs.info(
      '   ✅ Message added to UI (total: ${updatedMessages.length})',
    );

    // Cache the new message
    ChatLocalStorageService.addMessageToCache(roomId, message);

    // Notify chat list to update
    _ref
        .read(chatRoomsProvider.notifier)
        .updateRoomWithNewMessage(roomId, message);
  }

  void _markMessageAsRead(int messageId) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    CustomLogs.info('🟢 ChatDetailNotifier.sendMessage called');
    CustomLogs.info('   Content: "$content"');
    CustomLogs.info('   Room ID: $roomId');
    CustomLogs.info('   Online: ${state.isOnline}');
    CustomLogs.info('   WebSocket connected: ${state.isConnected}');

    // If offline, queue the message
    if (!state.isOnline) {
      CustomLogs.info('   📴 Offline - queuing message');
      await _queueMessage(content);
      return;
    }

    try {
      // Always send via HTTP to ensure message is saved and appears in UI
      CustomLogs.info('   📤 Sending message via HTTP...');
      final message = await _repository
          .sendMessage(roomId: roomId, content: content)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Message sending timed out. Please check your connection.',
              );
            },
          );

      CustomLogs.info('   ✅ HTTP send successful, adding to UI');
      _addNewMessage(message);

      // Also send via WebSocket if connected for real-time delivery to other user
      if (state.isConnected) {
        CustomLogs.info('   📡 Also sending via WebSocket for real-time...');
        try {
          _webSocketService.sendMessage(content);
        } catch (wsError) {
          CustomLogs.info(
            '   ⚠️ WebSocket send failed (non-critical): $wsError',
          );
          // Non-critical error, message already sent via HTTP
        }
      }
    } catch (e) {
      CustomLogs.info('   ❌ Error sending message: $e');

      // If it's a network error, queue the message
      if (e.toString().contains('timeout') ||
          e.toString().contains('network') ||
          e.toString().contains('connection')) {
        CustomLogs.info('   📴 Network error - queuing message');
        await _queueMessage(content);
      } else {
        // Show error to user for other types of errors
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('timeout')) {
          errorMessage =
              'Message sending timed out. It has been queued and will be sent when connection improves.';
          await _queueMessage(content);
        } else {
          errorMessage = 'Failed to send message: $errorMessage';
        }
        state = state.copyWith(error: errorMessage);
      }
    }
  }

  Future<void> _queueMessage(String content) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final queuedMessage = QueuedMessage(
      tempId: tempId,
      content: content,
      timestamp: DateTime.now(),
    );

    final updatedQueue = [...state.queuedMessages, queuedMessage];
    state = state.copyWith(queuedMessages: updatedQueue);

    await _saveQueuedMessages();

    CustomLogs.info('📥 Message queued (${updatedQueue.length} total)');

    // Show user feedback
    state = state.copyWith(
      error: 'Message queued. Will be sent when connection is restored.',
    );

    // Clear error after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(error: null);
      }
    });
  }

  Future<void> _sendQueuedMessages() async {
    if (state.queuedMessages.isEmpty ||
        state.isSendingQueued ||
        !state.isOnline) {
      return;
    }

    state = state.copyWith(isSendingQueued: true);
    CustomLogs.info(
      '📤 Sending ${state.queuedMessages.length} queued messages',
    );

    final messagesToSend = List<QueuedMessage>.from(state.queuedMessages);
    final successfulMessages = <QueuedMessage>[];

    for (final queuedMessage in messagesToSend) {
      try {
        CustomLogs.info(
          '   📤 Sending queued message: ${queuedMessage.content}',
        );

        final message = await _repository
            .sendMessage(roomId: roomId, content: queuedMessage.content)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Timeout sending queued message');
              },
            );

        _addNewMessage(message);
        successfulMessages.add(queuedMessage);

        CustomLogs.info('   ✅ Queued message sent successfully');

        // Small delay between messages to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        CustomLogs.info('   ❌ Failed to send queued message: $e');

        // Increment retry count
        final updatedMessage = queuedMessage.copyWith(
          retryCount: queuedMessage.retryCount + 1,
        );

        // Remove message if it has failed too many times
        if (updatedMessage.retryCount >= 3) {
          CustomLogs.info('   🗑️ Removing message after 3 failed attempts');
          successfulMessages.add(queuedMessage); // Mark for removal
        }

        break; // Stop sending if one fails
      }
    }

    // Remove successfully sent messages from queue
    final remainingMessages = state.queuedMessages
        .where((msg) => !successfulMessages.contains(msg))
        .toList();

    state = state.copyWith(
      queuedMessages: remainingMessages,
      isSendingQueued: false,
    );

    await _saveQueuedMessages();

    if (successfulMessages.isNotEmpty) {
      CustomLogs.info('✅ Sent ${successfulMessages.length} queued messages');
    }

    if (remainingMessages.isNotEmpty) {
      CustomLogs.info(
        '⚠️ ${remainingMessages.length} messages remain in queue',
      );
      // Schedule retry in 30 seconds
      _queueRetryTimer?.cancel();
      _queueRetryTimer = Timer(const Duration(seconds: 30), () {
        if (state.isOnline && remainingMessages.isNotEmpty) {
          _sendQueuedMessages();
        }
      });
    }
  }

  void sendTypingIndicator(bool isTyping) {
    CustomLogs.info('⌨️ Sending typing indicator: $isTyping');

    // Only send if we have a connection
    if (state.isConnected && state.isOnline) {
      try {
        _webSocketService.sendTypingIndicator(isTyping);
        CustomLogs.info('   ✅ Typing indicator sent via WebSocket');
      } catch (e) {
        CustomLogs.info('   ❌ Failed to send typing indicator: $e');
      }
    } else {
      CustomLogs.info('   ⚠️ Skipping typing indicator - not connected');
    }

    // Update local state
    state = state.copyWith(lastTypingTime: isTyping ? DateTime.now() : null);

    // Auto-stop typing after 3 seconds
    _typingIndicatorTimer?.cancel();
    if (isTyping) {
      _typingIndicatorTimer = Timer(const Duration(seconds: 3), () {
        sendTypingIndicator(false);
      });
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      if (state.isConnected && state.isOnline) {
        _webSocketService.markAsRead(messageId);
      } else if (state.isOnline) {
        await _repository.markMessageAsRead(messageId);
      }
      _markMessageAsRead(messageId);
    } catch (e) {
      CustomLogs.info('⚠️ Failed to mark message as read: $e');
      // Silent fail - not critical
    }
  }

  Future<void> editMessage(int messageId, String content) async {
    if (content.trim().isEmpty) return;

    CustomLogs.info(
      '📝 Editing message $messageId with new content: "$content"',
    );

    if (!state.isOnline) {
      state = state.copyWith(error: 'Cannot edit messages while offline');
      return;
    }

    try {
      final updatedMessage = await _repository
          .editMessage(messageId: messageId, content: content)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Edit request timed out');
            },
          );

      // Update the message in the local state
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return updatedMessage;
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
      CustomLogs.info('✅ Message updated successfully in UI');
    } catch (e) {
      CustomLogs.info('❌ Error editing message: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Edit request timed out. Please try again.';
      }
      state = state.copyWith(error: 'Failed to edit message: $errorMessage');
      rethrow;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    CustomLogs.info('🗑️ Deleting message $messageId');

    if (!state.isOnline) {
      state = state.copyWith(error: 'Cannot delete messages while offline');
      return;
    }

    try {
      await _repository
          .deleteMessage(messageId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Delete request timed out');
            },
          );

      // Remove the message from the local state
      final updatedMessages = state.messages
          .where((msg) => msg.id != messageId)
          .toList();

      state = state.copyWith(messages: updatedMessages);
      CustomLogs.info('✅ Message deleted successfully from UI');
    } catch (e) {
      CustomLogs.info('❌ Error deleting message: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Delete request timed out. Please try again.';
      }
      state = state.copyWith(error: 'Failed to delete message: $errorMessage');
      rethrow;
    }
  }

  // Retry sending queued messages manually
  Future<void> retryQueuedMessages() async {
    if (state.hasQueuedMessages && state.isOnline) {
      await _sendQueuedMessages();
    }
  }

  // Clear all queued messages
  Future<void> clearQueuedMessages() async {
    state = state.copyWith(queuedMessages: []);
    await _saveQueuedMessages();
    CustomLogs.info('🗑️ Cleared all queued messages');
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _typingTimer?.cancel();
    _queueRetryTimer?.cancel();
    _typingIndicatorTimer?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}

// Chat detail provider factory
final chatDetailProvider =
    StateNotifierProvider.family<ChatDetailNotifier, ChatDetailState, int>((
      ref,
      roomId,
    ) {
      final repository = ref.watch(chatRepositoryProvider);
      final webSocketService = WebSocketService();

      return ChatDetailNotifier(repository, webSocketService, ref, roomId);
    });
