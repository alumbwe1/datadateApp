import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Tinder/Badoo Style
  static const Color primaryLight = Color(0xFF000000);
  static const Color secondaryLight = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFF00D9A3);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F8F8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark Theme
  static const Color primaryDark = Color(0xFFFFFFFF);
  static const Color secondaryDark = Color(0xFFFF6B6B);
  static const Color accentDark = Color(0xFF00D9A3);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF2A2A2A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color mellowLime = Color(0xFFFFD900);

  // Common
  static const Color success = Color(0xFF00D9A3);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB800);
  static const Color like = Color(0xFF00D9A3);
  static const Color nope = Color(0xFFFF6B6B);
  static const Color superLike = Color(0xFF4FC3F7);

  // Gradients
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF00D9A3), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
