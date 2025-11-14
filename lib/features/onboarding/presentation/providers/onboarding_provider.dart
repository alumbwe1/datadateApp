import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';

class OnboardingState {
  final String? name;
  final String? email;
  final String? password;
  final int? age;
  final String? gender;
  final String? genderPreference;
  final List<String> desiredTraits;
  final String? datingGoal;
  final List<String> interests;
  final String? location;
  final bool isCompleted;

  OnboardingState({
    this.name,
    this.email,
    this.password,
    this.age,
    this.gender,
    this.genderPreference,
    this.desiredTraits = const [],
    this.datingGoal,
    this.interests = const [],
    this.location,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    String? name,
    String? email,
    String? password,
    int? age,
    String? gender,
    String? genderPreference,
    List<String>? desiredTraits,
    String? datingGoal,
    List<String>? interests,
    String? location,
    bool? isCompleted,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      genderPreference: genderPreference ?? this.genderPreference,
      desiredTraits: desiredTraits ?? this.desiredTraits,
      datingGoal: datingGoal ?? this.datingGoal,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs) : super(OnboardingState()) {
    _loadOnboardingStatus();
  }

  void _loadOnboardingStatus() {
    final isCompleted = _prefs.getBool('onboarding_completed') ?? false;
    state = state.copyWith(isCompleted: isCompleted);
  }

  void setBasicInfo({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      password: password,
      age: age,
      gender: gender,
    );
  }

  void setGenderPreference(String preference) {
    state = state.copyWith(genderPreference: preference);
  }

  void addDesiredTrait(String trait) {
    if (!state.desiredTraits.contains(trait)) {
      state = state.copyWith(desiredTraits: [...state.desiredTraits, trait]);
    }
  }

  void removeDesiredTrait(String trait) {
    state = state.copyWith(
      desiredTraits: state.desiredTraits.where((t) => t != trait).toList(),
    );
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

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_completed', true);
    state = state.copyWith(isCompleted: true);
  }

  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool('onboarding_completed') ?? false;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return OnboardingNotifier(prefs);
    });
