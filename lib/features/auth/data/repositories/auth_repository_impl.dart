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
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Get tokens from API
      final tokens = await remoteDataSource.login(email, password);

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
        university: 1, // Default university, will update in onboarding
        gender: 'male', // Default, will update in onboarding
        preferredGenders: ['female'], // Default, will update in onboarding
        intent: 'dating', // Default, will update in onboarding
      );

      // Auto-login after registration
      final tokens = await remoteDataSource.login(email, password);
      await localDataSource.saveAuthToken(tokens['access']!);
      await localDataSource.saveRefreshToken(tokens['refresh']!);
      await localDataSource.saveUserId(user.id.toString());

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
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return const Left(AuthFailure('No user logged in'));
      }

      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthFailure catch (e) {
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
}
