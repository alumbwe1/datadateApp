import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';

// Data sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final sharedPrefs = ref.watch(sharedPreferencesProvider);

  return AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    sharedPreferences: sharedPrefs,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(email, password);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) =>
          state = state.copyWith(isLoading: false, user: user, error: null),
    );
  }

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.register(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) =>
          state = state.copyWith(isLoading: false, user: user, error: null),
    );

    return result;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (user) => state = state.copyWith(user: user),
      );
    }
  }

  Future<String?> getAuthToken() async {
    return await _authRepository.getAuthToken();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
