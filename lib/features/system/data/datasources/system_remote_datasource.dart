import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/system_status_model.dart';

abstract class SystemRemoteDataSource {
  Future<SystemStatusModel> getSystemStatus();
}

class SystemRemoteDataSourceImpl implements SystemRemoteDataSource {
  final ApiClient apiClient;

  SystemRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SystemStatusModel> getSystemStatus() async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.systemStatus,
        options: Options(
          headers: {
            'requiresAuth': false, // Public endpoint
          },
        ),
      );
      return SystemStatusModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
