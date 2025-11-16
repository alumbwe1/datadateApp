import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/university.dart';

abstract class UniversityRepository {
  Future<Either<Failure, List<University>>> getUniversities();
  Future<Either<Failure, University>> getUniversityBySlug(String slug);
}
