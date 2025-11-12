import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String university;
  final String location;
  final String relationshipGoal;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final bool isOnline;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.university,
    required this.location,
    required this.relationshipGoal,
    this.bio,
    required this.photos,
    this.interests = const [],
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    gender,
    university,
    location,
    relationshipGoal,
    bio,
    photos,
    interests,
    isOnline,
  ];
}
