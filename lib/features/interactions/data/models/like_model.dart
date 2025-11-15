class LikeModel {
  final int id;
  final int liker;
  final int liked;
  final String likeType;
  final ProfileInfo? profileInfo;
  final String createdAt;

  LikeModel({
    required this.id,
    required this.liker,
    required this.liked,
    required this.likeType,
    this.profileInfo,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as int,
      liker: json['liker'] as int,
      liked: json['liked'] as int,
      likeType: json['like_type'] as String,
      profileInfo: json['profile_info'] != null
          ? ProfileInfo.fromJson(json['profile_info'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'liker': liker,
      'liked': liked,
      'like_type': likeType,
      'profile_info': profileInfo?.toJson(),
      'created_at': createdAt,
    };
  }
}

class ProfileInfo {
  final int id;
  final String username;
  final String displayName;
  final String? profilePhoto;

  ProfileInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePhoto,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'profile_photo': profilePhoto,
    };
  }
}
