import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';

class OnboardingState {
  final String? datingGoal;
  final List<String> interests;
  final String? location;
  final bool isCompleted;

  OnboardingState({
    this.datingGoal,
    this.interests = const [],
    this.location,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    String? datingGoal,
    List<String>? interests,
    String? location,
    bool? isCompleted,
  }) {
    return OnboardingState(
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
