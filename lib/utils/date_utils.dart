import 'package:intl/intl.dart';

class QuizDateUtils {
  static final DateFormat _dateFormatter = DateFormat('MMM d, y');
  static final DateFormat _timeFormatter = DateFormat('h:mm a');
  static final DateFormat _shortDateFormatter = DateFormat('MMM d');
  static final DateFormat _fullDateTimeFormatter = DateFormat('MMM d, y • h:mm a');

  /// Formats a date like "Apr 18, 2024"
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Formats a time like "2:30 PM"
  static String formatTime(DateTime time) => _timeFormatter.format(time);

  /// Formats a date like "Apr 18"
  static String formatShortDate(DateTime date) => _shortDateFormatter.format(date);

  /// Formats a date and time like "Apr 18, 2024 • 2:30 PM"
  static String formatFullDateTime(DateTime dateTime) => _fullDateTimeFormatter.format(dateTime);

  /// Returns a human-readable relative time like "2 hours ago" or "yesterday"
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return formatDate(dateTime);
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'yesterday';
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  /// Formats a duration like "2m 30s"
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Returns true if the date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Returns true if the date was yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
} 