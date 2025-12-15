import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../encounters/data/datasources/profile_remote_datasource.dart';
import '../../../encounters/data/repositories/profile_repository_impl.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../encounters/domain/repositories/profile_repository.dart';

// Reels state
class ReelsState {
  final List<Profile> profiles;
  final bool isLoading;
  final String? error;

  ReelsState({this.profiles = const [], this.isLoading = false, this.error});

  ReelsState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ReelsState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Reels notifier
class ReelsNotifier extends StateNotifier<ReelsState> {
  final ProfileRepository _profileRepository;

  ReelsNotifier(this._profileRepository) : super(ReelsState());

  Future<void> loadReels() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _profileRepository.getProfilesWithVideos();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (profiles) => state = state.copyWith(
        isLoading: false,
        profiles: profiles,
        error: null,
      ),
    );
  }

  Future<void> recordProfileView(int profileId) async {
    try {
      await _profileRepository.recordProfileView(profileId);
    } catch (e) {
      // Silently fail - view tracking shouldn't block user interaction
    }
  }
}

final reelsProvider = StateNotifierProvider<ReelsNotifier, ReelsState>((ref) {
  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
  final profileRepository = ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
  );
  return ReelsNotifier(profileRepository);
});
