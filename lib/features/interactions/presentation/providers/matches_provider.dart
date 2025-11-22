import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/interactions_remote_datasource.dart';
import '../../data/models/match_model.dart';
import '../../../../core/providers/api_providers.dart';

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
    try {
      final matches = await _dataSource.getMatches();
      state = state.copyWith(matches: matches, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
