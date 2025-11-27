import 'package:shared_preferences/shared_preferences.dart';

class FilterPreferencesService {
  static const String _keyMinAge = 'filter_min_age';
  static const String _keyMaxAge = 'filter_max_age';
  static const String _keyGender = 'filter_gender';
  static const String _keyCity = 'filter_city';
  static const String _keyCompound = 'filter_compound';
  static const String _keyUniversityId = 'filter_university_id';
  static const String _keyCourse = 'filter_course';
  static const String _keyGraduationYear = 'filter_graduation_year';
  static const String _keyIntent = 'filter_intent';
  static const String _keyInterests = 'filter_interests';
  static const String _keyOnlineOnly = 'filter_online_only';
  static const String _keyHasPhotos = 'filter_has_photos';
  static const String _keyOccupationType = 'filter_occupation_type';

  // Save filters
  Future<void> saveFilters(Map<String, dynamic> filters) async {
    final prefs = await SharedPreferences.getInstance();

    if (filters['minAge'] != null) {
      await prefs.setInt(_keyMinAge, filters['minAge']);
    }
    if (filters['maxAge'] != null) {
      await prefs.setInt(_keyMaxAge, filters['maxAge']);
    }
    if (filters['gender'] != null) {
      await prefs.setString(_keyGender, filters['gender']);
    }
    if (filters['city'] != null) {
      await prefs.setString(_keyCity, filters['city']);
    }
    if (filters['compound'] != null) {
      await prefs.setString(_keyCompound, filters['compound']);
    }
    if (filters['universityId'] != null) {
      await prefs.setInt(_keyUniversityId, filters['universityId']);
    }
    if (filters['course'] != null) {
      await prefs.setString(_keyCourse, filters['course']);
    }
    if (filters['graduationYear'] != null) {
      await prefs.setInt(_keyGraduationYear, filters['graduationYear']);
    }
    if (filters['intent'] != null) {
      await prefs.setString(_keyIntent, filters['intent']);
    }
    if (filters['interests'] != null && filters['interests'] is List) {
      await prefs.setStringList(
        _keyInterests,
        List<String>.from(filters['interests']),
      );
    }
    if (filters['onlineOnly'] != null) {
      await prefs.setBool(_keyOnlineOnly, filters['onlineOnly']);
    }
    if (filters['hasPhotos'] != null) {
      await prefs.setBool(_keyHasPhotos, filters['hasPhotos']);
    }
    if (filters['occupationType'] != null) {
      await prefs.setString(_keyOccupationType, filters['occupationType']);
    }
  }

  // Load filters
  Future<Map<String, dynamic>> loadFilters() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'minAge': prefs.getInt(_keyMinAge),
      'maxAge': prefs.getInt(_keyMaxAge),
      'gender': prefs.getString(_keyGender),
      'city': prefs.getString(_keyCity),
      'compound': prefs.getString(_keyCompound),
      'universityId': prefs.getInt(_keyUniversityId),
      'course': prefs.getString(_keyCourse),
      'graduationYear': prefs.getInt(_keyGraduationYear),
      'intent': prefs.getString(_keyIntent),
      'interests': prefs.getStringList(_keyInterests),
      'onlineOnly': prefs.getBool(_keyOnlineOnly) ?? false,
      'hasPhotos': prefs.getBool(_keyHasPhotos) ?? false,
      'occupationType': prefs.getString(_keyOccupationType),
    };
  }

  // Clear all filters
  Future<void> clearFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMinAge);
    await prefs.remove(_keyMaxAge);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyCity);
    await prefs.remove(_keyCompound);
    await prefs.remove(_keyUniversityId);
    await prefs.remove(_keyCourse);
    await prefs.remove(_keyGraduationYear);
    await prefs.remove(_keyIntent);
    await prefs.remove(_keyInterests);
    await prefs.remove(_keyOnlineOnly);
    await prefs.remove(_keyHasPhotos);
    await prefs.remove(_keyOccupationType);
  }

  // Build query parameters for API
  Map<String, dynamic> buildQueryParams(Map<String, dynamic> filters) {
    final params = <String, dynamic>{};

    if (filters['minAge'] != null) {
      params['min_age'] = filters['minAge'];
    }
    if (filters['maxAge'] != null) {
      params['max_age'] = filters['maxAge'];
    }
    if (filters['gender'] != null && filters['gender'].toString().isNotEmpty) {
      params['gender'] = filters['gender'];
    }
    if (filters['city'] != null && filters['city'].toString().isNotEmpty) {
      params['city'] = filters['city'];
    }
    if (filters['compound'] != null &&
        filters['compound'].toString().isNotEmpty) {
      params['compound'] = filters['compound'];
    }
    if (filters['universityId'] != null) {
      params['university_id'] = filters['universityId'];
    }
    if (filters['course'] != null && filters['course'].toString().isNotEmpty) {
      params['course'] = filters['course'];
    }
    if (filters['graduationYear'] != null) {
      params['graduation_year'] = filters['graduationYear'];
    }
    if (filters['intent'] != null && filters['intent'].toString().isNotEmpty) {
      params['intent'] = filters['intent'];
    }
    if (filters['interests'] != null && filters['interests'] is List) {
      final interests = filters['interests'] as List;
      if (interests.isNotEmpty) {
        params['interests'] = interests.join(',');
      }
    }
    if (filters['onlineOnly'] == true) {
      params['online_only'] = true;
    }
    if (filters['hasPhotos'] == true) {
      params['has_photos'] = true;
    }
    if (filters['occupationType'] != null &&
        filters['occupationType'].toString().isNotEmpty) {
      params['occupation_type'] = filters['occupationType'];
    }

    return params;
  }
}
