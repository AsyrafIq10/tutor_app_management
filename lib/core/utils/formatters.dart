import 'package:intl/intl.dart';

final _rm = NumberFormat('#,##0.##', 'en_US');
final _time = DateFormat('h:mm a', 'en_US');

/// 1200 -> "RM 1,200", 85.5 -> "RM 85.5".
String formatRm(num amount) => 'RM ${_rm.format(amount)}';

/// 1 -> "1st", 2 -> "2nd", 11 -> "11th", 22 -> "22nd".
String ordinal(int n) {
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

/// "10:00 AM – 11:30 AM".
String timeRange(DateTime start, DateTime end) =>
    '${_time.format(start)} – ${_time.format(end)}';

/// "Good morning" before 12:00, "Good afternoon" before 18:00,
/// otherwise "Good evening".
String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// "Wednesday, 18 November".
String longDate(DateTime date) => DateFormat('EEEE, d MMMM', 'en_US').format(date);
