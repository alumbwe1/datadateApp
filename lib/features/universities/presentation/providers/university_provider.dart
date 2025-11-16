import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/university_remote_datasource.dart';
import '../../data/repositories/university_repository_impl.dart';
import '../../domain/entities/university.dart';
import '../../domain/repositories/university_repository.dart';

// Data source
final universityRemoteDataSourceProvider = Provider<UniversityRemoteDataSource>(
  (ref) {
    return UniversityRemoteDataSourceImpl(
      apiClient: ref.watch(apiClientProvider),
    );
  },
);

// Repository
final universityRepositoryProvider = Provider<UniversityRepository>((ref) {
  return UniversityRepositoryImpl(
    remoteDataSource: ref.watch(universityRemoteDataSourceProvider),
  );
});

// Universities state
class UniversitiesState {
  final List<University> universities;
  final bool isLoading;
  final String? error;
  final University? selectedUniversity;

  UniversitiesState({
    this.universities = const [],
    this.isLoading = false,
    this.error,
    this.selectedUniversity,
  });

  UniversitiesState copyWith({
    List<University>? universities,
    bool? isLoading,
    String? error,
    University? selectedUniversity,
  }) {
    return UniversitiesState(
      universities: universities ?? this.universities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
    );
  }
}

// Universities notifier
class UniversitiesNotifier extends StateNotifier<UniversitiesState> {
  final UniversityRepository _universityRepository;

  UniversitiesNotifier(this._universityRepository) : super(UniversitiesState());

  Future<void> loadUniversities() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _universityRepository.getUniversities();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (universities) => state = state.copyWith(
        isLoading: false,
        universities: universities,
        error: null,
      ),
    );
  }

  void selectUniversity(University university) {
    state = state.copyWith(selectedUniversity: university);
  }

  void clearSelection() {
    state = state.copyWith(selectedUniversity: null);
  }
}

final universitiesProvider =
    StateNotifierProvider<UniversitiesNotifier, UniversitiesState>((ref) {
      return UniversitiesNotifier(ref.watch(universityRepositoryProvider));
    });
