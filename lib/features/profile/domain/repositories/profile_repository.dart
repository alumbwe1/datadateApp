import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getMyProfile();
  Future<Either<Failure, UserProfile>> updateMyProfile(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, String>> uploadProfilePhoto(String filePath);
  Future<Either<Failure, List<String>>> uploadProfilePhotos(
    List<String> filePaths,
  );
  Future<Either<Failure, void>> deleteAccount({
    required String reason,
    String? otherReason,
  });
}
