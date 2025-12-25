import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../../../core/utils/custom_logs.dart';
import '../../data/datasources/interactions_remote_datasource.dart';
import '../../data/models/match_model.dart';
import '../../data/services/matches_local_storage_service.dart';

final matchesDataSourceProvider = Provider<InteractionsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InteractionsRemoteDataSourceImpl(apiClient: apiClient);
});

final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((
  ref,
) {
  final dataSource = ref.watch(matchesDataSourceProvider);
  return MatchesNotifier(dataSource);
});

class MatchesState {
  final List<MatchModel> matches;
  final bool isLoading;
  final String? error;

  MatchesState({this.matches = const [], this.isLoading = false, this.error});

  MatchesState copyWith({
    List<MatchModel>? matches,
    bool? isLoading,
    String? error,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final InteractionsRemoteDataSource _dataSource;

  MatchesNotifier(this._dataSource) : super(MatchesState());

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: null);

    // Load cached matches first for instant display
    final cachedMatches = await MatchesLocalStorageService.getCachedMatches();
    if (cachedMatches.isNotEmpty) {
      state = state.copyWith(matches: cachedMatches, isLoading: false);
      CustomLogs.info('📱 Loaded ${cachedMatches.length} cached matches');
    }

    try {
      final matches = await _dataSource.getMatches();
      state = state.copyWith(matches: matches, isLoading: false);

      // Cache the matches
      await MatchesLocalStorageService.saveMatches(matches);
      CustomLogs.info('✅ Loaded ${matches.length} matches from API');
    } catch (e) {
      CustomLogs.error('❌ Error loading matches: $e');

      // If we have cached data, don't show error
      if (cachedMatches.isNotEmpty) {
        CustomLogs.info('📱 Using cached matches due to network error');
        state = state.copyWith(isLoading: false);
      } else {
        // Only show error if we have no cached data
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('Failed host lookup') ||
            errorMessage.contains('No address associated with hostname')) {
          errorMessage =
              'No internet connection. Please check your network and try again.';
        } else if (errorMessage.contains('timeout')) {
          errorMessage = 'Connection timeout. Please try again.';
        } else {
          errorMessage = 'Unable to load matches. Pull down to retry.';
        }

        state = state.copyWith(isLoading: false, error: errorMessage);
      }
    }
  }

  Future<void> refreshMatches() async {
    try {
      final matches = await _dataSource.getMatches();
      state = state.copyWith(matches: matches);

      // Cache the updated matches
      await MatchesLocalStorageService.saveMatches(matches);
      CustomLogs.info('✅ Refreshed ${matches.length} matches');
    } catch (e) {
      CustomLogs.info('⚠️ Failed to refresh matches: $e');
      // Silent fail on refresh - keep existing data
    }
  }
}
