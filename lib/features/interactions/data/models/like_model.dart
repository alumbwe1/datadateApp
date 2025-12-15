import 'package:datadate/core/utils/custom_logs.dart';

class LikeModel {
  final int id;
  final UserInfo? liker;
  final UserInfo? liked;
  final String? likeType;
  final String? galleryImage;
  final String? createdAt;

  LikeModel({
    required this.id,
    this.liker,
    this.liked,
    this.likeType,
    this.galleryImage,
    this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    try {
      return LikeModel(
        id: json['id'] as int,
        liker: json['liker'] != null && json['liker'] is Map
            ? UserInfo.fromJson(json['liker'] as Map<String, dynamic>)
            : null,
        liked: json['liked'] != null && json['liked'] is Map
            ? UserInfo.fromJson(json['liked'] as Map<String, dynamic>)
            : null,
        likeType: json['like_type'] as String?,
        galleryImage: json['gallery_image'] as String?,
        createdAt: json['created_at'] as String?,
      );
    } catch (e) {
      CustomLogs.info('Error parsing LikeModel: $e');
      CustomLogs.info('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'liker': liker?.toJson(),
      'liked': liked?.toJson(),
      'like_type': likeType,
      'gallery_image': galleryImage,
      'created_at': createdAt,
    };
  }
}

class UserInfo {
  final int id;
  final String username;
  final String displayName;
  final ProfileData? profile;

  UserInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profile,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      profile: json['profile'] != null
          ? ProfileData.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'profile': profile?.toJson(),
    };
  }
}

class ProfileData {
  final int id;
  final String? bio;
  final int? age;
  final String? gender;
  final String? course;
  final int? graduationYear;
  final List<String> interests;
  final List<String> imageUrls;
  final UniversityData? university;
  final String? lastActive;

  ProfileData({
    required this.id,
    this.bio,
    this.age,
    this.gender,
    this.course,
    this.graduationYear,
    required this.interests,
    required this.imageUrls,
    this.university,
    this.lastActive,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      course: json['course'] as String?,
      graduationYear: json['graduation_year'] as int?,

      // Parse interests list safely
      interests: json['interests'] != null && json['interests'] is List
          ? List<String>.from(json['interests'] as List)
          : [],

      // Parse imageUrls list safely
      imageUrls: json['imageUrls'] != null && json['imageUrls'] is List
          ? List<String>.from(json['imageUrls'] as List)
          : [],

      // Parse university object safely
      university: json['university'] != null && json['university'] is Map
          ? UniversityData.fromJson(json['university'] as Map<String, dynamic>)
          : null,

      lastActive: json['last_active'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'age': age,
      'gender': gender,
      'course': course,
      'graduation_year': graduationYear,
      'interests': interests,
      'imageUrls': imageUrls,
      'university': university?.toJson(),
      'last_active': lastActive,
    };
  }
}

class UniversityData {
  final int id;
  final String name;
  final String slug;

  UniversityData({required this.id, required this.name, required this.slug});

  factory UniversityData.fromJson(Map<String, dynamic> json) {
    return UniversityData(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
