import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Profile>>> getProfiles({
    required String userGender,
    String? relationshipGoal,
    int count = 10,
  }) async {
    try {
      final profiles = await remoteDataSource.getProfiles(
        userGender: userGender,
        relationshipGoal: relationshipGoal,
        count: count,
      );
      return Right(profiles);
    } catch (e) {
      return Left(ServerFailure('Failed to load profiles: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> likeProfile(String profileId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to like profile'));
    }
  }

  @override
  Future<Either<Failure, void>> skipProfile(String profileId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to skip profile'));
    }
  }
}
