import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/block_model.dart';

abstract class BlockingRemoteDataSource {
  Future<BlockModel> blockUser({required int blockedUserId, String? reason});
  Future<List<BlockModel>> getBlockedUsers();
  Future<void> unblockUser(int blockId);
  Future<BlockStatusModel> checkBlockStatus(int userId);
}

class BlockingRemoteDataSourceImpl implements BlockingRemoteDataSource {
  final ApiClient apiClient;

  BlockingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BlockModel> blockUser({
    required int blockedUserId,
    String? reason,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.blockedUsers,
      data: {
        'blocked_user_id': blockedUserId,
        if (reason != null) 'reason': reason,
      },
    );
    return BlockModel.fromJson(response.data['block']);
  }

  @override
  Future<List<BlockModel>> getBlockedUsers() async {
    final response = await apiClient.get(ApiEndpoints.blockedUsers);
    return (response.data as List)
        .map((json) => BlockModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> unblockUser(int blockId) async {
    await apiClient.delete(ApiEndpoints.unblockUser(blockId));
  }

  @override
  Future<BlockStatusModel> checkBlockStatus(int userId) async {
    final response = await apiClient.post(
      ApiEndpoints.checkBlockStatus,
      data: {'user_id': userId},
    );
    return BlockStatusModel.fromJson(response.data);
  }
}
