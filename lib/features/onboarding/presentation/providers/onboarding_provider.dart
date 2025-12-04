import 'dart:io';
import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../main.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class OnboardingState {
  final String? name;
  final String? email;
  final String? password;
  final String? gender;
  final List<String> preferredGenders;
  final String? intent;
  final List<String> interests;
  final int? universityId;
  final String? course;
  final String? bio;
  final int? graduationYear;
  final List<File> photos; // Changed to list for multiple photos (2-4)
  final DateTime? dateOfBirth;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  OnboardingState({
    this.name,
    this.email,
    this.password,
    this.gender,
    this.preferredGenders = const [],
    this.intent,
    this.interests = const [],
    this.universityId,
    this.course,
    this.bio,
    this.graduationYear,
    this.photos = const [],
    this.dateOfBirth,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    String? name,
    String? email,
    String? password,
    String? gender,
    List<String>? preferredGenders,
    String? intent,
    List<String>? interests,
    int? universityId,
    String? course,
    String? bio,
    int? graduationYear,
    List<File>? photos,
    DateTime? dateOfBirth,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      intent: intent ?? this.intent,
      interests: interests ?? this.interests,
      universityId: universityId ?? this.universityId,
      course: course ?? this.course,
      bio: bio ?? this.bio,
      graduationYear: graduationYear ?? this.graduationYear,
      photos: photos ?? this.photos,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final SharedPreferences _prefs;
  final Ref _ref;

  OnboardingNotifier(this._prefs, this._ref) : super(OnboardingState()) {
    _loadOnboardingStatus();
  }

  void _loadOnboardingStatus() {
    final isCompleted = _prefs.getBool('onboarding_completed') ?? false;
    state = state.copyWith(isCompleted: isCompleted);
  }

  void setRegistrationData({
    required String name,
    required String email,
    required String password,
  }) {
    state = state.copyWith(name: name, email: email, password: password);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void addPreferredGender(String gender) {
    if (!state.preferredGenders.contains(gender)) {
      state = state.copyWith(
        preferredGenders: [...state.preferredGenders, gender],
      );
    }
  }

  void removePreferredGender(String gender) {
    state = state.copyWith(
      preferredGenders: state.preferredGenders
          .where((g) => g != gender)
          .toList(),
    );
  }

  void setPreferredGenders(List<String> genders) {
    state = state.copyWith(preferredGenders: genders);
  }

  void setIntent(String intent) {
    state = state.copyWith(intent: intent);
  }

  void addInterest(String interest) {
    if (!state.interests.contains(interest) && state.interests.length < 5) {
      state = state.copyWith(interests: [...state.interests, interest]);
    }
  }

  void removeInterest(String interest) {
    state = state.copyWith(
      interests: state.interests.where((i) => i != interest).toList(),
    );
  }

  void setUniversity(int universityId) {
    state = state.copyWith(universityId: universityId);
  }

  void setCourse(String course) {
    state = state.copyWith(course: course);
  }

  void setBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  void setGraduationYear(int year) {
    state = state.copyWith(graduationYear: year);
  }

  void addPhoto(File photo) {
    if (state.photos.length < 4) {
      state = state.copyWith(photos: [...state.photos, photo]);
    }
  }

  void removePhoto(int index) {
    final photos = List<File>.from(state.photos);
    photos.removeAt(index);
    state = state.copyWith(photos: photos);
  }

  void setDateOfBirth(DateTime date) {
    state = state.copyWith(dateOfBirth: date);
  }

  Future<bool> completeOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      CustomLogs.log('🚀 Starting onboarding completion...');

      // Step 1: Upload photos FIRST (if provided)
      if (state.photos.isNotEmpty) {
        CustomLogs.log('📸 Uploading ${state.photos.length} photos...');
        final photoUploadSuccess = await _uploadPhotos();

        if (!photoUploadSuccess) {
          CustomLogs.log('❌ Photo upload failed');
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to upload photos',
          );
          return false;
        }
        CustomLogs.log('✅ Photos uploaded successfully');
      } else {
        CustomLogs.log('⚠️ No photos to upload');
      }

      // Step 2: Build profile update data (PATCH /api/v1.0/profiles/me/)
      final Map<String, dynamic> profileData = {};

      // Required fields
      if (state.universityId != null) {
        profileData['university'] = state.universityId;
      }
      if (state.gender != null) {
        profileData['gender'] = state.gender;
      }
      if (state.preferredGenders.isNotEmpty) {
        profileData['preferred_genders'] = state.preferredGenders;
      }
      if (state.intent != null) {
        profileData['intent'] = state.intent;
      }

      // Optional fields
      if (state.bio != null) {
        profileData['bio'] = state.bio;
      }
      if (state.course != null) {
        profileData['course'] = state.course;
      }
      if (state.interests.isNotEmpty) {
        profileData['interests'] = state.interests;
      }
      if (state.graduationYear != null) {
        profileData['graduation_year'] = state.graduationYear;
      }
      if (state.name != null) {
        profileData['real_name'] = state.name;
      }

      // Date of birth (required, must be 18+)
      if (state.dateOfBirth != null) {
        final dob = state.dateOfBirth!;
        profileData['date_of_birth'] =
            '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
      }

      // Privacy settings
      profileData['is_private'] = false;
      profileData['show_real_name_on_match'] = true;

      // Debug: Print the data being sent
      CustomLogs.log('📦 Profile data to be sent:');
      CustomLogs.log('  - University ID: ${profileData['university']}');
      CustomLogs.log('  - Gender: ${profileData['gender']}');
      CustomLogs.log(
        '  - Preferred Genders: ${profileData['preferred_genders']}',
      );
      CustomLogs.log('  - Intent: ${profileData['intent']}');
      CustomLogs.log('  - Bio: ${profileData['bio']}');
      CustomLogs.log('  - Course: ${profileData['course']}');
      CustomLogs.log('  - Interests: ${profileData['interests']}');
      CustomLogs.log('  - Graduation Year: ${profileData['graduation_year']}');
      CustomLogs.log('  - Real Name: ${profileData['real_name']}');
      CustomLogs.log('  - Date of Birth: ${profileData['date_of_birth']}');
      CustomLogs.log('  - Is Private: ${profileData['is_private']}');
      CustomLogs.log(
        '  - Show Real Name on Match: ${profileData['show_real_name_on_match']}',
      );

      // Step 3: Update profile
      CustomLogs.log('🔄 Updating profile...');
      final success = await _ref
          .read(profileProvider.notifier)
          .updateProfile(profileData);

      if (success) {
        CustomLogs.log('✅ Profile updated successfully');
        await _prefs.setBool('onboarding_completed', true);
        state = state.copyWith(isCompleted: true, isLoading: false);
        return true;
      } else {
        CustomLogs.log('❌ Profile update failed');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to complete onboarding',
        );
        return false;
      }
    } catch (e) {
      CustomLogs.log('❌ Error during onboarding completion: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> _uploadPhotos() async {
    try {
      final profileRepo = _ref.read(profileProvider.notifier);

      // Get all photo paths
      final photoPaths = state.photos.map((photo) => photo.path).toList();

      CustomLogs.log(
        '📤 Uploading ${photoPaths.length} photos in a single request',
      );
      CustomLogs.log('📁 Photo paths:');
      for (int i = 0; i < photoPaths.length; i++) {
        CustomLogs.log('   ${i + 1}. ${photoPaths[i]}');
      }

      // Upload all photos at once
      final success = await profileRepo.uploadPhotos(photoPaths);

      if (!success) {
        CustomLogs.log('❌ Failed to upload photos');
        return false;
      }

      CustomLogs.log('✅ All photos uploaded successfully');
      return true;
    } catch (e) {
      CustomLogs.log('❌ Error uploading photos: $e');
      return false;
    }
  }

  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  void reset() {
    state = OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return OnboardingNotifier(prefs, ref);
    });
