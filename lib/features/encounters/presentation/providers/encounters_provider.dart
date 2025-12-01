import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/services/filter_preferences_service.dart';
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
  final Map<String, dynamic> activeFilters;
  final int activeFilterCount;

  EncountersState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
    this.activeFilters = const {},
    this.activeFilterCount = 0,
  });

  EncountersState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
    int? currentIndex,
    Map<String, dynamic>? activeFilters,
    int? activeFilterCount,
  }) {
    return EncountersState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
      activeFilters: activeFilters ?? this.activeFilters,
      activeFilterCount: activeFilterCount ?? this.activeFilterCount,
    );
  }
}

// Encounters notifier
class EncountersNotifier extends StateNotifier<EncountersState> {
  final ProfileRepository _profileRepository;
  final FilterPreferencesService _filterService = FilterPreferencesService();

  EncountersNotifier(this._profileRepository) : super(EncountersState()) {
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final savedFilters = await _filterService.loadFilters();
    final filterCount = _countActiveFilters(savedFilters);
    state = state.copyWith(
      activeFilters: savedFilters,
      activeFilterCount: filterCount,
    );
  }

  int _countActiveFilters(Map<String, dynamic> filters) {
    int count = 0;
    filters.forEach((key, value) {
      if (value != null) {
        if (value is bool && value == true)
          count++;
        else if (value is String && value.isNotEmpty)
          count++;
        else if (value is int)
          count++;
        else if (value is List && value.isNotEmpty)
          count++;
      }
    });
    return count;
  }

  Future<void> loadProfiles(
    String userGender, {
    Map<String, dynamic>? filters,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    // Use provided filters or active filters
    final filtersToUse = filters ?? state.activeFilters;
    final queryParams = _filterService.buildQueryParams(filtersToUse);

    final result = await _profileRepository.getProfilesWithFilters(
      filters: queryParams,
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

  Future<void> applyFilters(
    Map<String, dynamic> filters,
    String userGender,
  ) async {
    await _filterService.saveFilters(filters);
    final filterCount = _countActiveFilters(filters);
    state = state.copyWith(
      activeFilters: filters,
      activeFilterCount: filterCount,
    );
    await loadProfiles(userGender, filters: filters);
  }

  Future<void> clearFilters(String userGender) async {
    await _filterService.clearFilters();
    state = state.copyWith(activeFilters: {}, activeFilterCount: 0);
    await loadProfiles(userGender);
  }

  Future<Map<String, dynamic>?> likeProfile(String profileId) async {
    final result = await _profileRepository.likeProfile(profileId);

    Map<String, dynamic>? matchInfo;
    result.fold(
      (failure) {
        // Throw the error so it can be caught in the UI
        throw Exception(failure.message);
      },
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
}

final encountersProvider =
    StateNotifierProvider<EncountersNotifier, EncountersState>((ref) {
      return EncountersNotifier(ref.watch(profileRepositoryProvider));
    });
