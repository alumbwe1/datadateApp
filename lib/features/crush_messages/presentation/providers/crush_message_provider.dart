import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/crush_message_remote_datasource.dart';
import '../../data/models/crush_message_model.dart';
import '../../../../core/providers/api_providers.dart';

final crushMessageDataSourceProvider = Provider<CrushMessageRemoteDataSource>((
  ref,
) {
  return CrushMessageRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final sentCrushMessagesProvider =
    StateNotifierProvider<
      SentCrushMessagesNotifier,
      AsyncValue<List<CrushMessageModel>>
    >(
      (ref) => SentCrushMessagesNotifier(
        dataSource: ref.watch(crushMessageDataSourceProvider),
      ),
    );

class SentCrushMessagesNotifier
    extends StateNotifier<AsyncValue<List<CrushMessageModel>>> {
  final CrushMessageRemoteDataSource dataSource;

  SentCrushMessagesNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchSentMessages();
  }

  Future<void> fetchSentMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await dataSource.getSentCrushMessages();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendCrushMessage({
    required int receiverId,
    required String message,
  }) async {
    try {
      final crushMessage = await dataSource.sendCrushMessage(
        receiverId: receiverId,
        message: message,
      );

      final currentMessages = state.value ?? [];
      state = AsyncValue.data([crushMessage, ...currentMessages]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final receivedCrushMessagesProvider =
    StateNotifierProvider<
      ReceivedCrushMessagesNotifier,
      AsyncValue<List<CrushMessageModel>>
    >(
      (ref) => ReceivedCrushMessagesNotifier(
        dataSource: ref.watch(crushMessageDataSourceProvider),
      ),
    );

class ReceivedCrushMessagesNotifier
    extends StateNotifier<AsyncValue<List<CrushMessageModel>>> {
  final CrushMessageRemoteDataSource dataSource;

  ReceivedCrushMessagesNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchReceivedMessages();
  }

  Future<void> fetchReceivedMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await dataSource.getReceivedCrushMessages();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(int messageId) async {
    try {
      final updatedMessage = await dataSource.markCrushMessageRead(messageId);

      final currentMessages = state.value ?? [];
      state = AsyncValue.data(
        currentMessages.map((msg) {
          return msg.id == messageId ? updatedMessage : msg;
        }).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> respondToMessage({
    required int messageId,
    required String action,
  }) async {
    try {
      final response = await dataSource.respondToCrushMessage(
        messageId: messageId,
        action: action,
      );

      // Refresh the list after responding
      await fetchReceivedMessages();

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final pendingCrushMessagesProvider =
    FutureProvider.autoDispose<List<CrushMessageModel>>((ref) async {
      final dataSource = ref.watch(crushMessageDataSourceProvider);
      return await dataSource.getPendingCrushMessages();
    });
