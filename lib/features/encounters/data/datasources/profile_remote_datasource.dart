import 'package:dio/dio.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> getProfiles({
    required String userGender,
    String? relationshipGoal,
    int count = 10,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  // Curated diverse profile images
  static final List<Map<String, dynamic>> _maleProfiles = [
    {
      'name': 'Marcus',
      'age': 22,
      'photo':
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'David',
      'age': 24,
      'photo':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800',
      'university': 'Copperbelt University',
      'location': 'Kitwe',
    },
    {
      'name': 'Chris',
      'age': 23,
      'photo':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
      'university': 'Mulungushi University',
      'location': 'Kabwe',
    },
    {
      'name': 'Chanda',
      'age': 25,
      'photo':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'Mwamba',
      'age': 21,
      'photo':
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800',
      'university': 'Copperbelt University',
      'location': 'Ndola',
    },
    {
      'name': 'Kabwe',
      'age': 26,
      'photo':
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800',
      'university': 'Mulungushi University',
      'location': 'Kabwe',
    },
    {
      'name': 'Bwalya',
      'age': 23,
      'photo':
          'https://images.unsplash.com/photo-1504593811423-6dd665756598?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'Mulenga',
      'age': 24,
      'photo':
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800',
      'university': 'Copperbelt University',
      'location': 'Kitwe',
    },
  ];

  static final List<Map<String, dynamic>> _femaleProfiles = [
    {
      'name': 'Amara',
      'age': 21,
      'photo':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'Zara',
      'age': 23,
      'photo':
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800',
      'university': 'Copperbelt University',
      'location': 'Kitwe',
    },
    {
      'name': 'Maya',
      'age': 22,
      'photo':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      'university': 'Mulungushi University',
      'location': 'Kabwe',
    },
    {
      'name': 'Thandiwe',
      'age': 24,
      'photo':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'Natasha',
      'age': 20,
      'photo':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      'university': 'Copperbelt University',
      'location': 'Ndola',
    },
    {
      'name': 'Chipo',
      'age': 25,
      'photo':
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800',
      'university': 'Mulungushi University',
      'location': 'Kabwe',
    },
    {
      'name': 'Mutale',
      'age': 23,
      'photo':
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
      'university': 'University of Zambia',
      'location': 'Lusaka',
    },
    {
      'name': 'Lubona',
      'age': 22,
      'photo':
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800',
      'university': 'Copperbelt University',
      'location': 'Kitwe',
    },
  ];

  static final List<String> _relationshipGoals = [
    'date',
    'chat',
    'relationship',
  ];

  static final List<String> _interests = [
    'Gaming',
    'Music',
    'Reading',
    'Travel',
    'Fitness',
    'Cooking',
    'Photography',
    'Art',
  ];

  @override
  Future<List<ProfileModel>> getProfiles({
    required String userGender,
    String? relationshipGoal,
    int count = 10,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get opposite gender profiles
      final oppositeGender = userGender == 'male' ? 'female' : 'male';
      final sourceProfiles = oppositeGender == 'male'
          ? _maleProfiles
          : _femaleProfiles;

      // Shuffle and take requested count
      final shuffled = List<Map<String, dynamic>>.from(sourceProfiles)
        ..shuffle();
      final selectedProfiles = shuffled.take(count).toList();

      // Convert to ProfileModel
      return selectedProfiles.map((profile) {
        return ProfileModel(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              profile['name'],
          name: profile['name'],
          age: profile['age'],
          gender: oppositeGender,
          university: profile['university'],
          location: profile['location'],
          relationshipGoal: (_relationshipGoals..shuffle()).first,
          bio:
              'Love to travel, explore new places, and meet interesting people. Looking for someone to share adventures with! 🌍✨',
          photos: [profile['photo']],
          interests: (_interests..shuffle()).take(3).toList(),
          isOnline: DateTime.now().second % 2 == 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }
}
