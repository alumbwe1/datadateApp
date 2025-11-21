import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../interactions/data/datasources/interactions_remote_datasource.dart'
    as interactions_ds;
import '../../../interactions/data/models/like_model.dart';
import '../../data/repositories/likes_repository_impl.dart';
import '../../domain/repositories/likes_repository.dart';

// Data source provider
final interactionsRemoteDataSourceProvider =
    Provider<interactions_ds.InteractionsRemoteDataSource>((ref) {
      return interactions_ds.InteractionsRemoteDataSourceImpl(
        apiClient: ref.watch(apiClientProvider),
      );
    });

// Repository provider
final likesRepositoryProvider = Provider<LikesRepository>((ref) {
  return LikesRepositoryImpl(
    remoteDataSource: ref.watch(interactionsRemoteDataSourceProvider),
  );
});

// Likes state
class LikesState {
  final List<LikeModel> sentLikes;
  final List<LikeModel> receivedLikes;
  final bool isLoading;
  final String? error;

  LikesState({
    this.sentLikes = const [],
    this.receivedLikes = const [],
    this.isLoading = false,
    this.error,
  });

  LikesState copyWith({
    List<LikeModel>? sentLikes,
    List<LikeModel>? receivedLikes,
    bool? isLoading,
    String? error,
  }) {
    return LikesState(
      sentLikes: sentLikes ?? this.sentLikes,
      receivedLikes: receivedLikes ?? this.receivedLikes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Likes notifier
class LikesNotifier extends StateNotifier<LikesState> {
  final LikesRepository _repository;

  LikesNotifier(this._repository) : super(LikesState());

  Future<void> loadSentLikes() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getSentLikes();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (likes) => state = state.copyWith(
        isLoading: false,
        sentLikes: likes,
        error: null,
      ),
    );
  }

  Future<void> loadReceivedLikes() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getReceivedLikes();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (likes) => state = state.copyWith(
        isLoading: false,
        receivedLikes: likes,
        error: null,
      ),
    );
  }

  Future<void> loadAllLikes() async {
    state = state.copyWith(isLoading: true, error: null);

    final sentResult = await _repository.getSentLikes();
    final receivedResult = await _repository.getReceivedLikes();

    if (sentResult.isLeft() || receivedResult.isLeft()) {
      final error = sentResult.fold(
        (failure) => failure.message,
        (_) => receivedResult.fold((failure) => failure.message, (_) => null),
      );
      state = state.copyWith(isLoading: false, error: error);
    } else {
      final sentLikes = sentResult.getOrElse(() => []);
      final receivedLikes = receivedResult.getOrElse(() => []);

      state = state.copyWith(
        isLoading: false,
        sentLikes: sentLikes,
        receivedLikes: receivedLikes,
        error: null,
      );
    }
  }
}

// Provider
final likesProvider = StateNotifierProvider<LikesNotifier, LikesState>((ref) {
  return LikesNotifier(ref.watch(likesRepositoryProvider));
});
