import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../interactions/data/models/like_model.dart';

abstract class LikesRepository {
  Future<Either<Failure, List<LikeModel>>> getSentLikes();
  Future<Either<Failure, List<LikeModel>>> getReceivedLikes();
}
