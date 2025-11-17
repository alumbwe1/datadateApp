import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();
  Future<UserProfileModel> updateMyProfile(Map<String, dynamic> data);
  Future<String> uploadProfilePhoto(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileModel> getMyProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.myProfile);
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfileModel> updateMyProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(ApiEndpoints.myProfile, data: data);
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profile_photo': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        ApiEndpoints.uploadProfilePhoto,
        data: formData,
      );

      return response.data['profile_photo'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
