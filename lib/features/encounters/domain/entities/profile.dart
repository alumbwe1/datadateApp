import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String displayName;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String universityName;
  final String universityLogo;
  final String? bio;
  final String gender;
  final String intent;
  final int age;
  final String? course;
  final int? graduationYear;
  final List<String> interests;
  final List<String> photos;
  final DateTime? lastActive;
  final String? videoUrl;
  final double? videoDuration;

  const Profile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.universityName,
    required this.universityLogo,
    this.bio,
    required this.gender,
    required this.intent,
    required this.age,
    this.course,
    this.graduationYear,
    this.interests = const [],
    this.photos = const [],
    this.lastActive,
    this.videoUrl,
    this.videoDuration,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      displayName: json['display_name'],
      username: json['user']['username'],
      email: json['user']['email'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      universityName: json['university_data']['name'],
      universityLogo: json['university_data']['logo'],
      bio: json['display_bio'],
      gender: json['gender'],
      intent: json['intent'],
      age: json['age'],
      course: json['course'],
      graduationYear: json['graduation_year'],
      interests: List<String>.from(json['interests'] ?? []),
      photos: List<String>.from(json['imageUrls'] ?? []),
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : null,
      videoUrl: json['video_url'],
      videoDuration: json['video_duration']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    username,
    email,
    firstName,
    lastName,
    universityName,
    universityLogo,
    bio,
    gender,
    intent,
    age,
    course,
    graduationYear,
    interests,
    photos,
    lastActive,
    videoUrl,
    videoDuration,
  ];
}
