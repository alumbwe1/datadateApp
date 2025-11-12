import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    required super.gender,
    required super.university,
    super.bio,
    required super.photos,
    required super.relationshipGoal,
    super.isSubscribed,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 18,
      gender: json['gender'] ?? '',
      university: json['university'] ?? '',
      bio: json['bio'],
      photos: List<String>.from(json['photos'] ?? []),
      relationshipGoal: json['relationshipGoal'] ?? 'Dating',
      isSubscribed: json['isSubscribed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'university': university,
      'bio': bio,
      'photos': photos,
      'relationshipGoal': relationshipGoal,
      'isSubscribed': isSubscribed,
    };
  }
}
