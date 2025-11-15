import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? anonHandle;
  final bool showRealNameOnMatch;
  final int remainingProfileViews;
  final String? quotaResetAt;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    required super.gender,
    required super.university,
    super.bio,
    required super.photos,
    required super.relationshipGoal,
    super.isSubscribed,
    this.anonHandle,
    this.showRealNameOnMatch = true,
    this.remainingProfileViews = 10,
    this.quotaResetAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['username'] ?? '', // API uses 'username'
      age: json['age'] ?? 18,
      gender: json['gender'] ?? '',
      university: json['university']?.toString() ?? '',
      bio: json['bio'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      relationshipGoal: json['intent'] ?? 'dating', // API uses 'intent'
      isSubscribed: json['subscription_active'] ?? false,
      anonHandle: json['anon_handle'],
      showRealNameOnMatch: json['show_real_name_on_match'] ?? true,
      remainingProfileViews: json['remaining_profile_views'] ?? 10,
      quotaResetAt: json['quota_reset_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': name,
      'age': age,
      'gender': gender,
      'university': university,
      'bio': bio,
      'photos': photos,
      'intent': relationshipGoal,
      'subscription_active': isSubscribed,
      'anon_handle': anonHandle,
      'show_real_name_on_match': showRealNameOnMatch,
      'remaining_profile_views': remainingProfileViews,
      'quota_reset_at': quotaResetAt,
    };
  }

  /// For PATCH requests - only include fields to update
  Map<String, dynamic> toUpdateJson({
    bool? isPrivate,
    String? anonHandle,
    bool? showRealNameOnMatch,
    List<String>? preferredGenders,
  }) {
    final Map<String, dynamic> data = {};

    if (isPrivate != null) data['is_private'] = isPrivate;
    if (anonHandle != null) data['anon_handle'] = anonHandle;
    if (showRealNameOnMatch != null) {
      data['show_real_name_on_match'] = showRealNameOnMatch;
    }
    if (preferredGenders != null) {
      data['preferred_genders'] = preferredGenders;
    }

    return data;
  }
}
