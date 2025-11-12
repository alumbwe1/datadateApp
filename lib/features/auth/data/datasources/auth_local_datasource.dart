import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearAuthData();
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
    await sharedPreferences.remove(AppConstants.keyUserId);
  }
}
