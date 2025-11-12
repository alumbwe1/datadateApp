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

  @override
  Future<List<ProfileModel>> getProfiles({
    required String userGender,
    String? relationshipGoal,
    int count = 10,
  }) async {
    try {
      // Get opposite gender profiles
      final oppositeGender = userGender == 'male' ? 'female' : 'male';

      final response = await dio.get(
        'https://randomuser.me/api/',
        queryParameters: {'results': count, 'gender': oppositeGender},
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results
            .map((json) => ProfileModel.fromRandomUser(json))
            .toList();
      }

      throw Exception('Failed to load profiles');
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }
}
