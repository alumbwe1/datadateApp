import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

// Data source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});

// Encounters state
class EncountersState {
  final List<Profile> profiles;
  final bool isLoading;
  final String? error;
  final int currentIndex;

  EncountersState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
  });

  EncountersState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
    int? currentIndex,
  }) {
    return EncountersState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// Encounters notifier
class EncountersNotifier extends StateNotifier<EncountersState> {
  final ProfileRepository _profileRepository;

  EncountersNotifier(this._profileRepository) : super(EncountersState());

  Future<void> loadProfiles(String userGender) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _profileRepository.getProfiles(
      userGender: userGender,
      count: 20,
    );

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

  Future<Map<String, dynamic>?> likeProfile(String profileId) async {
    final result = await _profileRepository.likeProfile(profileId);

    Map<String, dynamic>? matchInfo;
    result.fold(
      (failure) => print('Error liking profile: ${failure.message}'),
      (response) {
        matchInfo = response;
      },
    );

    _moveToNext();
    return matchInfo;
  }

  Future<void> skipProfile(String profileId) async {
    await _profileRepository.skipProfile(profileId);
    _moveToNext();
  }

  void _moveToNext() {
    if (state.currentIndex < state.profiles.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      // Load more profiles when running out
      state = state.copyWith(profiles: [], currentIndex: 0);
    }
  }
}

final encountersProvider =
    StateNotifierProvider<EncountersNotifier, EncountersState>((ref) {
      return EncountersNotifier(ref.watch(profileRepositoryProvider));
    });
