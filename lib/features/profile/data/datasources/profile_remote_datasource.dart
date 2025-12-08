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
        '📤 Uploading photo to: ${ApiEndpoints.uploadProfilePhoto}',
      );
      CustomLogs.info('📁 File path: $filePath');

      final formData = FormData.fromMap({
        'photos': await MultipartFile.fromFile(filePath),
      });

      CustomLogs.info('📦 FormData created with image field');

      final response = await dio.post(
        ApiEndpoints.uploadProfilePhoto,
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
      CustomLogs.info('📤 Uploading ${filePaths.length} photos one by one');

      final List<String> uploadedUrls = [];

      // Upload all photos in a single request
      final List<MultipartFile> photoFiles = [];
      for (int i = 0; i < filePaths.length; i++) {
        CustomLogs.info('📁 Adding photo ${i + 1}: ${filePaths[i]}');
        photoFiles.add(await MultipartFile.fromFile(filePaths[i]));
      }

      final formData = FormData.fromMap({'photos': photoFiles});

      CustomLogs.info(
        '📦 Uploading ${photoFiles.length} photos in one request',
      );

      try {
        final response = await dio.post(
          ApiEndpoints.uploadProfilePhoto,
          data: formData,
        );

        CustomLogs.success('✅ Upload response: ${response.data}');

        // Extract URLs from response
        // Backend returns: { "detail": "...", "profile": { "imageUrls": [...] } }
        if (response.data is Map<String, dynamic>) {
          // Check for nested profile.imageUrls (actual backend response)
          if (response.data.containsKey('profile')) {
            final profile = response.data['profile'];
            if (profile is Map<String, dynamic> &&
                profile.containsKey('imageUrls')) {
              final urls = profile['imageUrls'] as List;
              uploadedUrls.addAll(urls.map((url) => url.toString()));
              CustomLogs.success(
                '✅ Extracted ${uploadedUrls.length} URLs from profile.imageUrls',
              );
            }
          }
          // Fallback: Check for direct imageUrls
          else if (response.data.containsKey('imageUrls')) {
            final urls = response.data['imageUrls'] as List;
            uploadedUrls.addAll(urls.map((url) => url.toString()));
          }
          // Check for 'photos' array with objects containing 'url' field
          else if (response.data.containsKey('photos')) {
            final photos = response.data['photos'] as List;
            for (var photo in photos) {
              if (photo is Map<String, dynamic> && photo.containsKey('url')) {
                uploadedUrls.add(photo['url'].toString());
              }
            }
          }
        } else if (response.data is List) {
          uploadedUrls.addAll(
            (response.data as List).map((url) => url.toString()),
          );
        }

        CustomLogs.success('✅ Extracted ${uploadedUrls.length} URLs');
        if (uploadedUrls.isNotEmpty) {
          CustomLogs.info('📸 URLs: $uploadedUrls');
        }
      } catch (e) {
        CustomLogs.error('❌ Error uploading photos: $e');
        if (e is DioException) {
          CustomLogs.error('❌ Response data: ${e.response?.data}');
          CustomLogs.error('❌ Status code: ${e.response?.statusCode}');
        }
        rethrow;
      }

      if (uploadedUrls.isEmpty) {
        throw Exception('No photos were uploaded successfully');
      }

      CustomLogs.success(
        '✅ Step 1 complete: Uploaded ${uploadedUrls.length}/${filePaths.length} photo files',
      );
      CustomLogs.info('📸 Uploaded URLs: $uploadedUrls');

      // Step 2: Send the URLs to /photos/ endpoint
      CustomLogs.info('📤 Step 2: Sending URLs to /photos/ endpoint');
      try {
        final response = await dio.post(
          ApiEndpoints.uploadProfilePhotos, // Use photos endpoint
          data: {'imageUrls': uploadedUrls},
        );

        CustomLogs.success('✅ Photos endpoint response: ${response.data}');
      } catch (e) {
        CustomLogs.error('❌ Error sending URLs to photos endpoint: $e');
        if (e is DioException) {
          CustomLogs.error('❌ Response data: ${e.response?.data}');
        }
        // Don't throw here - we already have the URLs
      }

      return uploadedUrls;
    } catch (e) {
      CustomLogs.error('❌ Error in uploadProfilePhotos: $e');
      rethrow;
    }
  }
}
