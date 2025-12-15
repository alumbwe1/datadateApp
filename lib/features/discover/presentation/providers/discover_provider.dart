import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../encounters/data/datasources/profile_remote_datasource.dart';
import '../../../encounters/data/repositories/profile_repository_impl.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../encounters/domain/repositories/profile_repository.dart';

// Discover-specific state
class DiscoverState {
  final List<Profile> profiles;
  final bool isLoading;
  final String? error;

  DiscoverState({this.profiles = const [], this.isLoading = false, this.error});

  DiscoverState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return DiscoverState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Discover notifier
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final ProfileRepository _profileRepository;

  DiscoverNotifier(this._profileRepository) : super(DiscoverState());

  Future<void> loadRecommendedProfiles() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _profileRepository.getRecommendedProfiles();

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

  void clearProfiles() {
    state = state.copyWith(profiles: []);
  }
}

// Provider for discover page
final discoverProvider = StateNotifierProvider<DiscoverNotifier, DiscoverState>(
  (ref) {
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(
      apiClient: ref.watch(apiClientProvider),
    );
    final profileRepository = ProfileRepositoryImpl(
      remoteDataSource: profileRemoteDataSource,
    );
    return DiscoverNotifier(profileRepository);
  },
);
