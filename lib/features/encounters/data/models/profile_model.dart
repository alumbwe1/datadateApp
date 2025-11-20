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
    // Extract university name from nested university_data
    final universityData = json['university_data'] as Map<String, dynamic>?;
    final universityName =
        universityData?['name'] as String? ??
        json['university'] as String? ??
        'Unknown University';

    // Get display name (could be real name or display_name)
    final displayName =
        json['display_name'] as String? ?? json['name'] as String? ?? 'Unknown';

    // Get bio (could be display_bio or bio)
    final bio = json['display_bio'] as String? ?? json['bio'] as String?;

    // Parse photos from imageUrls (API format) or photos (old format)
    final photosList =
        json['imageUrls'] as List<dynamic>? ??
        json['photos'] as List<dynamic>? ??
        [];

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      name: displayName,
      age: json['age'] as int? ?? 18,
      gender: json['gender'] as String? ?? '',
      university: universityName,
      location: json['location'] as String? ?? universityName,
      relationshipGoal:
          json['intent'] as String? ??
          json['relationshipGoal'] as String? ??
          'dating',
      bio: bio,
      photos: photosList.map((e) => e.toString()).toList(),
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOnline:
          json['isOnline'] as bool? ?? json['is_online'] as bool? ?? false,
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
