import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../interactions/data/datasources/interactions_remote_datasource.dart';
import '../../../interactions/data/models/like_model.dart';
import '../../domain/repositories/likes_repository.dart';

class LikesRepositoryImpl implements LikesRepository {
  final InteractionsRemoteDataSource remoteDataSource;

  LikesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LikeModel>>> getSentLikes() async {
    try {
      final likes = await remoteDataSource.getLikes(type: 'sent');
      return Right(likes);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch sent likes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LikeModel>>> getReceivedLikes() async {
    try {
      final likes = await remoteDataSource.getLikes(type: 'received');
      return Right(likes);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch received likes: ${e.toString()}'),
      );
    }
  }
}
