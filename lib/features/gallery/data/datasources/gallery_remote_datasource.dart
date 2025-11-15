import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/gallery_photo_model.dart';

abstract class GalleryRemoteDataSource {
  Future<List<GalleryPhotoModel>> getGalleryPhotos();
  Future<GalleryPhotoModel> uploadPhoto({
    required String imagePath,
    required int order,
  });
  Future<void> deletePhoto(int photoId);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final ApiClient apiClient;

  GalleryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GalleryPhotoModel>> getGalleryPhotos() async {
    final response = await apiClient.get<List<dynamic>>(ApiEndpoints.gallery);

    return response
        .map((json) => GalleryPhotoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GalleryPhotoModel> uploadPhoto({
    required String imagePath,
    required int order,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
      'order': order,
    });

    final response = await apiClient.uploadFile<Map<String, dynamic>>(
      ApiEndpoints.gallery,
      formData: formData,
    );

    return GalleryPhotoModel.fromJson(response);
  }

  @override
  Future<void> deletePhoto(int photoId) async {
    await apiClient.delete(ApiEndpoints.deleteGalleryPhoto(photoId));
  }
}
