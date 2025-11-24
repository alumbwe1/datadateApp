import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/blocking_remote_datasource.dart';
import '../../data/models/block_model.dart';
import '../../../../core/providers/api_providers.dart';

final blockingDataSourceProvider = Provider<BlockingRemoteDataSource>((ref) {
  return BlockingRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final blockedUsersProvider =
    StateNotifierProvider<BlockedUsersNotifier, AsyncValue<List<BlockModel>>>(
      (ref) => BlockedUsersNotifier(
        dataSource: ref.watch(blockingDataSourceProvider),
      ),
    );

class BlockedUsersNotifier extends StateNotifier<AsyncValue<List<BlockModel>>> {
  final BlockingRemoteDataSource dataSource;

  BlockedUsersNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    state = const AsyncValue.loading();
    try {
      final blocks = await dataSource.getBlockedUsers();
      state = AsyncValue.data(blocks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> blockUser({required int blockedUserId, String? reason}) async {
    try {
      final block = await dataSource.blockUser(
        blockedUserId: blockedUserId,
        reason: reason,
      );

      final currentBlocks = state.value ?? [];
      state = AsyncValue.data([block, ...currentBlocks]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> unblockUser(int blockId) async {
    try {
      await dataSource.unblockUser(blockId);

      final currentBlocks = state.value ?? [];
      state = AsyncValue.data(
        currentBlocks.where((block) => block.id != blockId).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<BlockStatusModel> checkBlockStatus(int userId) async {
    return await dataSource.checkBlockStatus(userId);
  }

  bool isUserBlocked(int userId) {
    final blocks = state.value ?? [];
    return blocks.any((block) => block.blockedUserId == userId);
  }
}
