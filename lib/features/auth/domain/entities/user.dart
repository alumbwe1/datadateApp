import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final int age;
  final String gender;
  final String university;
  final String? bio;
  final List<String> photos;
  final String relationshipGoal;
  final bool isSubscribed;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.university,
    this.bio,
    required this.photos,
    required this.relationshipGoal,
    this.isSubscribed = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    age,
    gender,
    university,
    bio,
    photos,
    relationshipGoal,
    isSubscribed,
  ];
}
