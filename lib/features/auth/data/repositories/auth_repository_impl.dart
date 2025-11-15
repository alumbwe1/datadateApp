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
    required int age,
    required String gender,
    required String university,
    required String relationshipGoal,
  }) async {
    try {
      // Map relationship goal to intent
      final intent = _mapRelationshipGoalToIntent(relationshipGoal);

      // Map gender to preferred genders (opposite)
      final preferredGenders = _getPreferredGenders(gender);

      // Register user
      final user = await remoteDataSource.register(
        username: name.toLowerCase().replaceAll(' ', '_'),
        email: email,
        password: password,
        university: int.tryParse(university) ?? 1, // Parse university ID
        gender: gender.toLowerCase(),
        preferredGenders: preferredGenders,
        intent: intent,
      );

      // Note: Registration doesn't return tokens, need to login
      final tokens = await remoteDataSource.login(email, password);
      await localDataSource.saveAuthToken(tokens['access']!);
      await localDataSource.saveRefreshToken(tokens['refresh']!);
      await localDataSource.saveUserId(user.id);

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

  String _mapRelationshipGoalToIntent(String goal) {
    switch (goal.toLowerCase()) {
      case 'relationship':
        return 'dating';
      case 'dating':
        return 'dating';
      case 'new friends':
      case 'friends':
        return 'friendship';
      default:
        return 'dating';
    }
  }

  List<String> _getPreferredGenders(String userGender) {
    // Default to opposite gender
    switch (userGender.toLowerCase()) {
      case 'male':
        return ['female'];
      case 'female':
        return ['male'];
      default:
        return ['male', 'female', 'non-binary'];
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
}
