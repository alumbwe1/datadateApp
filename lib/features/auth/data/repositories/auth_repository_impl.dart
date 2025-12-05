import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      // Get tokens from API
      final tokens = await remoteDataSource.login(username, password);

      // Save tokens
      await localDataSource.saveAuthToken(tokens['access']!);
      await localDataSource.saveRefreshToken(tokens['refresh']!);

      // Get current user data
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUserId(user.id);

      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create username from name
      final username = name.toLowerCase().replaceAll(' ', '_');

      // Register with minimal data - will complete profile in onboarding
      final user = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );

      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } on ValidationFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      // Also clear tokens from API client
      // The ApiClient will handle this through its clearTokens method
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String currentPassword) async {
    try {
      await remoteDataSource.deleteAccount(currentPassword);
      await localDataSource.clearAuthData();
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Account deletion failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('No user logged in'));
      }

      // Add timeout to prevent hanging
      final user = await remoteDataSource.getCurrentUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw AuthFailure('Request timeout - please check your connection');
        },
      );
      return Right(user);
    } on AuthFailure catch (e) {
      // Clear local tokens if auth fails
      await localDataSource.clearAuthData();
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getAuthToken();
    return token != null;
  }

  @override
  Future<String?> getAuthToken() async {
    return await localDataSource.getAuthToken();
  }

  @override
  Future<bool> shouldRefreshUserData() async {
    final lastFetch = await localDataSource.getUserDataTimestamp();
    if (lastFetch == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastFetch);

    // Refresh if more than 7 days old
    return difference.inDays >= 7;
  }

  @override
  Future<User?> getCachedUser() async {
    return await localDataSource.getCachedUser();
  }

  @override
  Future<void> saveUserDataTimestamp() async {
    await localDataSource.saveUserDataTimestamp(DateTime.now());
  }
}
