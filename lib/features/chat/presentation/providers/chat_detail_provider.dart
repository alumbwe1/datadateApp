import 'dart:async';

import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/websocket_service.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_local_storage_service.dart';
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
  final bool isOnline;
  final DateTime? lastTypingTime;

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
    this.isOnline = true,
    this.lastTypingTime,
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
    bool? isOnline,
    DateTime? lastTypingTime,
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
      isOnline: isOnline ?? this.isOnline,
      lastTypingTime: lastTypingTime ?? this.lastTypingTime,
    );
  }
}

// Chat detail notifier
class ChatDetailNotifier extends StateNotifier<ChatDetailState> {
  final ChatRepository _repository;
  final WebSocketService _webSocketService;
  final Ref _ref;
  final int roomId;
  StreamSubscription? _wsSubscription;
  Timer? _typingTimer;
  Timer? _typingIndicatorTimer;
  Timer? _refreshTimer;

  ChatDetailNotifier(
    this._repository,
    this._webSocketService,
    this._ref,
    this.roomId,
  ) : super(ChatDetailState()) {
    _initialize();
  }

  void _initialize() {
    _loadCachedData();
    _connectWebSocket();
    _listenToConnectivity();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    // Reduced frequency to avoid too many API calls - only refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshMessages();
    });
  }

  Future<void> _refreshMessages() async {
    try {
      // Only refresh if we're online and have an established connection
      final connectionInfo = await _ref.read(connectionInfoProvider.future);
      if (!connectionInfo.isConnected) {
        return; // Don't refresh if offline
      }

      // Load fresh messages from server silently (without affecting UI loading states)
      loadMessages(silent: true);
    } catch (e) {
      CustomLogs.error('Failed to refresh messages: $e');
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load cached room data
      final cachedRooms = await ChatLocalStorageService.getCachedChatRooms();
      final room = cachedRooms.where((r) => r.id == roomId).firstOrNull;

      // Load cached messages only if we don't have messages yet
      if (state.messages.isEmpty) {
        final cachedMessages = await ChatLocalStorageService.getCachedMessages(
          roomId,
        );

        state = state.copyWith(
          room: room,
          messages: cachedMessages,
          isLoading: false,
        );

        CustomLogs.info(
          '💬 Loaded ${cachedMessages.length} cached messages for room $roomId',
        );
      } else {
        // Just update the room if we already have messages
        state = state.copyWith(room: room);
      }
    } catch (e) {
      CustomLogs.error('Failed to load cached chat data: $e');
    }
  }

  void _listenToConnectivity() {
    _ref.listen(connectionInfoProvider, (previous, next) {
      next.whenData((connectionInfo) {
        final wasOffline = !state.isOnline;
        state = state.copyWith(isOnline: connectionInfo.isConnected);

        if (connectionInfo.isConnected && wasOffline) {
          CustomLogs.info('💬 Connection restored, refreshing messages');

          // Refresh messages when connection is restored
          _refreshMessages();
        }
      });
    });
  }

  void _connectWebSocket() {
    try {
      _wsSubscription?.cancel();

      // Connect to WebSocket
      _webSocketService
          .connect(roomId)
          .then((_) {
            state = state.copyWith(isConnected: true);
            CustomLogs.info('💬 WebSocket connected for room $roomId');
          })
          .catchError((error) {
            CustomLogs.error('Failed to connect WebSocket: $error');
            state = state.copyWith(isConnected: false);
          });

      // Listen to messages
      _wsSubscription = _webSocketService.messages.listen(
        (data) {
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          CustomLogs.error('WebSocket error: $error');
          state = state.copyWith(isConnected: false);

          // Don't schedule reconnect immediately on error
          Timer(const Duration(seconds: 10), () {
            if (state.isOnline && !state.isConnected) {
              _scheduleReconnect();
            }
          });
        },
        onDone: () {
          CustomLogs.info('WebSocket connection closed');
          state = state.copyWith(isConnected: false);
          _scheduleReconnect();
        },
      );
    } catch (e) {
      CustomLogs.error('Failed to connect WebSocket: $e');
      state = state.copyWith(isConnected: false);
    }
  }

  void _scheduleReconnect() {
    if (!state.isOnline) return;

    Timer(const Duration(seconds: 5), () {
      if (!state.isConnected && state.isOnline) {
        CustomLogs.info('💬 Attempting WebSocket reconnection...');
        _connectWebSocket();
      }
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String;

      switch (type) {
        case 'new_message':
          final message = MessageModel.fromJson(data['message']);
          _addNewMessage(message);
          break;
        case 'message_sent':
          // Handle confirmation that our message was sent
          final message = MessageModel.fromJson(data['message']);
          _addNewMessage(message);
          break;
        case 'message_updated':
          final message = MessageModel.fromJson(data['message']);
          _updateMessage(message);
          break;
        case 'message_deleted':
          final messageId = data['message_id'] as int;
          _removeMessage(messageId);
          break;
        case 'typing_start':
          _handleTypingStart();
          break;
        case 'typing_stop':
          _handleTypingStop();
          break;
      }
    } catch (e) {
      CustomLogs.error('Failed to handle WebSocket message: $e');
    }
  }

  void _addNewMessage(MessageModel message) {
    final messages = List<MessageModel>.from(state.messages);

    // Check if message already exists
    if (!messages.any((msg) => msg.id == message.id)) {
      messages.add(message);
      messages.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );

      state = state.copyWith(messages: messages);

      // Cache the new message
      ChatLocalStorageService.addMessageToCache(roomId, message);
    }
  }

  void _updateMessage(MessageModel message) {
    final messages = List<MessageModel>.from(state.messages);
    final index = messages.indexWhere((msg) => msg.id == message.id);

    if (index != -1) {
      messages[index] = message;
      state = state.copyWith(messages: messages);

      // Update cache
      ChatLocalStorageService.addMessageToCache(roomId, message);
    }
  }

  void _removeMessage(int messageId) {
    final messages = state.messages
        .where((msg) => msg.id != messageId)
        .toList();
    state = state.copyWith(messages: messages);

    // Update cache
    ChatLocalStorageService.saveMessages(roomId, messages);
  }

  void _handleTypingStart() {
    state = state.copyWith(isTyping: true, lastTypingTime: DateTime.now());

    _typingIndicatorTimer?.cancel();
    _typingIndicatorTimer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(isTyping: false);
    });
  }

  void _handleTypingStop() {
    state = state.copyWith(isTyping: false);
    _typingIndicatorTimer?.cancel();
  }

  // Load messages from server
  Future<void> loadMessages({
    bool isLoadMore = false,
    bool silent = false,
  }) async {
    if (!silent) {
      state = state.copyWith(
        isLoading: !isLoadMore,
        isLoadingMore: isLoadMore,
        error: null,
      );
    }

    try {
      final page = isLoadMore ? state.currentPage + 1 : 1;
      final response = await _repository.getMessages(
        roomId: roomId,
        page: page,
      );

      // The response is a Map<String, dynamic> with 'messages' key containing List<MessageModel>
      final newMessages = response['messages'] as List<MessageModel>;

      List<MessageModel> allMessages;
      if (isLoadMore) {
        // Add older messages to the beginning
        allMessages = [...newMessages, ...state.messages];
      } else {
        // Replace with fresh messages
        allMessages = newMessages;
      }

      // Remove duplicates and sort
      final uniqueMessages = <String, MessageModel>{};
      for (final message in allMessages) {
        uniqueMessages[message.uniqueId] = message;
      }

      final sortedMessages = uniqueMessages.values.toList();
      sortedMessages.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );

      state = state.copyWith(
        messages: sortedMessages,
        isLoading: false,
        isLoadingMore: false,
        hasMore: response['next'] != null,
        currentPage: page,
      );

      // Cache the messages
      await ChatLocalStorageService.saveMessages(roomId, sortedMessages);

      // Load room data if not available
      if (state.room == null) {
        await _loadRoomData();
      }
    } catch (e) {
      CustomLogs.error('Failed to load messages: $e');
      if (!silent) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Failed to load messages',
        );
      }
    }
  }

  Future<void> _loadRoomData() async {
    try {
      final rooms = await _repository.getChatRooms();
      final room = rooms.where((r) => r.id == roomId).firstOrNull;
      if (room != null) {
        state = state.copyWith(room: room);
      }
    } catch (e) {
      CustomLogs.error('Failed to load room data: $e');
    }
  }

  // Send message directly to server
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final currentUser = _ref.read(authProvider).user;
    if (currentUser == null) return;

    final currentUserId = int.tryParse(currentUser.id);
    if (currentUserId == null) return;

    try {
      // Send directly to server via HTTP API
      final sentMessage = await _repository.sendMessage(
        roomId: roomId,
        content: content.trim(),
      );

      // Add to messages list
      final messages = List<MessageModel>.from(state.messages);
      messages.add(sentMessage);
      messages.sort(
        (a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)),
      );

      state = state.copyWith(messages: messages);

      // Cache the sent message
      await ChatLocalStorageService.addMessageToCache(roomId, sentMessage);

      CustomLogs.info('💬 Message sent via HTTP: ${sentMessage.id}');
    } catch (e) {
      CustomLogs.error('💬 Failed to send message: $e');
      rethrow;
    }
  }

  // Edit message
  Future<void> editMessage(int messageId, String newContent) async {
    try {
      final updatedMessage = await _repository.editMessage(
        messageId: messageId,
        content: newContent,
      );
      _updateMessage(updatedMessage);
    } catch (e) {
      CustomLogs.error('Failed to edit message: $e');
      rethrow;
    }
  }

  // Delete message
  Future<void> deleteMessage(int messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      _removeMessage(messageId);
    } catch (e) {
      CustomLogs.error('Failed to delete message: $e');
      rethrow;
    }
  }

  // Send typing indicator
  void sendTypingIndicator([bool? isTyping]) {
    if (state.isConnected) {
      _webSocketService.sendTypingIndicator(isTyping != false);

      if (isTyping != false) {
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 2), () {
          if (state.isConnected) {
            _webSocketService.sendTypingIndicator(false);
          }
        });
      }
    }
  }

  // Retry failed messages (simplified - just refresh)
  Future<void> retryFailedMessages() async {
    await _refreshMessages();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Public method to refresh messages (called from UI)
  Future<void> refreshMessages() async {
    await _refreshMessages();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _typingTimer?.cancel();
    _typingIndicatorTimer?.cancel();
    _refreshTimer?.cancel();
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
      final webSocketService = ref.watch(webSocketServiceProvider);

      return ChatDetailNotifier(repository, webSocketService, ref, roomId);
    });
