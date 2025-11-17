import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class OnboardingState {
  final String? name;
  final String? email;
  final String? password;
  final String? gender;
  final String? genderPreference;
  final String? datingGoal;
  final List<String> interests;
  final int? universityId;
  final int? age;
  final String? course;
  final String? bio;
  final int? graduationYear;
  final File? profilePhoto;
  final DateTime? dateOfBirth;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  OnboardingState({
    this.name,
    this.email,
    this.password,
    this.gender,
    this.genderPreference,
    this.datingGoal,
    this.interests = const [],
    this.universityId,
    this.age,
    this.course,
    this.bio,
    this.graduationYear,
    this.profilePhoto,
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
    String? genderPreference,
    String? datingGoal,
    List<String>? interests,
    int? universityId,
    int? age,
    String? course,
    String? bio,
    int? graduationYear,
    File? profilePhoto,
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
      genderPreference: genderPreference ?? this.genderPreference,
      datingGoal: datingGoal ?? this.datingGoal,
      interests: interests ?? this.interests,
      universityId: universityId ?? this.universityId,
      age: age ?? this.age,
      course: course ?? this.course,
      bio: bio ?? this.bio,
      graduationYear: graduationYear ?? this.graduationYear,
      profilePhoto: profilePhoto ?? this.profilePhoto,
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

  void setGenderPreference(String preference) {
    state = state.copyWith(genderPreference: preference);
  }

  void setDatingGoal(String goal) {
    state = state.copyWith(datingGoal: goal);
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

  void setAge(int age) {
    state = state.copyWith(age: age);
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

  void setProfilePhoto(File photo) {
    state = state.copyWith(profilePhoto: photo);
  }

  void setDateOfBirth(DateTime date) {
    state = state.copyWith(dateOfBirth: date);
  }

  Future<bool> completeOnboarding() async {
    print('📝 Starting completeOnboarding...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Build profile update data
      final Map<String, dynamic> profileData = {};

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

      // Use date of birth if provided, otherwise calculate from age
      if (state.dateOfBirth != null) {
        final dob = state.dateOfBirth!;
        profileData['date_of_birth'] =
            '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
      } else if (state.age != null) {
        final now = DateTime.now();
        final birthYear = now.year - state.age!;
        profileData['date_of_birth'] = '$birthYear-01-01';
      }

      print('📦 Profile data to update: $profileData');

      // Update profile
      final success = await _ref
          .read(profileProvider.notifier)
          .updateProfile(profileData);

      print('📊 Update profile result: $success');

      if (success) {
        // Upload profile photo if provided
        if (state.profilePhoto != null) {
          print('📸 Uploading profile photo...');
          final photoSuccess = await _ref
              .read(profileProvider.notifier)
              .uploadPhoto(state.profilePhoto!.path);

          if (photoSuccess) {
            print('✅ Profile photo uploaded successfully');
          } else {
            print('⚠️ Profile photo upload failed, but continuing...');
            // Don't fail the whole onboarding if photo upload fails
          }
        } else {
          print('ℹ️ No profile photo to upload');
        }

        print('✅ Saving onboarding_completed to SharedPreferences');
        await _prefs.setBool('onboarding_completed', true);
        state = state.copyWith(isCompleted: true, isLoading: false);
        print('✅ completeOnboarding returning true');
        return true;
      } else {
        print('❌ Profile update failed');
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to complete onboarding',
        );
        return false;
      }
    } catch (e) {
      print('❌ Exception in completeOnboarding: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
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
