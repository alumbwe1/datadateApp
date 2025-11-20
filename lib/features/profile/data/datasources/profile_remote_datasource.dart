import 'package:datadate/core/utils/custom_logs.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();
  Future<UserProfileModel> updateMyProfile(Map<String, dynamic> data);
  Future<String> uploadProfilePhoto(String filePath);
  Future<List<String>> uploadProfilePhotos(List<String> filePaths);
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
      CustomLogs.info(
        '📤 Uploading photo to: ${ApiEndpoints.uploadProfilePhotos}',
      );
      CustomLogs.info('📁 File path: $filePath');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      CustomLogs.info('📦 FormData created with image field');

      final response = await dio.post(
        ApiEndpoints.uploadProfilePhotos,
        data: formData,
      );

      CustomLogs.success('✅ Upload response: ${response.data}');

      // The API returns the photo URL in the response
      // Adjust based on actual API response structure
      if (response.data is Map<String, dynamic>) {
        return response.data['image_url'] as String? ??
            response.data['url'] as String? ??
            response.data['image'] as String? ??
            '';
      }

      return response.data.toString();
    } catch (e) {
      CustomLogs.error('❌ Error uploading photo: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadProfilePhotos(List<String> filePaths) async {
    try {
      CustomLogs.info(
        '📤 Uploading ${filePaths.length} photos to: ${ApiEndpoints.uploadProfilePhotos}',
      );

      // Create FormData with multiple images
      final formDataMap = <String, dynamic>{};

      // Add all images as a list with the same field name
      final List<MultipartFile> imageFiles = [];
      for (int i = 0; i < filePaths.length; i++) {
        CustomLogs.info('📁 Adding photo ${i + 1}: ${filePaths[i]}');
        imageFiles.add(await MultipartFile.fromFile(filePaths[i]));
      }

      // Try different field names that the API might accept
      formDataMap['photos'] = imageFiles;

      final formData = FormData.fromMap(formDataMap);

      CustomLogs.info('📦 FormData created with ${filePaths.length} images');
      CustomLogs.info('📦 FormData fields: ${formData.fields}');
      CustomLogs.info('📦 FormData files: ${formData.files.length}');

      final response = await dio.post(
        ApiEndpoints.uploadProfilePhotos,
        data: formData,
      );

      CustomLogs.success('✅ Upload response: ${response.data}');

      // Parse response to get list of URLs
      final List<String> uploadedUrls = [];

      if (response.data is Map<String, dynamic>) {
        // Check for various possible response formats
        if (response.data.containsKey('image_urls')) {
          final urls = response.data['image_urls'] as List;
          uploadedUrls.addAll(urls.map((url) => url.toString()));
        } else if (response.data.containsKey('images')) {
          final urls = response.data['images'] as List;
          uploadedUrls.addAll(urls.map((url) => url.toString()));
        } else if (response.data.containsKey('urls')) {
          final urls = response.data['urls'] as List;
          uploadedUrls.addAll(urls.map((url) => url.toString()));
        } else if (response.data.containsKey('imageUrls')) {
          final urls = response.data['imageUrls'] as List;
          uploadedUrls.addAll(urls.map((url) => url.toString()));
        }
      } else if (response.data is List) {
        uploadedUrls.addAll(
          (response.data as List).map((url) => url.toString()),
        );
      }

      CustomLogs.success(
        '✅ Uploaded ${uploadedUrls.length} photos successfully',
      );
      return uploadedUrls;
    } catch (e) {
      CustomLogs.error('❌ Error uploading photos: $e');
      if (e is DioException) {
        CustomLogs.error('❌ Response data: ${e.response?.data}');
        CustomLogs.error('❌ Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
