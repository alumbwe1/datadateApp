import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/custom_logs.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/chat_local_storage_service.dart';
import '../../domain/repositories/chat_repository.dart';

// Repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(remoteDataSource: ChatRemoteDataSource());
});

// Remote datasource provider
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource();
});

// Chat rooms state
class ChatRoomsState {
  final List<ChatRoomModel> rooms;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastCacheUpdate;
  final bool hasCache;

  ChatRoomsState({
    this.rooms = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastCacheUpdate,
    this.hasCache = false,
  });

  ChatRoomsState copyWith({
    List<ChatRoomModel>? rooms,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastCacheUpdate,
    bool? hasCache,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      lastCacheUpdate: lastCacheUpdate ?? this.lastCacheUpdate,
      hasCache: hasCache ?? this.hasCache,
    );
  }

  // Check if cache is stale (older than 5 minutes)
  bool get isCacheStale {
    if (lastCacheUpdate == null) return true;
    return DateTime.now().difference(lastCacheUpdate!).inMinutes > 5;
  }

  // Check if we should show cached data
  bool get shouldShowCachedData => hasCache && rooms.isNotEmpty;
}

// Chat rooms notifier
class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  final ChatRepository _repository;

  ChatRoomsNotifier(this._repository) : super(ChatRoomsState()) {
    _initializeWithCache();
  }

  // Initialize with cached data immediately
  Future<void> _initializeWithCache() async {
    try {
      final cachedRooms = await ChatLocalStorageService.getCachedChatRooms();
      final lastUpdate = await ChatLocalStorageService.getLastUpdateTime();

      if (cachedRooms.isNotEmpty) {
        state = state.copyWith(
          rooms: cachedRooms,
          hasCache: true,
          lastCacheUpdate: lastUpdate,
          isLoading: false,
        );
        CustomLogs.info(
          '📱 Initialized with ${cachedRooms.length} cached chat rooms',
        );

        // If cache is stale, refresh in background
        if (state.isCacheStale) {
          CustomLogs.info('📱 Cache is stale, refreshing in background');
          _refreshInBackground();
        }
      }
    } catch (e) {
      CustomLogs.error('Failed to initialize with cache: $e');
    }
  }

  // Background refresh without affecting UI loading state
  Future<void> _refreshInBackground() async {
    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(
        rooms: rooms,
        lastCacheUpdate: DateTime.now(),
        error: null,
      );

      // Cache the updated rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
      CustomLogs.info('✅ Background refresh completed: ${rooms.length} rooms');
    } catch (e) {
      CustomLogs.info('⚠️ Background refresh failed: $e');
      // Silent fail - keep existing cached data
    }
  }

  Future<void> loadChatRooms() async {
    // If we already have cached data, don't show loading
    if (!state.shouldShowCachedData) {
      state = state.copyWith(isLoading: true, error: null);
    }

    // Load cached rooms first for instant display
    if (!state.hasCache) {
      final cachedRooms = await ChatLocalStorageService.getCachedChatRooms();
      final lastUpdate = await ChatLocalStorageService.getLastUpdateTime();

      if (cachedRooms.isNotEmpty) {
        state = state.copyWith(
          rooms: cachedRooms,
          hasCache: true,
          lastCacheUpdate: lastUpdate,
          isLoading: false,
        );
        CustomLogs.info('📱 Loaded ${cachedRooms.length} cached chat rooms');
      }
    }

    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
        lastCacheUpdate: DateTime.now(),
        error: null,
      );

      // Cache the rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
      CustomLogs.info('✅ Loaded ${rooms.length} chat rooms from API');
    } catch (e) {
      CustomLogs.error('❌ Error loading chat rooms: $e');

      // If we have cached data, don't show error
      if (state.shouldShowCachedData) {
        CustomLogs.info('📱 Using cached data due to network error');
        state = state.copyWith(isLoading: false, error: null);
      } else {
        // Only show error if we have no cached data
        final String errorMessage = _formatErrorMessage(e.toString());
        state = state.copyWith(isLoading: false, error: errorMessage);
      }
    }
  }

  Future<void> refreshChatRooms() async {
    state = state.copyWith(isRefreshing: true);

    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(
        rooms: rooms,
        isRefreshing: false,
        lastCacheUpdate: DateTime.now(),
        error: null,
      );

      // Cache the updated rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
      CustomLogs.info('✅ Refreshed ${rooms.length} chat rooms');
    } catch (e) {
      CustomLogs.info('⚠️ Failed to refresh chat rooms: $e');
      state = state.copyWith(isRefreshing: false);
      // Silent fail on refresh - keep existing data
    }
  }

  String _formatErrorMessage(String error) {
    final String errorMessage = error.replaceAll('Exception: ', '');
    if (errorMessage.contains('Failed host lookup') ||
        errorMessage.contains('No address associated with hostname')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorMessage.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else {
      return 'Unable to load chats. Pull down to retry.';
    }
  }

  void updateRoomWithNewMessage(int roomId, MessageModel message) {
    final updatedRooms = state.rooms.map((room) {
      if (room.id == roomId) {
        // Update room with new last message
        return room.copyWith(
          lastMessage: message,
          unreadCount: room.unreadCount + 1,
        );
      }
      return room;
    }).toList();

    // Sort by last message time (most recent first)
    updatedRooms.sort((a, b) {
      if (a.id == roomId) return -1;
      if (b.id == roomId) return 1;

      // Compare by last message time
      if (a.lastMessage != null && b.lastMessage != null) {
        return DateTime.parse(
          b.lastMessage!.createdAt,
        ).compareTo(DateTime.parse(a.lastMessage!.createdAt));
      }
      return 0;
    });

    state = state.copyWith(rooms: updatedRooms);

    // Update cache
    ChatLocalStorageService.saveChatRooms(updatedRooms);
  }

  // Force refresh from server (ignoring cache)
  Future<void> forceRefresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
        lastCacheUpdate: DateTime.now(),
        error: null,
      );

      // Cache the updated rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
      CustomLogs.info('✅ Force refreshed ${rooms.length} chat rooms');
    } catch (e) {
      CustomLogs.error('❌ Force refresh failed: $e');
      final String errorMessage = _formatErrorMessage(e.toString());
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  // Clear cache and reload
  Future<void> clearCacheAndReload() async {
    await ChatLocalStorageService.clearCache();
    state = ChatRoomsState(); // Reset to initial state
    await loadChatRooms();
  }
}

// Chat rooms provider
final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatRoomsNotifier(repository);
    });
