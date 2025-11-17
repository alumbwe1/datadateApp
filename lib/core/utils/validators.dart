class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value, {String? email, String? username}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check if password is entirely numeric
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Password cannot be entirely numeric';
    }

    // Check if password is too common
    final commonPasswords = [
      'password',
      'password123',
      '12345678',
      'qwerty',
      'abc123',
      'letmein',
      'welcome',
      'monkey',
      '1234567890',
      'password1',
    ];
    if (commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common';
    }

    // Check similarity with email
    if (email != null && email.isNotEmpty) {
      final emailUsername = email.split('@')[0].toLowerCase();
      if (value.toLowerCase().contains(emailUsername) ||
          emailUsername.contains(value.toLowerCase())) {
        return 'Password is too similar to your email';
      }
    }

    // Check similarity with username
    if (username != null && username.isNotEmpty) {
      if (value.toLowerCase().contains(username.toLowerCase()) ||
          username.toLowerCase().contains(value.toLowerCase())) {
        return 'Password is too similar to your username';
      }
    }

    return null;
  }

  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 18 || age > 100) {
      return 'Enter a valid age (18-100)';
    }
    return null;
  }
}
