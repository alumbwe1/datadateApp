import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, String>> login(String email, String password);
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required int university,
    required String gender,
    required List<String> preferredGenders,
    required String intent,
  });
  Future<String> refreshToken(String refreshToken);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, String>> login(String email, String password) async {
    // Note: Login doesn't require authentication
    final response = await apiClient.postPublic<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return {
      'access': response['access'] as String,
      'refresh': response['refresh'] as String,
    };
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required int university,
    required String gender,
    required List<String> preferredGenders,
    required String intent,
  }) async {
    // Note: Registration doesn't require authentication
    final response = await apiClient.postPublic<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'university': university,
        'gender': gender,
        'preferred_genders': preferredGenders,
        'intent': intent,
      },
    );

    return UserModel.fromJson(response);
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    // Note: Token refresh doesn't require authentication (uses refresh token)
    final response = await apiClient.postPublic<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refresh': refreshToken},
    );

    return response['access'] as String;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.currentUser,
    );

    return UserModel.fromJson(response);
  }
}
