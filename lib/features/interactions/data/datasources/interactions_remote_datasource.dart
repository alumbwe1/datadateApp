import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/like_model.dart';
import '../models/match_model.dart';
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
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.matches,
    );

    List<Map<String, dynamic>> matchesData = [];

    // Handle paginated response
    if (response.containsKey('results')) {
      matchesData = (response['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }
    // Fallback for non-paginated response
    else if (response is List) {
      matchesData = (response as List<dynamic>).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Unexpected response format for matches');
    }

    // Get current user ID from stored auth data
    final currentUserId = await _getCurrentUserId();

    return matchesData.map((json) {
      final match = MatchModel.fromJson(json);
      // Determine which user is the "other" user
      final otherUser = match.user1.id == currentUserId
          ? match.user2
          : match.user1;

      return MatchModel(
        id: match.id,
        user1: match.user1,
        user2: match.user2,
        otherUser: otherUser,
        createdAt: match.createdAt,
      );
    }).toList();
  }

  Future<int?> _getCurrentUserId() async {
    try {
      // Get user ID from profile endpoint
      final userData = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.myProfile,
      );
      return userData['user']?['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LikeModel>> getLikes({required String type}) async {
    // Use the correct endpoint based on type
    final endpoint = type == 'received'
        ? ApiEndpoints.receivedLikes
        : ApiEndpoints.likes;

    try {
      // Try to get as dynamic first to handle both List and Map responses
      final response = await apiClient.get<dynamic>(endpoint);

      // Handle direct list response (non-paginated)
      if (response is List) {
        return response
            .map((json) => LikeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Handle paginated response with 'results' key
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        return results
            .map((json) => LikeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        'Unexpected response format for likes: ${response.runtimeType}',
      );
    } catch (e) {
      rethrow;
    }
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
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.profileViews,
    );

    // Handle paginated response
    if (response.containsKey('results')) {
      final results = response['results'] as List<dynamic>;
      return results
          .map(
            (json) => ProfileViewModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }
    // Fallback for non-paginated response
    else if (response is List) {
      return (response as List<dynamic>)
          .map(
            (json) => ProfileViewModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('Unexpected response format for profile views');
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
