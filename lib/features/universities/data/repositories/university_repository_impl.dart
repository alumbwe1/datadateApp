import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/university.dart';
import '../../domain/repositories/university_repository.dart';
import '../datasources/university_remote_datasource.dart';

class UniversityRepositoryImpl implements UniversityRepository {
  final UniversityRemoteDataSource remoteDataSource;

  UniversityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<University>>> getUniversities() async {
    try {
      final universities = await remoteDataSource.getUniversities();
      return Right(universities);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to load universities: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, University>> getUniversityBySlug(String slug) async {
    try {
      final university = await remoteDataSource.getUniversityBySlug(slug);
      return Right(university);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to load university: ${e.toString()}'));
    }
  }
}
