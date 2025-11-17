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
  final String? profilePhoto;
  final String? lastActive;
  final String createdAt;
  final String updatedAt;

  // User info
  final int userId;
  final String universityName;
  final String gender;
  final String intent;
  final bool isPrivate;

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
    this.profilePhoto,
    this.lastActive,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.universityName,
    required this.gender,
    required this.intent,
    required this.isPrivate,
  });

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
    profilePhoto,
    lastActive,
    createdAt,
    updatedAt,
    userId,
    universityName,
    gender,
    intent,
    isPrivate,
  ];
}
