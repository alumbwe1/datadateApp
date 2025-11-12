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
      final user = await remoteDataSource.login(email, password);
      await localDataSource.saveAuthToken('mock_token_${user.id}');
      await localDataSource.saveUserId(user.id);
      return Right(user);
    } catch (e) {
      return const Left(AuthFailure('Login failed'));
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
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        age: age,
        gender: gender,
        university: university,
        relationshipGoal: relationshipGoal,
      );
      await localDataSource.saveAuthToken('mock_token_${user.id}');
      await localDataSource.saveUserId(user.id);
      return Right(user);
    } catch (e) {
      return const Left(AuthFailure('Registration failed'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userId = await localDataSource.getUserId();
      if (userId == null) {
        return const Left(AuthFailure('No user logged in'));
      }
      // Mock user data
      final user = await remoteDataSource.login('mock@email.com', 'password');
      return Right(user);
    } catch (e) {
      return const Left(AuthFailure('Failed to get current user'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getAuthToken();
    return token != null;
  }
}
