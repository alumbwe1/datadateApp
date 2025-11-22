class MatchModel {
  final int id;
  final MatchedUserInfo user1;
  final MatchedUserInfo user2;
  final MatchedUserInfo otherUser;
  final String createdAt;

  MatchModel({
    required this.id,
    required this.user1,
    required this.user2,
    required this.otherUser,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final user1Data = MatchedUserInfo.fromJson(
      json['user1'] as Map<String, dynamic>,
    );
    final user2Data = MatchedUserInfo.fromJson(
      json['user2'] as Map<String, dynamic>,
    );

    return MatchModel(
      id: json['id'] as int,
      user1: user1Data,
      user2: user2Data,
      otherUser: user1Data, // Will be determined by the repository
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1.toJson(),
      'user2': user2.toJson(),
      'created_at': createdAt,
    };
  }
}

class MatchedUserInfo {
  final int id;
  final String username;
  final String displayName;
  final MatchProfile? profile;

  MatchedUserInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profile,
  });

  factory MatchedUserInfo.fromJson(Map<String, dynamic> json) {
    return MatchedUserInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      profile: json['profile'] != null
          ? MatchProfile.fromJson(json['profile'] as Map<String, dynamic>)
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

class MatchProfile {
  final int id;
  final String? bio;
  final int age;
  final String gender;
  final String course;
  final int graduationYear;
  final List<String> interests;
  final List<String> imageUrls;
  final MatchUniversity? university;
  final String? lastActive;

  MatchProfile({
    required this.id,
    this.bio,
    required this.age,
    required this.gender,
    required this.course,
    required this.graduationYear,
    required this.interests,
    required this.imageUrls,
    this.university,
    this.lastActive,
  });

  factory MatchProfile.fromJson(Map<String, dynamic> json) {
    return MatchProfile(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      age: json['age'] as int,
      gender: json['gender'] as String,
      course: json['course'] as String,
      graduationYear: json['graduation_year'] as int,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      university: json['university'] != null
          ? MatchUniversity.fromJson(json['university'] as Map<String, dynamic>)
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

class MatchUniversity {
  final int id;
  final String name;
  final String slug;

  MatchUniversity({required this.id, required this.name, required this.slug});

  factory MatchUniversity.fromJson(Map<String, dynamic> json) {
    return MatchUniversity(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
