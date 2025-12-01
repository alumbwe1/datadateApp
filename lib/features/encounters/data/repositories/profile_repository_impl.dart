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
      // Get opposite gender
      final oppositeGender = _getOppositeGender(userGender);

      // Map relationship goal to intent
      final intent = relationshipGoal != null
          ? _mapRelationshipGoalToIntent(relationshipGoal)
          : null;

      final profiles = await remoteDataSource.getProfiles(
        gender: oppositeGender,
        intent: intent,
        page: 1,
      );

      return Right(profiles);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to load profiles: ${e.toString()}'));
    }
  }

  String _getOppositeGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'female';
      case 'female':
        return 'male';
      default:
        return 'female';
    }
  }

  String _mapRelationshipGoalToIntent(String goal) {
    switch (goal.toLowerCase()) {
      case 'relationship':
      case 'dating':
        return 'dating';
      case 'new friends':
      case 'friends':
        return 'friendship';
      case 'networking':
        return 'networking';
      default:
        return 'dating';
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfilesWithFilters({
    required Map<String, dynamic> filters,
    int count = 20,
  }) async {
    try {
      final profiles = await remoteDataSource.getProfilesWithFilters(filters);
      return Right(profiles);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to load profiles: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> likeProfile(
    String profileId,
  ) async {
    try {
      final id = int.tryParse(profileId);
      if (id == null) {
        return const Left(ValidationFailure('Invalid profile ID'));
      }

      final result = await remoteDataSource.likeProfile(id);
      return Right(result);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      // Check if it's an "already liked" error
      if (e.message.toLowerCase().contains('already liked')) {
        return Left(ValidationFailure('You have already liked this profile'));
      }
      return Left(e);
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('already liked')) {
        return Left(ValidationFailure('You have already liked this profile'));
      }
      return Left(ServerFailure('Failed to like profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> skipProfile(String profileId) async {
    try {
      // Skip is just a local action, no API call needed
      // Unless you want to track skips on the backend
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to skip profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getRecommendedProfiles() async {
    try {
      final profiles = await remoteDataSource.getRecommendedProfiles();
      return Right(profiles);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to load recommended profiles: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> recordProfileView(int profileId) async {
    try {
      await remoteDataSource.recordProfileView(profileId);
      return const Right(null);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to record view: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfilesWithVideos() async {
    try {
      final profiles = await remoteDataSource.getProfilesWithVideos();
      return Right(profiles);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to load video profiles: ${e.toString()}'),
      );
    }
  }
}
