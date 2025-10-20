import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;

class SmsParserService {
  // Parse M-Pesa SMS message and return Transaction object
  static models.Transaction? parseMpesaSms(String smsBody, String smsDate) {
    try {
      // Extract transaction ID
      final transactionId = _extractTransactionId(smsBody);
      if (transactionId == null) return null;

      // Extract amount
      final amount = _extractAmount(smsBody);
      if (amount == null) return null;

      // Determine transaction type
      final type = _determineTransactionType(smsBody);

      // Extract recipient/merchant name
      final recipient = _extractRecipient(smsBody, type);

      // Extract date and time from SMS body (M-Pesa format)
      final dateTime = _extractDateTime(smsBody);

      // Extract balance
      final balance = _extractBalance(smsBody);

      // Get current timestamp
      final createdAt = DateTime.now().toIso8601String();

      return models.Transaction(
        transactionId: transactionId,
        amount: amount,
        type: type,
        recipient: recipient,
        category: 'OTHER', // Will be categorized later
        date: dateTime['date'] ?? _formatSmsDate(smsDate),
        time: dateTime['time'],
        balance: balance,
        smsBody: smsBody,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error parsing SMS: $e');
      return null;
    }
  }

  // Extract transaction ID (e.g., SAF123ABC)
  static String? _extractTransactionId(String sms) {
    final regex = RegExp(r'([A-Z0-9]{10})\s+confirmed', caseSensitive: false);
    final match = regex.firstMatch(sms);
    return match?.group(1);
  }

  // Extract amount (e.g., Ksh1,200.00 or 1200.00)
  static double? _extractAmount(String sms) {
    final regex = RegExp(r'Ksh?\s?([\d,]+\.?\d*)', caseSensitive: false);
    final match = regex.firstMatch(sms);
    if (match != null) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      return double.tryParse(amountStr ?? '');
    }
    return null;
  }

  // Determine transaction type from SMS content
  static String _determineTransactionType(String sms) {
    final lowerSms = sms.toLowerCase();

    if (lowerSms.contains('sent to') && lowerSms.contains('airtime')) {
      return 'AIRTIME';
    } else if (lowerSms.contains('sent to')) {
      return 'PAYMENT';
    } else if (lowerSms.contains('paid to')) {
      return 'PAYMENT';
    } else if (lowerSms.contains('withdraw')) {
      return 'WITHDRAWAL';
    } else if (lowerSms.contains('you have received')) {
      return 'RECEIVE';
    } else if (lowerSms.contains('give') && lowerSms.contains('cash')) {
      return 'DEPOSIT';
    } else if (lowerSms.contains('reversed')) {
      return 'REVERSAL';
    } else if (lowerSms.contains('buy goods')) {
      return 'BUY_GOODS';
    } else if (lowerSms.contains('paybill')) {
      return 'PAYBILL';
    }

    return 'PAYMENT'; // Default
  }

