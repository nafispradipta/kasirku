import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yy', 'id_ID');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }
  
  static String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }
  
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return formatDate(date);
    }
  }
  
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }
  
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
}
