import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() async {
    try {
      final profile = await remoteDataSource.getMyProfile();
      return Right(profile);
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateMyProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final profile = await remoteDataSource.updateMyProfile(data);
      return Right(profile);
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(String filePath) async {
    try {
      final photoUrl = await remoteDataSource.uploadProfilePhoto(filePath);
      return Right(photoUrl);
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          return errors.values.first.toString();
        }
      }
      return 'Server error: ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    }
    return 'Network error. Please try again.';
  }
}
