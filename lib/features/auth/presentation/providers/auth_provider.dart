import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/logout_service.dart';
import '../../../../core/utils/custom_logs.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

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

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(username, password);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) =>
          state = state.copyWith(isLoading: false, user: user, error: null),
    );

    return result.isRight();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.register(
      email: email,
      password: password,
      name: username,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) =>
          state = state.copyWith(isLoading: false, user: user, error: null),
    );

    return result.isRight();
  }

  Future<void> logout() async {
    try {
      // First try to logout from server
      await _authRepository.logout();
    } catch (e) {
      // Even if server logout fails, we should still clear local data
      CustomLogs.error('Server logout failed: $e');
    }

    // Always clear all local data
    await LogoutService.performLogout();

    // Reset auth state
    state = AuthState();
  }

  Future<bool> deleteAccount(String currentPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.deleteAccount(currentPassword);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = AuthState(), // Clear state on successful deletion
    );

    return result.isRight();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      // Check if we need to refresh user data (7 days cache)
      final shouldRefresh = await _authRepository.shouldRefreshUserData();

      if (shouldRefresh) {
        // Fetch fresh user data from API
        final result = await _authRepository.getCurrentUser();
        result.fold(
          (failure) {
            // If token validation fails, clear auth state
            state = AuthState(user: null, error: null);
          },
          (user) {
            state = state.copyWith(user: user);
            // Save timestamp of last fetch
            _authRepository.saveUserDataTimestamp();
          },
        );
      } else {
        // Use cached user data
        final cachedUser = await _authRepository.getCachedUser();
        if (cachedUser != null) {
          state = state.copyWith(user: cachedUser);
        } else {
          // No cache, fetch from API
          final result = await _authRepository.getCurrentUser();
          result.fold(
            (failure) {
              state = AuthState(user: null, error: null);
            },
            (user) {
              state = state.copyWith(user: user);
              _authRepository.saveUserDataTimestamp();
            },
          );
        }
      }
    } else {
      state = AuthState(user: null, error: null);
    }
  }

  Future<String?> getAuthToken() async {
    return await _authRepository.getAuthToken();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
