import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.displayName,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    required super.universityName,
    required super.universityLogo,
    super.bio,
    required super.gender,
    required super.intent,
    required super.age,
    super.course,
    super.graduationYear,
    super.interests,
    super.photos,
    super.lastActive,
    super.videoUrl,
    super.videoDuration,
    super.matchScore,
    super.sharedInterests,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Extract user data
    final userData = json['user'] as Map<String, dynamic>?;

    // Extract university data
    final universityData = json['university_data'] as Map<String, dynamic>?;

    return ProfileModel(
      id: json['id'] as int,
      displayName: json['real_name'] as String? ?? 'Unknown',
      username: userData?['username'] as String? ?? '',
      email: userData?['email'] as String? ?? '',
      firstName: userData?['first_name'] as String?,
      lastName: userData?['last_name'] as String?,
      universityName:
          universityData?['name'] as String? ?? 'Unknown University',
      universityLogo: universityData?['logo'] as String? ?? '',
      bio: json['bio'] as String?,
      gender: json['gender'] as String? ?? '',
      intent: json['intent'] as String? ?? 'dating',
      age: json['age'] as int? ?? 18,
      course: json['course'] as String?,
      graduationYear: json['graduation_year'] as int?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      photos:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastActive: json['last_active'] != null
          ? DateTime.tryParse(json['last_active'] as String)
          : null,
      videoUrl: json['video'] as String?,
      videoDuration: (json['video_duration'] as num?)?.toDouble(),
      matchScore: json['match_score'] as int?,
      sharedInterests:
          (json['shared_interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'user': {
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      },
      'university_data': {'name': universityName, 'logo': universityLogo},
      'display_bio': bio,
      'gender': gender,
      'intent': intent,
      'age': age,
      'course': course,
      'graduation_year': graduationYear,
      'interests': interests,
      'imageUrls': photos,
      'last_active': lastActive?.toIso8601String(),
      'match_score': matchScore,
      'shared_interests': sharedInterests,
    };
  }
}
