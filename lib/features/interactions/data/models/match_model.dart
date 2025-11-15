class MatchModel {
  final int id;
  final int user1;
  final int user2;
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
    return MatchModel(
      id: json['id'] as int,
      user1: json['user1'] as int,
      user2: json['user2'] as int,
      otherUser: MatchedUserInfo.fromJson(
        json['other_user'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1,
      'user2': user2,
      'other_user': otherUser.toJson(),
      'created_at': createdAt,
    };
  }
}

class MatchedUserInfo {
  final int id;
  final String username;
  final String displayName;
  final String? profilePhoto;

  MatchedUserInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePhoto,
  });

  factory MatchedUserInfo.fromJson(Map<String, dynamic> json) {
    return MatchedUserInfo(
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
