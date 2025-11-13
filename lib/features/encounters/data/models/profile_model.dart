import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.university,
    required super.location,
    required super.relationshipGoal,
    super.bio,
    required super.photos,
    super.interests,
    super.isOnline,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 18,
      gender: json['gender'] ?? '',
      university: json['university'] ?? '',
      location: json['location'] ?? '',
      relationshipGoal: json['relationshipGoal'] ?? 'Dating',
      bio: json['bio'],
      photos: List<String>.from(json['photos'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'university': university,
      'location': location,
      'relationshipGoal': relationshipGoal,
      'bio': bio,
      'photos': photos,
      'interests': interests,
      'isOnline': isOnline,
    };
  }

  // Factory to create from randomuser.me API
  factory ProfileModel.fromRandomUser(Map<String, dynamic> json) {
    final gender = json['gender'] == 'male' ? 'male' : 'female';
    final name = '${json['name']['first']} ${json['name']['last']}';
    final age = json['dob']['age'] ?? 22;
    final uuid = json['login']['uuid'];

    final universities = [
      'MIT',
      'Stanford',
      'Harvard',
      'Berkeley',
      'Yale',
      'Princeton',
      'Columbia',
      'Cornell',
    ];

    final goals = ['Relationship', 'Dating', 'New Friends'];
    final interests = [
      'Travel',
      'Music',
      'Sports',
      'Reading',
      'Cooking',
      'Photography',
      'Art',
      'Gaming',
    ];

    // Use Unsplash for better quality images
    // Generate consistent but varied images based on UUID
    final seed = uuid.hashCode.abs();
    final photoIds = [
      1000 + (seed % 100),
      1100 + (seed % 100),
      1200 + (seed % 100),
    ];

    final photos = photoIds
        .map((id) => 'https://picsum.photos/seed/$id/800/1200')
        .toList();

    return ProfileModel(
      id: uuid,
      name: name,
      age: age,
      gender: gender,
      university: (universities..shuffle()).first,
      location: json['location']['city'] ?? 'Unknown',
      relationshipGoal: (goals..shuffle()).first,
      bio: 'Love life and meeting new people!',
      photos: photos,
      interests: (interests..shuffle()).take(4).toList(),
      isOnline: (age % 2 == 0),
    );
  }
}