  // Extract recipient/merchant name
  static String? _extractRecipient(String sms, String type) {
    try {
      switch (type) {
        case 'PAYMENT':
        case 'PAYBILL':
        case 'BUY_GOODS':
          // Pattern: "paid to MERCHANT NAME for" or "sent to NAME phone"
          final paidToRegex = RegExp(
            r'(?:paid to|sent to)\s+([A-Z0-9\s&.-]+?)(?:\s+for\s+account|\s+\d{10}|\s+on)',
            caseSensitive: false,
          );
          final match = paidToRegex.firstMatch(sms);
          if (match != null) {
            return match.group(1)?.trim();
          }
          break;

        case 'RECEIVE':
          // Pattern: "received from NAME phone"
          final receiveRegex = RegExp(
            r'received\s+[\w\s]+from\s+([A-Z\s]+?)\s+\d{10}',
            caseSensitive: false,
          );
          final match = receiveRegex.firstMatch(sms);
          if (match != null) {
            return match.group(1)?.trim();
          }
          break;

        case 'WITHDRAWAL':
          // Pattern: "Withdraw from AGENT NAME"
          final withdrawRegex = RegExp(
            r'withdraw\s+[\w\s]+from\s+([A-Z0-9\s]+?)\s+\d+',
            caseSensitive: false,
          );
          final match = withdrawRegex.firstMatch(sms);
          if (match != null) {
            return match.group(1)?.trim();
          }
          break;

        case 'AIRTIME':
          // Pattern: "sent to phone for airtime"
          final airtimeRegex = RegExp(r'sent to\s+(\d{10})', caseSensitive: false);
          final match = airtimeRegex.firstMatch(sms);
          if (match != null) {
            return 'Airtime ${match.group(1)}';
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error extracting recipient: $e');
    }
    return 'Unknown';
  }

  // Extract date and time from SMS body
  static Map<String, String?> _extractDateTime(String sms) {
    try {
      // Pattern: "on 15/3/24 at 3:00 PM" or "on 15/03/2024 at 15:00"
      final dateTimeRegex = RegExp(
        r'on\s+(\d{1,2}/\d{1,2}/\d{2,4})\s+at\s+(\d{1,2}:\d{2}\s*(?:AM|PM)?)',
        caseSensitive: false,
      );
      final match = dateTimeRegex.firstMatch(sms);

      if (match != null) {
        return {
          'date': match.group(1),
          'time': match.group(2),
        };
      }
    } catch (e) {
      print('Error extracting date/time: $e');
    }
    return {'date': null, 'time': null};
  }

  // Extract balance from SMS
  static double? _extractBalance(String sms) {
    try {
      // Pattern: "M-PESA balance is Ksh3,250.00"
      final balanceRegex = RegExp(
        r'balance is\s+Ksh?\s?([\d,]+\.?\d*)',
        caseSensitive: false,
      );
      final match = balanceRegex.firstMatch(sms);
      if (match != null) {
        final balanceStr = match.group(1)?.replaceAll(',', '');
        return double.tryParse(balanceStr ?? '');
      }
    } catch (e) {
      print('Error extracting balance: $e');
    }
    return null;
  }

  // Format SMS date to DD/MM/YY format
  static String _formatSmsDate(String smsDate) {
    try {
      // SMS date is usually in milliseconds timestamp
      final timestamp = int.tryParse(smsDate);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('dd/MM/yy').format(date);
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return DateFormat('dd/MM/yy').format(DateTime.now());
  }

  // Test the parser with sample messages
  static void testParser() {
    final sampleMessages = [
      'SAF123ABC confirmed. Ksh500.00 sent to JOHN DOE 0712345678 on 15/3/24 at 2:30 PM. New M-PESA balance is Ksh2,450.00',
      'SAF456DEF confirmed. Ksh1,200.00 paid to NAIVAS SUPERMARKET for account 12345 on 15/3/24 at 3:00 PM. New M-PESA balance is Ksh3,250.00',
      'SAF789GHI confirmed. Withdraw Ksh1,000.00 from ABC AGENCY 98765 on 16/3/24 at 10:00 AM. New M-PESA balance is Ksh450.00',
      'SAF111JKL confirmed. You have received Ksh5,000.00 from JANE SMITH 0798765432 on 17/3/24 at 9:00 AM. New M-PESA balance is Ksh5,450.00',
      'SAF222MNO confirmed. Ksh100.00 sent to 0712345678 for airtime on 18/3/24 at 8:00 PM. New M-PESA balance is Ksh5,350.00',
    ];

    print('=== SMS Parser Test ===');
    for (var msg in sampleMessages) {
      print('\n--- Parsing: ${msg.substring(0, 50)}...');
      final transaction = parseMpesaSms(msg, DateTime.now().millisecondsSinceEpoch.toString());
      if (transaction != null) {
        print('✓ ID: ${transaction.transactionId}');
        print('✓ Type: ${transaction.type}');
        print('✓ Amount: KSh ${transaction.amount}');
        print('✓ Recipient: ${transaction.recipient}');
        print('✓ Date: ${transaction.date} at ${transaction.time}');
        print('✓ Balance: KSh ${transaction.balance}');
      } else {
        print('✗ Failed to parse');
      }
    }
  }
}
