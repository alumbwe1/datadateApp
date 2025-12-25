import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatMessageTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show only time (e.g., "2:30 PM")
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday - show "Yesterday"
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // This week - show day name (e.g., "Monday")
      return DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      // This year - show month and day (e.g., "Dec 19")
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Different year - show full date (e.g., "Dec 19, 2023")
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  static String formatChatListTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time (e.g., "2:30 PM")
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // This week - show day name
      return DateFormat('EEE').format(dateTime); // Short day name
    } else {
      // Older - show date
      return DateFormat('M/d/yy').format(dateTime);
    }
  }

  static String formatMessageBubbleTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  static bool shouldShowDateSeparator(
    String currentMessageTime,
    String? previousMessageTime,
  ) {
    if (previousMessageTime == null) return true;

    final currentDate = DateTime.parse(currentMessageTime);
    final previousDate = DateTime.parse(previousMessageTime);

    // Show separator if messages are from different days
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  static String formatDateSeparator(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // This week - show full day name
      return DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      // This year - show "Monday, December 19"
      return DateFormat('EEEE, MMMM d').format(dateTime);
    } else {
      // Different year - show "Monday, December 19, 2023"
      return DateFormat('EEEE, MMMM d, y').format(dateTime);
    }
  }

  static bool isToday(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    return dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;
  }

  static bool isYesterday(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return dateTime.day == yesterday.day &&
        dateTime.month == yesterday.month &&
        dateTime.year == yesterday.year;
  }
}
