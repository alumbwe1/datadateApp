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
    return UserProfileModel(
      id: json['id'] as int,
      displayName:
          json['display_name'] as String? ??
          json['user']['display_name'] as String,
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
      userId: json['user']['id'] as int,
      universityName: json['user']['university']['name'] as String,
      gender: json['user']['gender'] as String,
      intent: json['user']['intent'] as String,
      isPrivate: json['user']['is_private'] as bool,
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
