import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.displayName,
    super.bio,
    super.realName,
    super.course,
    super.dateOfBirth,
    super.age,
    super.graduationYear,
    required super.interests,
    required super.imageUrls,
    required super.imagePublicIds,
    super.lastActive,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
    required super.username,
    required super.email,
    required super.universityId,
    required super.universityName,
    super.universityLogo,
    required super.gender,
    required super.preferredGenders,
    required super.intent,
    required super.isPrivate,
    required super.anonHandle,
    required super.showRealNameOnMatch,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final universityData = json['university_data'] as Map<String, dynamic>?;

    // Determine display name based on privacy settings
    String displayName;
    if (json['is_private'] == true) {
      displayName = json['anon_handle'] as String? ?? 'Anonymous';
    } else {
      displayName =
          json['real_name'] as String? ??
          user?['username'] as String? ??
          'Unknown';
    }

    return UserProfileModel(
      id: json['id'] as int,
      displayName: displayName,
      bio: json['bio'] as String?,
      realName: json['real_name'] as String?,
      course: json['course'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      age: json['age'] as int?,
      graduationYear: json['graduation_year'] as int?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imagePublicIds:
          (json['imagePublicIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastActive: json['last_active'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      userId: user?['id'] as int? ?? 0,
      username: user?['username'] as String? ?? '',
      email: user?['email'] as String? ?? '',
      universityId: json['university'] as int? ?? 0,
      universityName:
          universityData?['name'] as String? ?? 'Unknown University',
      universityLogo: universityData?['logo'] as String?,
      gender: json['gender'] as String? ?? 'other',
      preferredGenders:
          (json['preferred_genders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      intent: json['intent'] as String? ?? 'dating',
      isPrivate: json['is_private'] as bool? ?? false,
      anonHandle: json['anon_handle'] as String? ?? '',
      showRealNameOnMatch: json['show_real_name_on_match'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'real_name': realName,
      'course': course,
      'date_of_birth': dateOfBirth,
      'graduation_year': graduationYear,
      'interests': interests,
      'gender': gender,
      'preferred_genders': preferredGenders,
      'intent': intent,
      'is_private': isPrivate,
      'show_real_name_on_match': showRealNameOnMatch,
    };
  }
}
