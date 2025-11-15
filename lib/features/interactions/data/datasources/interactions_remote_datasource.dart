import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/match_model.dart';
import '../models/like_model.dart';
import '../models/profile_view_model.dart';

abstract class InteractionsRemoteDataSource {
  Future<List<MatchModel>> getMatches();
  Future<List<LikeModel>> getLikes({required String type});
  Future<LikeModel> createLike({
    required int likedUserId,
    required String likeType,
  });
  Future<List<ProfileViewModel>> getProfileViews();
  Future<ProfileViewModel> recordProfileView(int viewedUserId);
}

class InteractionsRemoteDataSourceImpl implements InteractionsRemoteDataSource {
  final ApiClient apiClient;

  InteractionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MatchModel>> getMatches() async {
    final response = await apiClient.get<List<dynamic>>(ApiEndpoints.matches);

    return response
        .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LikeModel>> getLikes({required String type}) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.likes,
      queryParameters: {'type': type},
    );

    return response
        .map((json) => LikeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LikeModel> createLike({
    required int likedUserId,
    required String likeType,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.likes,
      data: {'liked': likedUserId, 'like_type': likeType},
    );

    return LikeModel.fromJson(response);
  }

  @override
  Future<List<ProfileViewModel>> getProfileViews() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.profileViews,
    );

    return response
        .map((json) => ProfileViewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProfileViewModel> recordProfileView(int viewedUserId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.profileViews,
      data: {'viewed': viewedUserId},
    );

    return ProfileViewModel.fromJson(response);
  }
}
