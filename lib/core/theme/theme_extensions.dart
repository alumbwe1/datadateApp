import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_style.dart';

/// Extension on BuildContext for easy theme access
extension ThemeExtension on BuildContext {
  /// Get current theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => colors.primary;

  /// Get secondary color
  Color get secondaryColor => colors.secondary;

  /// Get background color
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  /// Get surface color
  Color get surfaceColor => colors.surface;

  /// Get text primary color
  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  /// Get text secondary color
  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
}

/// Extension for common text styles
extension TextStyleExtension on BuildContext {
  /// Heading 1 - Large titles
  TextStyle get h1 => appStyle(32, textPrimary, FontWeight.w800);

  /// Heading 2 - Section titles
  TextStyle get h2 => appStyle(26, textPrimary, FontWeight.w700);

  /// Heading 3 - Card titles
  TextStyle get h3 => appStyle(20, textPrimary, FontWeight.w600);

  /// Heading 4 - Small titles
  TextStyle get h4 => appStyle(18, textPrimary, FontWeight.w600);

  /// Body Large - Main content
  TextStyle get bodyLarge => appStyle(16, textPrimary, FontWeight.w400);

  /// Body Medium - Secondary content
  TextStyle get bodyMedium => appStyle(15, textPrimary, FontWeight.w400);

  /// Body Small - Tertiary content
  TextStyle get bodySmall => appStyle(14, textSecondary, FontWeight.w400);

  /// Caption - Small labels
  TextStyle get caption => appStyle(12, textSecondary, FontWeight.w500);

  /// Button text
  TextStyle get button => appStyle(16, Colors.white, FontWeight.w700);
}

/// Extension for common colors
extension ColorExtension on BuildContext {
  /// Like/Success color
  Color get likeColor => AppColors.like;

  /// Nope/Error color
  Color get nopeColor => AppColors.nope;

  /// Super like color
  Color get superLikeColor => AppColors.superLike;

  /// Success color
  Color get successColor => AppColors.success;

  /// Error color
  Color get errorColor => AppColors.error;

  /// Warning color
  Color get warningColor => AppColors.warning;

  /// Divider color
  Color get dividerColor =>
      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

  /// Border color
  Color get borderColor =>
      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
}

/// Extension for common gradients
extension GradientExtension on BuildContext {
  /// Like gradient
  LinearGradient get likeGradient => AppColors.likeGradient;

  /// Nope gradient
  LinearGradient get nopeGradient => AppColors.nopeGradient;

  /// Primary gradient
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, primaryColor.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Extension for common spacing
extension SpacingExtension on BuildContext {
  /// Extra small spacing (4px)
  double get spaceXS => 4.0;

  /// Small spacing (8px)
  double get spaceS => 8.0;

  /// Medium spacing (12px)
  double get spaceM => 12.0;

  /// Large spacing (16px)
  double get spaceL => 16.0;

  /// Extra large spacing (24px)
  double get spaceXL => 24.0;

  /// Extra extra large spacing (32px)
  double get spaceXXL => 32.0;
}

/// Extension for common border radius
extension RadiusExtension on BuildContext {
  /// Small radius (8px)
  BorderRadius get radiusS => BorderRadius.circular(8);

  /// Medium radius (12px)
  BorderRadius get radiusM => BorderRadius.circular(12);

  /// Large radius (16px)
  BorderRadius get radiusL => BorderRadius.circular(16);

  /// Extra large radius (20px)
  BorderRadius get radiusXL => BorderRadius.circular(20);

  /// Pill radius (999px)
  BorderRadius get radiusPill => BorderRadius.circular(999);
}
