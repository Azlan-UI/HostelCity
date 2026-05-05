import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // Format date as "Jan 23, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date as "23/01/2026"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date and time as "Jan 23, 2026 2:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
  }

  // Format time as "2:30 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  // Format month and year as "January 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Format as "2026-01" for payment month
  static String formatPaymentMonth(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  // Parse payment month "2026-01" to DateTime
  static DateTime parsePaymentMonth(String month) {
    return DateFormat('yyyy-MM').parse(month);
  }

  // Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Format duration (e.g., "2 months 15 days")
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    
    if (days >= 365) {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      final months = (remainingDays / 30).floor();
      
      if (months > 0) {
        return '$years ${years == 1 ? 'year' : 'years'} $months ${months == 1 ? 'month' : 'months'}';
      }
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (days >= 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      
      if (remainingDays > 0) {
        return '$months ${months == 1 ? 'month' : 'months'} $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
      }
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    } else {
      return 'Less than a day';
    }
  }
}
