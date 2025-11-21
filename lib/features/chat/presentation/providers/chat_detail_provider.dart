import 'dart:async';
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
    if (isLoadMore) {
      if (!state.hasMore || state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _repository.getMessages(
        roomId: roomId,
        page: isLoadMore ? state.currentPage + 1 : 1,
        pageSize: 50,
      );

      final newMessages = result['messages'] as List<MessageModel>;
      final hasMore = result['next'] != null;

      if (isLoadMore) {
        state = state.copyWith(
          messages: [...state.messages, ...newMessages],
          isLoadingMore: false,
          hasMore: hasMore,
          currentPage: state.currentPage + 1,
        );
      } else {
        state = state.copyWith(
          messages: newMessages,
          isLoading: false,
          hasMore: hasMore,
          currentPage: 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      await _webSocketService.connect(roomId);
      state = state.copyWith(isConnected: true);

      _wsSubscription = _webSocketService.messages.listen((data) {
        _handleWebSocketMessage(data);
      });
    } catch (e) {
      state = state.copyWith(isConnected: false);
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'chat_message':
        final messageData = data['message'] as Map<String, dynamic>;
        final message = MessageModel.fromJson(messageData);
        _addNewMessage(message);
        break;

      case 'typing':
        final isTyping = data['is_typing'] as bool? ?? false;
        state = state.copyWith(isTyping: isTyping);
        break;

      case 'message_read':
        final messageId = data['message_id'] as int;
        _markMessageAsRead(messageId);
        break;
    }
  }

  void _addNewMessage(MessageModel message) {
    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
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

    try {
      if (state.isConnected) {
        // Send via WebSocket for real-time
        _webSocketService.sendMessage(content);
      } else {
        // Fallback to HTTP
        final message = await _repository.sendMessage(
          roomId: roomId,
          content: content,
        );
        _addNewMessage(message);
      }
    } catch (e) {
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
