import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart' as models;
import 'sms_parser_service.dart';
import 'database_helper.dart';

class SmsReaderService {
  final SmsQuery _query = SmsQuery();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Check if SMS permission is granted
  Future<bool> isSmsPermissionGranted() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  // Read all M-Pesa SMS messages
  Future<List<SmsMessage>> readMpesaMessages() async {
    try {
      // Check permission first
      if (!await isSmsPermissionGranted()) {
        print('SMS permission not granted');
        return [];
      }

      // Query SMS messages from MPESA
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        address: 'MPESA',
        count: 1000, // Read up to 1000 messages
      );

      print('Found ${messages.length} M-Pesa SMS messages');
      return messages;
    } catch (e) {
      print('Error reading M-Pesa messages: $e');
      return [];
    }
  }

  // Parse and store M-Pesa messages in database
  Future<int> parseAndStoreMessages({
    Function(int current, int total)? onProgress,
  }) async {
    try {
      // Read M-Pesa messages
      final messages = await readMpesaMessages();
      int successCount = 0;
      int totalMessages = messages.length;

      print('Parsing $totalMessages M-Pesa messages...');

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];

        // Call progress callback
        if (onProgress != null) {
          onProgress(i + 1, totalMessages);
        }

        // Parse SMS
        final transaction = SmsParserService.parseMpesaSms(
          message.body ?? '',
          message.date?.millisecondsSinceEpoch.toString() ?? '',
        );

        if (transaction != null) {
          // Categorize transaction
          final categorizedTransaction = await _categorizeTransaction(transaction);

          // Insert into database
          final result = await _dbHelper.insertTransaction(categorizedTransaction);
          if (result != -1) {
            successCount++;
          }
        } else {
          print('Failed to parse SMS: ${message.body?.substring(0, 50)}...');
        }
      }

      print('Successfully parsed and stored $successCount out of $totalMessages messages');
      return successCount;
    } catch (e) {
      print('Error in parseAndStoreMessages: $e');
      return 0;
    }
  }

  // Categorize transaction based on recipient
  Future<models.Transaction> _categorizeTransaction(models.Transaction transaction) async {
    try {
      // First, check type-based categorization
      String? category;

      switch (transaction.type) {
        case 'AIRTIME':
          category = 'AIRTIME';
          break;
        case 'WITHDRAWAL':
          category = 'CASH_OUT';
          break;
        case 'RECEIVE':
        case 'DEPOSIT':
        case 'REVERSAL':
          // Income transactions don't need categorization by recipient
          category = 'TRANSFER';
          break;
        default:
          // For expense transactions, try to match recipient to category
          if (transaction.recipient != null) {
            category = await _dbHelper.getCategoryForRecipient(transaction.recipient!);
          }
          break;
      }

      // If no category found, use OTHER
      category ??= 'OTHER';

      return transaction.copyWith(category: category);
    } catch (e) {
      print('Error categorizing transaction: $e');
      return transaction.copyWith(category: 'OTHER');
    }
  }

  // Sync new messages (check for messages not in database)
  Future<int> syncNewMessages() async {
    try {
      final messages = await readMpesaMessages();
      final existingTransactions = await _dbHelper.getAllTransactions();

      // Get set of existing transaction IDs
      final existingIds = existingTransactions
          .map((t) => t.transactionId)
          .toSet();

      int newCount = 0;

      for (var message in messages) {
        // Parse SMS
        final transaction = SmsParserService.parseMpesaSms(
          message.body ?? '',
          message.date?.millisecondsSinceEpoch.toString() ?? '',
        );

        if (transaction != null && !existingIds.contains(transaction.transactionId)) {
          // Categorize and store new transaction
          final categorizedTransaction = await _categorizeTransaction(transaction);
          final result = await _dbHelper.insertTransaction(categorizedTransaction);

          if (result != -1) {
            newCount++;
          }
        }
      }

      print('Synced $newCount new transactions');
      return newCount;
    } catch (e) {
      print('Error syncing new messages: $e');
      return 0;
    }
  }

  // Open app settings if permission is denied
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
