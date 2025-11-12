import 'dart:math';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String university,
    required String relationshipGoal,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Mock implementation using dummy data
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    return UserModel(
      id: 'user_${Random().nextInt(1000)}',
      email: email,
      name: 'John Doe',
      age: 22,
      gender: 'male',
      university: 'MIT',
      bio: 'Love coding and coffee',
      photos: ['https://randomuser.me/api/portraits/men/1.jpg'],
      relationshipGoal: 'Dating',
      isSubscribed: false,
    );
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String university,
    required String relationshipGoal,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return UserModel(
      id: 'user_${Random().nextInt(1000)}',
      email: email,
      name: name,
      age: age,
      gender: gender,
      university: university,
      photos: [
        gender == 'male'
            ? 'https://randomuser.me/api/portraits/men/${Random().nextInt(99)}.jpg'
            : 'https://randomuser.me/api/portraits/women/${Random().nextInt(99)}.jpg',
      ],
      relationshipGoal: relationshipGoal,
      isSubscribed: false,
    );
  }
}
