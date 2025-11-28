import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Romantic & Warm
  static const Color primaryLight = Color(
    0xFFFF6B9D,
  ); // Soft pink - love & romance
  static const Color secondaryLight = Color(0xFFFF8FB1); // Lighter pink
  static const Color accentLight = Color(
    0xFFFFC947,
  ); // Warm gold - special moments
  static const Color backgroundLight = Color(
    0xFFFFF5F7,
  ); // Soft blush background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2D2D2D);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Navigation Colors - Light
  static const Color navEncountersLight = Color(
    0xFFFF6B9D,
  ); // Pink for encounters/matches
  static const Color navDiscoverLight = Color(0xFFFF8F5A); // Coral for explore
  static const Color navLikesLight = Color(0xFFFF4177); // Deep pink for likes
  static const Color navChatsLight = Color(0xFF4FC3F7); // Blue for chats
  static const Color navProfileLight = Color(0xFF9C27B0); // Purple for profile

  // Dark Theme - Intimate & Sophisticated
  static const Color primaryDark = Color(0xFFFF6B9D); // Keep romantic pink
  static const Color secondaryDark = Color(0xFFFF8FB1);
  static const Color accentDark = Color(0xFFFFC947); // Gold accent pops in dark
  static const Color backgroundDark = Color(0xFF1A1625); // Deep purple-black
  static const Color surfaceDark = Color(0xFF2A1F35); // Rich dark purple
  static const Color cardDark = Color(0xFF352844); // Elegant card surface
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0C0);

  // Navigation Colors - Dark
  static const Color navEncountersDark = Color(0xFFFF6B9D);
  static const Color navDiscoverDark = Color(0xFFFF8F5A);
  static const Color navLikesDark = Color(0xFFFF4177);
  static const Color navChatsDark = Color(0xFF4FC3F7);
  static const Color navProfileDark = Color(0xFFAB47BC);

  // Common - Dating Actions
  static const Color success = Color(0xFF4CAF50); // Match success
  static const Color error = Color(0xFFFF5252); // Connection error
  static const Color warning = Color(0xFFFFC947); // Gold for premium
  static const Color like = Color(0xFFFF6B9D); // Heart pink
  static const Color nope = Color(0xFF9E9E9E); // Neutral gray for pass
  static const Color superLike = Color(0xFF4FC3F7); // Blue star

  // Gradients - Romantic & Eye-catching
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1), Color(0xFFFFADC6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient superLikeGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heartGradient = LinearGradient(
    colors: [Colors.pink, Color(0xFFFF4177)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFC947), Color(0xFFFFD700), Color(0xFFFFE066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
