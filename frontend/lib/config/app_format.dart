import 'package:intl/intl.dart';

// =============================================================================
// AppFormat - Centralized formatting utilities
// =============================================================================
class AppFormat {
  AppFormat._();

  // --- Currency ---
  static String currency(double amount, {String currencyCode = 'VND'}) {
    final absAmount = amount.abs().toInt();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    String symbol;
    switch (currencyCode) {
      case 'USD':
        symbol = '\$';
      case 'EUR':
        symbol = '\u20AC';
      case 'JPY':
        symbol = '\u00A5';
      default:
        symbol = '\u0111';
    }

    return '${buffer.toString()}$symbol';
  }

  static String currencySigned(double amount, {String currencyCode = 'VND'}) {
    final prefix = amount >= 0 ? '+' : '-';
    return '$prefix${currency(amount, currencyCode: currencyCode)}';
  }

  // --- Date ---
  static String date(DateTime date) {
    return '${date.day} thg ${date.month}, ${date.year}';
  }

  static String dateFull(DateTime date) {
    return '${date.day} thg ${date.month} n\u0103m ${date.year}';
  }

  static String dateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String monthYear(DateTime date) {
    return 'Thg ${date.month}, ${date.year}';
  }

  static String dayOfWeek(DateTime date) {
    const days = [
      'Th\u1EE9 Hai',
      'Th\u1EE9 Ba',
      'Th\u1EE9 T\u01B0',
      'Th\u1EE9 N\u0103m',
      'Th\u1EE9 S\u00E1u',
      'Th\u1EE9 B\u1EA3y',
      'Ch\u1EE7 Nh\u1EADt',
    ];
    return days[date.weekday - 1];
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'H\u00F4m nay';
    if (diff == 1) return 'H\u00F4m qua';
    if (diff < 7) return '$diff ng\u00E0y tr\u01B0\u1EDBc';
    return AppFormat.date(date);
  }

  // --- Number ---
  static String number(double value) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(value);
  }

  static String numberCompact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}t';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}tr';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
