import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/university_model.dart';

abstract class UniversityRemoteDataSource {
  Future<List<UniversityModel>> getUniversities();
  Future<UniversityModel> getUniversityBySlug(String slug);
}

class UniversityRemoteDataSourceImpl implements UniversityRemoteDataSource {
  final ApiClient apiClient;

  UniversityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UniversityModel>> getUniversities() async {
    // Note: This endpoint doesn't require authentication
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.universities,
    );

    return response
        .map((json) => UniversityModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UniversityModel> getUniversityBySlug(String slug) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.universityBySlug(slug),
    );

    return UniversityModel.fromJson(response);
  }
}
