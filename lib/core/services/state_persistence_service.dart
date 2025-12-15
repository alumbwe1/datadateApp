import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_logs.dart';

class StatePersistenceService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      CustomLogs.success(
        'State persistence service initialized',
        tag: 'STATE_PERSISTENCE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to initialize state persistence: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  /// Navigation state persistence
  static const String _navigationIndexKey = 'navigation_index';
  static const String _lastVisitedPageKey = 'last_visited_page';
  static const String _pageHistoryKey = 'page_history';

  static Future<void> saveNavigationState({
    required int currentIndex,
    required String currentRoute,
    List<String>? pageHistory,
  }) async {
    try {
      await _prefs?.setInt(_navigationIndexKey, currentIndex);
      await _prefs?.setString(_lastVisitedPageKey, currentRoute);

      if (pageHistory != null) {
        await _prefs?.setStringList(_pageHistoryKey, pageHistory);
      }

      CustomLogs.debug(
        'Navigation state saved: index=$currentIndex, route=$currentRoute',
        tag: 'STATE_PERSISTENCE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to save navigation state: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  static NavigationState? getNavigationState() {
    try {
      final index = _prefs?.getInt(_navigationIndexKey);
      final route = _prefs?.getString(_lastVisitedPageKey);
      final history = _prefs?.getStringList(_pageHistoryKey);

      if (index != null && route != null) {
        return NavigationState(
          currentIndex: index,
          currentRoute: route,
          pageHistory: history ?? [],
        );
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to get navigation state: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
    return null;
  }

  /// Filter preferences persistence
  static const String _filterPreferencesKey = 'filter_preferences';

  static Future<void> saveFilterPreferences(
    Map<String, dynamic> filters,
  ) async {
    try {
      final jsonString = jsonEncode(filters);
      await _prefs?.setString(_filterPreferencesKey, jsonString);

      CustomLogs.debug('Filter preferences saved', tag: 'STATE_PERSISTENCE');
    } catch (e) {
      CustomLogs.error(
        'Failed to save filter preferences: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  static Map<String, dynamic>? getFilterPreferences() {
    try {
      final jsonString = _prefs?.getString(_filterPreferencesKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to get filter preferences: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
    return null;
  }

  /// Chat state persistence
  static const String _chatScrollPositionsKey = 'chat_scroll_positions';
  static const String _draftMessagesKey = 'draft_messages';

  static Future<void> saveChatScrollPosition(
    String chatId,
    double position,
  ) async {
    try {
      final positions = getChatScrollPositions();
      positions[chatId] = position;

      final jsonString = jsonEncode(positions);
      await _prefs?.setString(_chatScrollPositionsKey, jsonString);

      CustomLogs.debug(
        'Chat scroll position saved for $chatId: $position',
        tag: 'STATE_PERSISTENCE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to save chat scroll position: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  static Map<String, double> getChatScrollPositions() {
    try {
      final jsonString = _prefs?.getString(_chatScrollPositionsKey);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to get chat scroll positions: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
    return {};
  }

  static Future<void> saveDraftMessage(String chatId, String message) async {
    try {
      final drafts = getDraftMessages();
      if (message.isEmpty) {
        drafts.remove(chatId);
      } else {
        drafts[chatId] = message;
      }

      final jsonString = jsonEncode(drafts);
      await _prefs?.setString(_draftMessagesKey, jsonString);

      CustomLogs.debug(
        'Draft message saved for $chatId',
        tag: 'STATE_PERSISTENCE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to save draft message: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  static Map<String, String> getDraftMessages() {
    try {
      final jsonString = _prefs?.getString(_draftMessagesKey);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to get draft messages: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
    return {};
  }

  /// User preferences persistence
  static const String _userPreferencesKey = 'user_preferences';

  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final jsonString = jsonEncode(preferences.toJson());
      await _prefs?.setString(_userPreferencesKey, jsonString);

      CustomLogs.debug('User preferences saved', tag: 'STATE_PERSISTENCE');
    } catch (e) {
      CustomLogs.error(
        'Failed to save user preferences: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }

  static UserPreferences? getUserPreferences() {
    try {
      final jsonString = _prefs?.getString(_userPreferencesKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserPreferences.fromJson(json);
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to get user preferences: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
    return null;
  }

  /// Clear all persisted state
  static Future<void> clearAllState() async {
    try {
      await _prefs?.clear();
      CustomLogs.info('All persisted state cleared', tag: 'STATE_PERSISTENCE');
    } catch (e) {
      CustomLogs.error(
        'Failed to clear persisted state: $e',
        tag: 'STATE_PERSISTENCE',
        error: e,
      );
    }
  }
}

class NavigationState {
  final int currentIndex;
  final String currentRoute;
  final List<String> pageHistory;

  NavigationState({
    required this.currentIndex,
    required this.currentRoute,
    required this.pageHistory,
  });
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final bool darkMode;
  final double textScale;

  UserPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'en',
    this.darkMode = false,
    this.textScale = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'notificationsEnabled': notificationsEnabled,
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
    'language': language,
    'darkMode': darkMode,
    'textScale': textScale,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        soundEnabled: json['soundEnabled'] ?? true,
        vibrationEnabled: json['vibrationEnabled'] ?? true,
        language: json['language'] ?? 'en',
        darkMode: json['darkMode'] ?? false,
        textScale: json['textScale'] ?? 1.0,
      );
}
