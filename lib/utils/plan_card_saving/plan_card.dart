import 'package:intl/intl.dart';

/// Format amount as 1k, 1L, 1Cr, etc.
String formatAmount(num amount) {
  if (amount >= 10000000) {
    return "${(amount / 10000000).toStringAsFixed(2)}Cr";
  } else if (amount >= 100000) {
    return "${(amount / 100000).toStringAsFixed(2)}L";
  } else if (amount >= 1000) {
    return "${(amount / 1000).toStringAsFixed(2)}k";
  } else {
    return "₹${amount.toStringAsFixed(0)}";
  }
}

/// Safe month addition
DateTime addMonths(DateTime date, int months) {
  final int year = date.year + ((date.month - 1 + months) ~/ 12);
  final int month = ((date.month - 1 + months) % 12) + 1;
  final int day = date.day;
  final int lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
  final int safeDay = day > lastDayOfTargetMonth ? lastDayOfTargetMonth : day;
  return DateTime(year, month, safeDay);
}

/// Get next due date based on frequency
DateTime getNextDate(int frequencyIndex, DateTime date) {
  switch (frequencyIndex) {
    case 0:
      return date.add(const Duration(days: 1));
    case 1:
      return date.add(const Duration(days: 7));
    case 2:
      return addMonths(date, 1);
    default:
      return date;
  }
}

String frequencyLabel(dynamic frequency) {
  if (frequency is String) {
    switch (frequency.toUpperCase()) {
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        return 'Weekly';
      case 'MONTHLY':
        return 'Monthly';
      default:
        return frequency;
    }
  } else if (frequency is int) {
    switch (frequency) {
      case 0:
        return 'Daily';
      case 1:
        return 'Weekly';
      case 2:
        return 'Monthly';
      default:
        return 'Unknown';
    }
  } else {
    return 'Unknown';
  }
}

