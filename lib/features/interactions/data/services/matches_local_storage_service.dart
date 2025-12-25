import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';

class MatchesLocalStorageService {
  static const String _matchesKey = 'cached_matches';
  static const String _lastUpdateKey = 'matches_last_update';

  static Future<void> saveMatches(List<MatchModel> matches) async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = matches.map((match) => match.toJson()).toList();
    await prefs.setString(_matchesKey, jsonEncode(matchesJson));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<MatchModel>> getCachedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = prefs.getString(_matchesKey);
    if (matchesJson == null) return [];

    try {
      final List<dynamic> matchesList = jsonDecode(matchesJson);
      return matchesList.map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      // If there's an error parsing cached data, return empty list
      return [];
    }
  }

  static Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUpdateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_matchesKey);
    await prefs.remove(_lastUpdateKey);
  }

  static Future<bool> isCacheValid({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return false;

    return DateTime.now().difference(lastUpdate) < maxAge;
  }
}
