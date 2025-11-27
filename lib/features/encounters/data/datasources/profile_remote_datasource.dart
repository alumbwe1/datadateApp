import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProfileModel>> getProfiles({
    String? gender,
    String? intent,
    int? university,
    int page = 1,
  });

  Future<List<ProfileModel>> getProfilesWithFilters(
    Map<String, dynamic> filters,
  );

  Future<ProfileModel> getProfileDetail(int id);
  Future<Map<String, dynamic>> likeProfile(int profileId);
  Future<ProfileModel> createProfile({
    required String bio,
    required int age,
    required String major,
    required int graduationYear,
    required List<String> interests,
    String? profilePhoto,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

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
    String? gender,
    String? intent,
    int? university,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};

      if (gender != null) queryParams['gender'] = gender;
      if (intent != null) queryParams['intent'] = intent;
      if (university != null) queryParams['university'] = university;

      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.profiles,
        queryParameters: queryParams,
      );

      final paginatedResponse = PaginatedResponse.fromJson(
        response,
        (json) => ProfileModel.fromJson(json),
      );

      return paginatedResponse.results;
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockProfiles(gender: gender);
    }
  }

  @override
  Future<List<ProfileModel>> getProfilesWithFilters(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.discoverProfiles,
        queryParameters: filters,
      );

      final paginatedResponse = PaginatedResponse.fromJson(
        response,
        (json) => ProfileModel.fromJson(json),
      );

      return paginatedResponse.results;
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockProfiles(gender: filters['gender']);
    }
  }

  @override
  Future<ProfileModel> getProfileDetail(int id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.profileDetail(id),
    );

    return ProfileModel.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> likeProfile(int profileId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.likes,
        data: {'liked': profileId, 'like_type': 'profile'},
      );

      // Check if it's a match by looking at the response
      // The API returns a Like object, but may include match info
      return {
        'matched': response['matched'] ?? false,
        'match_id': response['match_id'],
        'detail': response['detail'] ?? 'Profile liked successfully',
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileModel> createProfile({
    required String bio,
    required int age,
    required String major,
    required int graduationYear,
    required List<String> interests,
    String? profilePhoto,
  }) async {
    final formData = FormData.fromMap({
      'bio': bio,
      'age': age,
      'major': major,
      'graduation_year': graduationYear,
      'interests': interests,
      if (profilePhoto != null)
        'profile_photo': await MultipartFile.fromFile(profilePhoto),
    });

    final response = await apiClient.uploadFile<Map<String, dynamic>>(
      ApiEndpoints.profiles,
      formData: formData,
    );

    return ProfileModel.fromJson(response);
  }

  // Mock data fallback
  List<ProfileModel> _getMockProfiles({String? gender}) {
    final oppositeGender = gender == 'male' ? 'female' : 'male';
    final sourceProfiles = oppositeGender == 'male'
        ? _maleProfiles
        : _femaleProfiles;

    final shuffled = List<Map<String, dynamic>>.from(sourceProfiles)..shuffle();

    return shuffled.take(10).map((profile) {
      final id = DateTime.now().millisecondsSinceEpoch;
      return ProfileModel(
        id: id,
        displayName: profile['name'],
        username: profile['name'].toString().toLowerCase(),
        email: '${profile['name'].toString().toLowerCase()}@example.com',
        universityName: profile['university'],
        universityLogo: '',
        age: profile['age'],
        gender: oppositeGender,
        intent: (_relationshipGoals..shuffle()).first,
        bio:
            'Love to travel, explore new places, and meet interesting people. Looking for someone to share adventures with! 🌍✨',
        photos: [profile['photo']],
        interests: (_interests..shuffle()).take(3).toList(),
        lastActive: DateTime.now().second % 2 == 0 ? DateTime.now() : null,
      );
    }).toList();
  }
}
