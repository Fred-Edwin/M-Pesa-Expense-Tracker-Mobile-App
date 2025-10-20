import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'database_helper.dart';
import 'sms_reader_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SmsReaderService _smsService = SmsReaderService();

  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  Map<String, double> _categorySpending = {};

  double _totalSpent = 0.0;
  double _totalSpentThisMonth = 0.0;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  Map<String, double> get categorySpending => _categorySpending;
  double get totalSpent => _totalSpent;
  double get totalSpentThisMonth => _totalSpentThisMonth;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Transaction> get recentTransactions =>
      _transactions.take(10).toList();

  // Initialize - Load data from database
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await loadTransactions();
      await loadCategories();
      await loadSummaryData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all transactions from database
  Future<void> loadTransactions() async {
    try {
      _transactions = await _dbHelper.getAllTransactions();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _dbHelper.getAllCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  // Load summary data
  Future<void> loadSummaryData() async {
    try {
      _totalSpent = await _dbHelper.getTotalSpent();
      _totalSpentThisMonth = await _dbHelper.getTotalSpentThisMonth();
      _categorySpending = await _dbHelper.getSpendingByCategory();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load summary: $e';
      notifyListeners();
    }
  }

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    return await _smsService.requestSmsPermission();
  }

  // Check SMS permission
  Future<bool> checkSmsPermission() async {
    return await _smsService.isSmsPermissionGranted();
  }

  // Parse and store SMS messages
  Future<int> parseAndStoreSms({
    Function(int current, int total)? onProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final count = await _smsService.parseAndStoreMessages(
        onProgress: onProgress,
      );

      // Reload data after parsing
      await loadTransactions();
      await loadSummaryData();

      _isLoading = false;
      notifyListeners();

      return count;
    } catch (e) {
      _errorMessage = 'Failed to parse SMS: $e';
      _isLoading = false;
      notifyListeners();
      return 0;
    }
  }

  // Sync new messages
  Future<int> syncNewMessages() async {
    try {
      final count = await _smsService.syncNewMessages();

      if (count > 0) {
        // Reload data after syncing
        await loadTransactions();
        await loadSummaryData();
      }

      return count;
    } catch (e) {
      _errorMessage = 'Failed to sync messages: $e';
      notifyListeners();
      return 0;
    }
  }

  // Update transaction category
  Future<void> updateTransactionCategory(int transactionId, String newCategory) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == transactionId);
      final updatedTransaction = transaction.copyWith(category: newCategory);

      await _dbHelper.updateTransaction(updatedTransaction);

      // Reload data
      await loadTransactions();
      await loadSummaryData();
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  // Update transaction notes
  Future<void> updateTransactionNotes(int transactionId, String notes) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == transactionId);
      final updatedTransaction = transaction.copyWith(notes: notes);

      await _dbHelper.updateTransaction(updatedTransaction);

      // Reload transactions
      await loadTransactions();
    } catch (e) {
      _errorMessage = 'Failed to update notes: $e';
      notifyListeners();
    }
  }

  // Search transactions
  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      if (query.isEmpty) {
        return _transactions;
      }
      return await _dbHelper.searchTransactions(query);
    } catch (e) {
      _errorMessage = 'Failed to search: $e';
      notifyListeners();
      return [];
    }
  }

  // Filter transactions by category
  Future<List<Transaction>> filterByCategory(String category) async {
    try {
      return await _dbHelper.getTransactionsByCategory(category);
    } catch (e) {
      _errorMessage = 'Failed to filter: $e';
      notifyListeners();
      return [];
    }
  }

  // Get top categories by spending
  List<MapEntry<String, double>> getTopCategories({int limit = 5}) {
    final entries = _categorySpending.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  // Get category icon
  String getCategoryIcon(String categoryName) {
    try {
      final category = _categories.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => Category(name: 'OTHER', icon: '📌'),
      );
      return category.icon;
    } catch (e) {
      return '📌';
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
