class ProfileViewModel {
  final int id;
  final int viewer;
  final int viewed;
  final ViewedProfileInfo? viewedProfile;
  final String viewedAt;

  ProfileViewModel({
    required this.id,
    required this.viewer,
    required this.viewed,
    this.viewedProfile,
    required this.viewedAt,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) {
    return ProfileViewModel(
      id: json['id'] as int,
      viewer: json['viewer'] as int,
      viewed: json['viewed'] as int,
      viewedProfile: json['viewed_profile'] != null
          ? ViewedProfileInfo.fromJson(
              json['viewed_profile'] as Map<String, dynamic>,
            )
          : null,
      viewedAt: json['viewed_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'viewer': viewer,
      'viewed': viewed,
      'viewed_profile': viewedProfile?.toJson(),
      'viewed_at': viewedAt,
    };
  }
}

class ViewedProfileInfo {
  final int id;
  final String username;
  final String displayName;
  final String? profilePhoto;

  ViewedProfileInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePhoto,
  });

  factory ViewedProfileInfo.fromJson(Map<String, dynamic> json) {
    return ViewedProfileInfo(
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
