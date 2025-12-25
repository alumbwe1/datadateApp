import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Chat rooms state
class ChatRoomsState {
  final List<ChatRoomModel> rooms;
  final bool isLoading;
  final String? error;

  ChatRoomsState({this.rooms = const [], this.isLoading = false, this.error});

  ChatRoomsState copyWith({
    List<ChatRoomModel>? rooms,
    bool? isLoading,
    String? error,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chat rooms notifier
class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  final ChatRepository _repository;

  ChatRoomsNotifier(this._repository) : super(ChatRoomsState());

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, error: null);

    // Load cached rooms first for instant display
    final cachedRooms = await ChatLocalStorageService.getCachedChatRooms();
    if (cachedRooms.isNotEmpty) {
      state = state.copyWith(rooms: cachedRooms);
    }

    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(rooms: rooms, isLoading: false);

      // Cache the rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refreshChatRooms() async {
    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(rooms: rooms);

      // Cache the updated rooms
      await ChatLocalStorageService.saveChatRooms(rooms);
    } catch (e) {
      // Silent fail on refresh
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
}

// Chat rooms provider
final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatRoomsNotifier(repository);
    });
