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
    super.profilePhoto,
    super.lastActive,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
    required super.universityName,
    required super.gender,
    required super.intent,
    required super.isPrivate,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final university = user?['university'] as Map<String, dynamic>?;

    return UserProfileModel(
      id: json['id'] as int,
      displayName:
          json['display_name'] as String? ??
          (user?['display_name'] as String?) ??
          'Unknown',
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
      profilePhoto: json['profile_photo'] as String?,
      lastActive: json['last_active'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      userId: user?['id'] as int? ?? 0,
      universityName: university?['name'] as String? ?? 'Unknown University',
      gender: user?['gender'] as String? ?? 'other',
      intent: user?['intent'] as String? ?? 'dating',
      isPrivate: user?['is_private'] as bool? ?? false,
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
    };
  }
}
