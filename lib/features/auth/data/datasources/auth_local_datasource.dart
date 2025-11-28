import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearAuthData();

  // User data caching
  Future<void> saveUserDataTimestamp(DateTime timestamp);
  Future<DateTime?> getUserDataTimestamp();
  Future<void> saveCachedUser(Map<String, dynamic> userData);
  Future<dynamic> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveAuthToken(String token) async {
    await secureStorage.write(key: AppConstants.keyAuthToken, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: AppConstants.keyAuthToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await sharedPreferences.setString(AppConstants.keyUserId, userId);
  }

  @override
  Future<String?> getUserId() async {
    return sharedPreferences.getString(AppConstants.keyUserId);
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: AppConstants.keyAuthToken);
    await secureStorage.delete(key: AppConstants.keyRefreshToken);
    await sharedPreferences.remove(AppConstants.keyUserId);
    await sharedPreferences.remove('userDataTimestamp');
    await sharedPreferences.remove('cachedUserData');
  }

  @override
  Future<void> saveUserDataTimestamp(DateTime timestamp) async {
    await sharedPreferences.setString(
      'userDataTimestamp',
      timestamp.toIso8601String(),
    );
  }

  @override
  Future<DateTime?> getUserDataTimestamp() async {
    final timestampStr = sharedPreferences.getString('userDataTimestamp');
    if (timestampStr == null) return null;
    return DateTime.tryParse(timestampStr);
  }

  @override
  Future<void> saveCachedUser(Map<String, dynamic> userData) async {
    await sharedPreferences.setString(
      'cachedUserData',
      userData.toString(), // Simple string storage
    );
  }

  @override
  Future<dynamic> getCachedUser() async {
    // For now, return null - full implementation would parse stored user data
    // This is a simplified version
    return null;
  }
}
