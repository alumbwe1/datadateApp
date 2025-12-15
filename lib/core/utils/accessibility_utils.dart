import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityUtils {
  /// Common semantic labels for the dating app
  static const String likeButtonLabel = 'Like this profile';
  static const String passButtonLabel = 'Pass on this profile';
  static const String superLikeButtonLabel = 'Super like this profile';
  static const String backButtonLabel = 'Go back';
  static const String menuButtonLabel = 'Open menu';
  static const String profileImageLabel = 'Profile photo';
  static const String sendMessageLabel = 'Send message';
  static const String attachImageLabel = 'Attach image';
  static const String recordVoiceLabel = 'Record voice message';

  /// Navigation labels
  static const String encountersTabLabel = 'Encounters tab';
  static const String discoverTabLabel = 'Discover tab';
  static const String likesTabLabel = 'Likes tab';
  static const String chatTabLabel = 'Chat tab';
  static const String profileTabLabel = 'Profile tab';

  /// Create semantic widget with proper labels
  static Widget semanticWidget({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? textField,
    bool? image,
    VoidCallback? onTap,
    bool excludeSemantics = false,
  }) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      header: header ?? false,
      textField: textField ?? false,
      image: image ?? false,
      onTap: onTap,
      child: child,
    );
  }

  /// Profile card accessibility
  static Widget accessibleProfileCard({
    required Widget child,
    required String name,
    required int age,
    String? bio,
    VoidCallback? onTap,
  }) {
    final label = 'Profile of $name, age $age';
    final hint = bio != null
        ? 'Bio: $bio. Tap to view full profile'
        : 'Tap to view full profile';

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Message bubble accessibility
  static Widget accessibleMessageBubble({
    required Widget child,
    required String message,
    required String senderName,
    required DateTime timestamp,
    bool isOwn = false,
  }) {
    final timeString = _formatTimeForAccessibility(timestamp);
    final label = isOwn
        ? 'You sent: $message at $timeString'
        : '$senderName sent: $message at $timeString';

    return Semantics(label: label, readOnly: true, child: child);
  }

  /// Navigation button accessibility
  static Widget accessibleNavButton({
    required Widget child,
    required String tabName,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final label = '$tabName tab';
    final hint = isSelected
        ? 'Currently selected'
        : 'Tap to switch to $tabName';

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: child,
    );
  }

  /// Action button accessibility (like, pass, etc.)
  static Widget accessibleActionButton({
    required Widget child,
    required String action,
    String? profileName,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final label = profileName != null
        ? '$action $profileName\'s profile'
        : action;
    final hint = enabled ? 'Double tap to $action' : 'Button disabled';

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Image with accessibility
  static Widget accessibleImage({
    required Widget child,
    String? description,
    bool isProfileImage = false,
    String? ownerName,
  }) {
    String label;
    if (isProfileImage && ownerName != null) {
      label = 'Profile photo of $ownerName';
    } else if (description != null) {
      label = description;
    } else {
      label = 'Image';
    }

    return Semantics(label: label, image: true, child: child);
  }

  /// Text field with accessibility
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool required = false,
  }) {
    final fullHint = required ? '${hint ?? ''} Required field' : hint;

    return Semantics(
      label: label,
      hint: fullHint,
      value: value,
      textField: true,
      child: child,
    );
  }

  /// Loading state accessibility
  static Widget accessibleLoadingState({
    required Widget child,
    String? loadingMessage,
  }) {
    return Semantics(
      label: loadingMessage ?? 'Loading',
      liveRegion: true,
      child: child,
    );
  }

  /// Error state accessibility
  static Widget accessibleErrorState({
    required Widget child,
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return Semantics(
      label: 'Error: $errorMessage',
      hint: onRetry != null ? 'Tap to retry' : null,
      button: onRetry != null,
      onTap: onRetry,
      child: child,
    );
  }

  /// Format time for accessibility
  static String _formatTimeForAccessibility(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Announce to screen reader
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if accessibility is enabled
  static bool get isAccessibilityEnabled {
    return WidgetsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  /// Get recommended minimum touch target size
  static double get minimumTouchTargetSize => 48.0;

  /// Ensure widget meets accessibility size requirements
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? minimumTouchTargetSize,
      height: height ?? minimumTouchTargetSize,
      child: child,
    );
  }
}
