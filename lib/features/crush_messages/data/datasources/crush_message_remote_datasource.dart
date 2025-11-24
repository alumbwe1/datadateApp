import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/crush_message_model.dart';

abstract class CrushMessageRemoteDataSource {
  Future<CrushMessageModel> sendCrushMessage({
    required int receiverId,
    required String message,
  });
  Future<List<CrushMessageModel>> getSentCrushMessages();
  Future<List<CrushMessageModel>> getReceivedCrushMessages();
  Future<List<CrushMessageModel>> getPendingCrushMessages();
  Future<CrushMessageModel> markCrushMessageRead(int messageId);
  Future<Map<String, dynamic>> respondToCrushMessage({
    required int messageId,
    required String action, // 'accept' or 'decline'
  });
}

class CrushMessageRemoteDataSourceImpl implements CrushMessageRemoteDataSource {
  final ApiClient apiClient;

  CrushMessageRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CrushMessageModel> sendCrushMessage({
    required int receiverId,
    required String message,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.crushMessages,
      data: {'receiver_id': receiverId, 'message': message},
    );
    return CrushMessageModel.fromJson(response.data['crush_message']);
  }

  @override
  Future<List<CrushMessageModel>> getSentCrushMessages() async {
    final response = await apiClient.get(ApiEndpoints.sentCrushMessages);
    return (response.data as List)
        .map((json) => CrushMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<CrushMessageModel>> getReceivedCrushMessages() async {
    final response = await apiClient.get(ApiEndpoints.receivedCrushMessages);
    return (response.data as List)
        .map((json) => CrushMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<CrushMessageModel>> getPendingCrushMessages() async {
    final response = await apiClient.get(ApiEndpoints.pendingCrushMessages);
    return (response.data as List)
        .map((json) => CrushMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<CrushMessageModel> markCrushMessageRead(int messageId) async {
    final response = await apiClient.post(
      ApiEndpoints.markCrushMessageRead(messageId),
    );
    return CrushMessageModel.fromJson(response.data['crush_message']);
  }

  @override
  Future<Map<String, dynamic>> respondToCrushMessage({
    required int messageId,
    required String action,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.respondToCrushMessage(messageId),
      data: {'action': action},
    );
    return response.data;
  }
}
