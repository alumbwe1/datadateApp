import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ProfileRemoteDataSourceImpl(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getMyProfile();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: null,
      ),
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    CustomLogs.info('🔄 ProfileProvider: Starting updateProfile');
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.updateMyProfile(data);

    return result.fold(
      (failure) {
        CustomLogs.info(
          '❌ ProfileProvider: Update failed - ${failure.message}',
        );
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (profile) {
        CustomLogs.info(
          '✅ ProfileProvider: Update successful - Profile: ${profile.displayName}',
        );
        state = state.copyWith(isLoading: false, profile: profile, error: null);
        return true;
      },
    );
  }

  Future<bool> uploadPhoto(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.uploadProfilePhoto(filePath);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (photoUrl) {
        // Reload profile to get updated data
        loadProfile();
        return true;
      },
    );
  }

  Future<bool> uploadPhotos(List<String> filePaths) async {
    CustomLogs.info(
      '🔄 ProfileProvider: Starting uploadPhotos with ${filePaths.length} files',
    );
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.uploadProfilePhotos(filePaths);

    return result.fold(
      (failure) {
        CustomLogs.info(
          '❌ ProfileProvider: Upload failed - ${failure.message}',
        );
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (photoUrls) {
        CustomLogs.info(
          '✅ ProfileProvider: Uploaded ${photoUrls.length} photos successfully',
        );
        // Reload profile to get updated data
        loadProfile();
        return true;
      },
    );
  }

  Future<List<String>?> uploadPhotosAndGetUrls(List<String> filePaths) async {
    CustomLogs.info(
      '🔄 ProfileProvider: Starting uploadPhotosAndGetUrls with ${filePaths.length} files',
    );
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.uploadProfilePhotos(filePaths);

    return result.fold(
      (failure) {
        CustomLogs.info(
          '❌ ProfileProvider: Upload failed - ${failure.message}',
        );
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (photoUrls) {
        CustomLogs.info(
          '✅ ProfileProvider: Uploaded ${photoUrls.length} photos successfully',
        );
        CustomLogs.info('📸 Photo URLs: $photoUrls');
        state = state.copyWith(isLoading: false);
        return photoUrls;
      },
    );
  }

  Future<bool> deleteAccount({
    required String reason,
    String? otherReason,
  }) async {
    CustomLogs.info('🗑️ ProfileProvider: Starting deleteAccount');
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deleteAccount(
      reason: reason,
      otherReason: otherReason,
    );

    return result.fold(
      (failure) {
        CustomLogs.info(
          '❌ ProfileProvider: Delete account failed - ${failure.message}',
        );
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        CustomLogs.info('✅ ProfileProvider: Account deleted successfully');
        // Clear the profile state after successful deletion
        state = ProfileState();
        return true;
      },
    );
  }
}
