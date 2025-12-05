import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount(String currentPassword);
  Future<Either<Failure, User>> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String?> getAuthToken();

  // Caching methods
  Future<bool> shouldRefreshUserData();
  Future<User?> getCachedUser();
  Future<void> saveUserDataTimestamp();
}
