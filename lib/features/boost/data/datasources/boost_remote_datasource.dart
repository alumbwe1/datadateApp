import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/boost_model.dart';

abstract class BoostRemoteDataSource {
  Future<BoostPricingModel> getBoostPricing();
  Future<BoostModel> createBoost({
    required double amountPaid,
    required int targetViews,
    required int durationHours,
  });
  Future<BoostModel> activateBoost(int boostId);
  Future<BoostModel?> getActiveBoost();
  Future<List<BoostModel>> getBoostHistory();
}

class BoostRemoteDataSourceImpl implements BoostRemoteDataSource {
  final ApiClient apiClient;

  BoostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BoostPricingModel> getBoostPricing() async {
    final response = await apiClient.get(ApiEndpoints.boostPricing);
    return BoostPricingModel.fromJson(response.data);
  }

  @override
  Future<BoostModel> createBoost({
    required double amountPaid,
    required int targetViews,
    required int durationHours,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.createBoost,
      data: {
        'amount_paid': amountPaid,
        'target_views': targetViews,
        'duration_hours': durationHours,
      },
    );
    return BoostModel.fromJson(response.data['boost']);
  }

  @override
  Future<BoostModel> activateBoost(int boostId) async {
    final response = await apiClient.post(ApiEndpoints.activateBoost(boostId));
    return BoostModel.fromJson(response.data['boost']);
  }

  @override
  Future<BoostModel?> getActiveBoost() async {
    try {
      final response = await apiClient.get(ApiEndpoints.activeBoost);
      return BoostModel.fromJson(response.data);
    } catch (e) {
      // 404 means no active boost
      return null;
    }
  }

  @override
  Future<List<BoostModel>> getBoostHistory() async {
    final response = await apiClient.get(ApiEndpoints.boostHistory);
    return (response.data as List)
        .map((json) => BoostModel.fromJson(json))
        .toList();
  }
}
