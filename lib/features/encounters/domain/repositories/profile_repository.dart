import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<Profile>>> getProfiles({
    required String userGender,
    String? relationshipGoal,
    int count,
  });
  Future<Either<Failure, Map<String, dynamic>>> likeProfile(String profileId);
  Future<Either<Failure, void>> skipProfile(String profileId);
}
