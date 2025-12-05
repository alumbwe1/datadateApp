import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/custom_logs.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, String>> login(String email, String password);
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  });
  Future<void> deleteAccount(String currentPassword);
  Future<String> refreshToken(String refreshToken);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, String>> login(String username, String password) async {
    try {
      CustomLogs.info(
        'Attempting login',
        tag: 'AUTH',
        metadata: {'username': username},
      );

      // Note: Login doesn't require authentication
      // Backend requires 'username' field (can be email or username)
      final response = await apiClient.postPublic<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      CustomLogs.success(
        'Login successful',
        tag: 'AUTH',
        metadata: {'username': username},
      );

      return {
        'access': response['access'] as String,
        'refresh': response['refresh'] as String,
      };
    } catch (e, stackTrace) {
      CustomLogs.error(
        'Login failed',
        tag: 'AUTH',
        error: e,
        stackTrace: stackTrace,
        metadata: {'username': username},
      );
      rethrow;
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      CustomLogs.info(
        'Attempting registration',
        tag: 'AUTH',
        metadata: {'username': username, 'email': email},
      );

      // Note: Registration doesn't require authentication
      // Step 1: Create account with basic info only
      final response = await apiClient.postPublic<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          're_password': password,
        },
      );

      final user = UserModel.fromJson(response);

      CustomLogs.success(
        'Registration successful',
        tag: 'AUTH',
        metadata: {'userId': user.id, 'name': user.name, 'email': user.email},
      );

      return user;
    } catch (e, stackTrace) {
      CustomLogs.error(
        'Registration failed',
        tag: 'AUTH',
        error: e,
        stackTrace: stackTrace,
        metadata: {'username': username, 'email': email},
      );
      rethrow;
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      CustomLogs.info('Attempting token refresh', tag: 'AUTH');

      // Note: Token refresh doesn't require authentication (uses refresh token)
      final response = await apiClient.postPublic<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      CustomLogs.success('Token refresh successful', tag: 'AUTH');

      return response['access'] as String;
    } catch (e, stackTrace) {
      CustomLogs.error(
        'Token refresh failed',
        tag: 'AUTH',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      CustomLogs.info('Fetching current user', tag: 'AUTH');

      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.currentUser,
      );

      final user = UserModel.fromJson(response);

      CustomLogs.success(
        'Current user fetched',
        tag: 'AUTH',
        metadata: {'userId': user.id, 'name': user.name, 'email': user.email},
      );

      return user;
    } catch (e, stackTrace) {
      CustomLogs.error(
        'Failed to fetch current user',
        tag: 'AUTH',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String currentPassword) async {
    try {
      CustomLogs.info('Attempting account deletion', tag: 'AUTH');

      await apiClient.delete(
        ApiEndpoints.currentUser, // /auth/users/me
        data: {'current_password': currentPassword},
      );

      CustomLogs.success('Account deletion successful', tag: 'AUTH');
    } catch (e, stackTrace) {
      CustomLogs.error(
        'Account deletion failed',
        tag: 'AUTH',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
