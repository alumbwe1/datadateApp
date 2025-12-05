import 'dart:async';
import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/websocket_service.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_room_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_provider.dart';

// Chat detail state
class ChatDetailState {
  final ChatRoomModel? room;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool isTyping;
  final bool isConnected;

  ChatDetailState({
    this.room,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.isTyping = false,
    this.isConnected = false,
  });

  ChatDetailState copyWith({
    ChatRoomModel? room,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isTyping,
    bool? isConnected,
  }) {
    return ChatDetailState(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// Chat detail notifier
class ChatDetailNotifier extends StateNotifier<ChatDetailState> {
  final ChatRepository _repository;
  final WebSocketService _webSocketService;
  final int roomId;
  StreamSubscription? _wsSubscription;
  Timer? _typingTimer;

  ChatDetailNotifier(this._repository, this._webSocketService, this.roomId)
    : super(ChatDetailState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadRoomDetails();
    await loadMessages();
    await _connectWebSocket();
  }

  Future<void> loadRoomDetails() async {
    try {
      final room = await _repository.getChatRoomDetail(roomId);
      state = state.copyWith(room: room);
    } catch (e) {
      // Continue even if room details fail
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
    }

    try {
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

      if (isLoadMore) {
        state = state.copyWith(
          messages: [...state.messages, ...newMessages],
          isLoadingMore: false,
          hasMore: hasMore,
          currentPage: state.currentPage + 1,
        );
        CustomLogs.info(
          '   ✅ Added to existing messages. Total: ${state.messages.length}',
        );
      } else {
        state = state.copyWith(
          messages: newMessages,
          isLoading: false,
          hasMore: hasMore,
          currentPage: 1,
        );
        CustomLogs.info('   ✅ Set messages. Total: ${newMessages.length}');
      }
    } catch (e) {
      CustomLogs.info('   ❌ Error loading messages: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _connectWebSocket() async {
    CustomLogs.info('🔌 Attempting to connect WebSocket for room $roomId...');
    try {
      await _webSocketService.connect(roomId);
      state = state.copyWith(isConnected: true);
      CustomLogs.info('✅ WebSocket connected successfully');

      _wsSubscription = _webSocketService.messages.listen((data) {
        CustomLogs.info('📨 WebSocket message received: $data');
        _handleWebSocketMessage(data);
      });
    } catch (e) {
      CustomLogs.info('❌ WebSocket connection failed: $e');
      state = state.copyWith(isConnected: false);
    }
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
        break;

      case 'message_read':
        final messageId = data['message_id'] as int;
        CustomLogs.info('   ✓✓ Message $messageId marked as read');
        _markMessageAsRead(messageId);
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

    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
    CustomLogs.info(
      '   ✅ Message added to UI (total: ${updatedMessages.length})',
    );
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
    CustomLogs.info('   WebSocket connected: ${state.isConnected}');

    try {
      // Always send via HTTP to ensure message is saved and appears in UI
      CustomLogs.info('   📤 Sending message via HTTP...');
      final message = await _repository.sendMessage(
        roomId: roomId,
        content: content,
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
      // Show error to user
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
    }
  }

  void sendTypingIndicator(bool isTyping) {
    if (state.isConnected) {
      _webSocketService.sendTypingIndicator(isTyping);
    }

    // Auto-stop typing after 3 seconds
    _typingTimer?.cancel();
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        sendTypingIndicator(false);
      });
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      if (state.isConnected) {
        _webSocketService.markAsRead(messageId);
      } else {
        await _repository.markMessageAsRead(messageId);
      }
      _markMessageAsRead(messageId);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> editMessage(int messageId, String content) async {
    if (content.trim().isEmpty) return;

    CustomLogs.info(
      '📝 Editing message $messageId with new content: "$content"',
    );

    try {
      final updatedMessage = await _repository.editMessage(
        messageId: messageId,
        content: content,
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
      state = state.copyWith(error: 'Failed to edit message: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    CustomLogs.info('🗑️ Deleting message $messageId');

    try {
      await _repository.deleteMessage(messageId);

      // Remove the message from the local state
      final updatedMessages = state.messages
          .where((msg) => msg.id != messageId)
          .toList();

      state = state.copyWith(messages: updatedMessages);
      CustomLogs.info('✅ Message deleted successfully from UI');
    } catch (e) {
      CustomLogs.info('❌ Error deleting message: $e');
      state = state.copyWith(
        error: 'Failed to delete message: ${e.toString()}',
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _typingTimer?.cancel();
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

      return ChatDetailNotifier(repository, webSocketService, roomId);
    });
