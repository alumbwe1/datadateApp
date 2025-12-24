import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> getProfiles({
    String? gender,
    String? intent,
    int? university,
    int page = 1,
  });

  Future<List<ProfileModel>> getProfilesWithFilters(
    Map<String, dynamic> filters,
  );

  Future<List<ProfileModel>> getRecommendedProfiles();
  Future<List<ProfileModel>> getProfilesWithVideos();

  Future<ProfileModel> getProfileDetail(int id);
  Future<Map<String, dynamic>> likeProfile(int profileId);
  Future<void> recordProfileView(int profileId);
  Future<ProfileModel> createProfile({
    required String bio,
    required int age,
    required String major,
    required int graduationYear,
    required List<String> interests,
    String? profilePhoto,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProfileModel>> getProfiles({
    String? gender,
    String? intent,
    int? university,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};

      if (gender != null) queryParams['gender'] = gender;
      if (intent != null) queryParams['intent'] = intent;
      if (university != null) queryParams['university'] = university;

      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.profiles,
        queryParameters: queryParams,
      );

      final paginatedResponse = PaginatedResponse.fromJson(
        response,
        (json) => ProfileModel.fromJson(json),
      );

      return paginatedResponse.results;
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }

  @override
  Future<List<ProfileModel>> getProfilesWithFilters(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiEndpoints.discoverProfiles,
        queryParameters: filters,
      );

      // The discover endpoint returns a list directly, not paginated
      if (response is List) {
        return response
            .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If it's paginated, handle it
        final paginatedResponse = PaginatedResponse.fromJson(
          response,
          (json) => ProfileModel.fromJson(json),
        );
        return paginatedResponse.results;
      }

      return [];
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }

  @override
  Future<ProfileModel> getProfileDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.profileDetail(id),
    );

    return ProfileModel.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> likeProfile(int profileId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.likes,
        data: {'liked': profileId, 'like_type': 'profile'},
      );

      // Check if it's a match by looking at the response
      // The API returns a Like object, but may include match info
      return {
        'matched': response['matched'] ?? false,
        'match_id': response['match_id'],
        'detail': response['detail'] ?? 'Profile liked successfully',
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProfileModel>> getRecommendedProfiles() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiEndpoints.recommendedProfiles,
      );

      // The recommended endpoint returns a list directly
      if (response is List) {
        return response
            .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If it's paginated, handle it
        final paginatedResponse = PaginatedResponse.fromJson(
          response,
          (json) => ProfileModel.fromJson(json),
        );
        return paginatedResponse.results;
      }

      return [];
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }

  @override
  Future<void> recordProfileView(int profileId) async {
    try {
      await apiClient.post(
        ApiEndpoints.profileViews,
        data: {
          'profile_ids': [profileId],
        },
      );
    } catch (e) {
      // Silently fail - view tracking shouldn't block user interaction
    }
  }

  @override
  Future<List<ProfileModel>> getProfilesWithVideos() async {
    try {
      final response = await apiClient.get<dynamic>(
        ApiEndpoints.discoverWithVideos,
      );

      // The endpoint returns a list directly
      if (response is List) {
        return response
            .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // If it's paginated, handle it
        final paginatedResponse = PaginatedResponse.fromJson(
          response,
          (json) => ProfileModel.fromJson(json),
        );
        return paginatedResponse.results;
      }

      return [];
    } catch (e) {
      // Return empty list if API fails
      return [];
    }
  }

  @override
  Future<ProfileModel> createProfile({
    required String bio,
    required int age,
    required String major,
    required int graduationYear,
    required List<String> interests,
    String? profilePhoto,
  }) async {
    final formData = FormData.fromMap({
      'bio': bio,
      'age': age,
      'major': major,
      'graduation_year': graduationYear,
      'interests': interests,
      if (profilePhoto != null)
        'profile_photo': await MultipartFile.fromFile(profilePhoto),
    });

    final response = await apiClient.uploadFile<Map<String, dynamic>>(
      ApiEndpoints.profiles,
      formData: formData,
    );

    return ProfileModel.fromJson(response);
  }
}
