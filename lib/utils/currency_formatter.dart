import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {bool showDecimals = false}) {
    final formatter = NumberFormat(showDecimals ? '#,##0.00' : '#,##0', 'en_US');
    return 'KSh ${formatter.format(amount)}';
  }

  static String formatWithSign(double amount, bool isExpense, {bool showDecimals = false}) {
    final prefix = isExpense ? '-' : '+';
    final formatted = format(amount, showDecimals: showDecimals);
    return '$prefix$formatted';
  }
}
