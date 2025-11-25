import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String displayName;
  final String? bio;
  final String? realName;
  final String? course;
  final String? dateOfBirth;
  final int? age;
  final int? graduationYear;
  final List<String> interests;
  final List<String> imageUrls;
  final List<String> imagePublicIds;
  final String? lastActive;
  final String createdAt;
  final String updatedAt;

  // User info
  final int userId;
  final String username;
  final String email;
  final int universityId;
  final String universityName;
  final String? universityLogo;
  final String gender;
  final List<String> preferredGenders;
  final String intent;
  final bool isPrivate;
  final String anonHandle;
  final bool showRealNameOnMatch;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.bio,
    this.realName,
    this.course,
    this.dateOfBirth,
    this.age,
    this.graduationYear,
    required this.interests,
    required this.imageUrls,
    required this.imagePublicIds,
    this.lastActive,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.username,
    required this.email,
    required this.universityId,
    required this.universityName,
    this.universityLogo,
    required this.gender,
    required this.preferredGenders,
    required this.intent,
    required this.isPrivate,
    required this.anonHandle,
    required this.showRealNameOnMatch,
  });

  // Helper getter for backward compatibility
  String? get profilePhoto => imageUrls.isNotEmpty ? imageUrls.first : null;

  // Helper getter for university data
  Map<String, dynamic>? get universityData => {
    'id': universityId,
    'name': universityName,
    'logo': universityLogo,
  };

  @override
  List<Object?> get props => [
    id,
    displayName,
    bio,
    realName,
    course,
    dateOfBirth,
    age,
    graduationYear,
    interests,
    imageUrls,
    imagePublicIds,
    lastActive,
    createdAt,
    updatedAt,
    userId,
    username,
    email,
    universityId,
    universityName,
    universityLogo,
    gender,
    preferredGenders,
    intent,
    isPrivate,
    anonHandle,
    showRealNameOnMatch,
  ];
}
