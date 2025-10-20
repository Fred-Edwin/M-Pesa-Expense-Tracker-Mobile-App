import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mpesa_expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id TEXT UNIQUE,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        recipient TEXT,
        category TEXT,
        date TEXT NOT NULL,
        time TEXT,
        balance REAL,
        sms_body TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        icon TEXT,
        user_created INTEGER DEFAULT 0
      )
    ''');

    // Create category_rules table
    await db.execute('''
      CREATE TABLE category_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipient_keyword TEXT UNIQUE NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // Insert default category rules
    await _insertDefaultCategoryRules(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = CategoryConstants.getDefaultCategories();
    for (var category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  Future<void> _insertDefaultCategoryRules(Database db) async {
    final rules = _getDefaultCategoryRules();
    for (var rule in rules) {
      await db.insert('category_rules', rule.toMap());
    }
  }

  List<CategoryRule> _getDefaultCategoryRules() {
    return [
      // Food & Dining
      CategoryRule(recipientKeyword: 'NAIVAS', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'CARREFOUR', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'QUICKMART', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'CHANDARANA', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'KFC', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'PIZZA', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'RESTAURANT', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'CAFE', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'SUPERMARKET', category: CategoryConstants.foodDining),
      CategoryRule(recipientKeyword: 'GROCERY', category: CategoryConstants.foodDining),

      // Transport
      CategoryRule(recipientKeyword: 'UBER', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'BOLT', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'LITTLE CAB', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'MATATU', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'TAXI', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'TOTAL', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'SHELL', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'FUEL', category: CategoryConstants.transport),
      CategoryRule(recipientKeyword: 'PARKING', category: CategoryConstants.transport),

      // Utilities
      CategoryRule(recipientKeyword: 'KPLC', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'NAIROBI WATER', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'ZUKU', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'SAFARICOM', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'AIRTEL', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'TELKOM', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'DSTV', category: CategoryConstants.utilities),
      CategoryRule(recipientKeyword: 'GOTV', category: CategoryConstants.utilities),

      // Shopping
      CategoryRule(recipientKeyword: 'JUMIA', category: CategoryConstants.shopping),
      CategoryRule(recipientKeyword: 'KILIMALL', category: CategoryConstants.shopping),
      CategoryRule(recipientKeyword: 'MASOKO', category: CategoryConstants.shopping),

      // Entertainment
      CategoryRule(recipientKeyword: 'BETIKA', category: CategoryConstants.entertainment),
      CategoryRule(recipientKeyword: 'SPORTPESA', category: CategoryConstants.entertainment),
      CategoryRule(recipientKeyword: 'MOZZARTBET', category: CategoryConstants.entertainment),
      CategoryRule(recipientKeyword: 'NETFLIX', category: CategoryConstants.entertainment),
      CategoryRule(recipientKeyword: 'SHOWMAX', category: CategoryConstants.entertainment),
      CategoryRule(recipientKeyword: 'CINEMA', category: CategoryConstants.entertainment),

      // Health
      CategoryRule(recipientKeyword: 'PHARMACY', category: CategoryConstants.health),
      CategoryRule(recipientKeyword: 'HOSPITAL', category: CategoryConstants.health),
      CategoryRule(recipientKeyword: 'CLINIC', category: CategoryConstants.health),
      CategoryRule(recipientKeyword: 'DOCTOR', category: CategoryConstants.health),

      // Education
      CategoryRule(recipientKeyword: 'SCHOOL', category: CategoryConstants.education),
      CategoryRule(recipientKeyword: 'UNIVERSITY', category: CategoryConstants.education),
      CategoryRule(recipientKeyword: 'COLLEGE', category: CategoryConstants.education),
      CategoryRule(recipientKeyword: 'COURSE', category: CategoryConstants.education),
    ];
  }

  // ===== TRANSACTION OPERATIONS =====

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    try {
      return await db.insert('transactions', transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting transaction: $e');
      return -1;
    }
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Search transactions
  Future<List<Transaction>> searchTransactions(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'recipient LIKE ? OR transaction_id LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Get total spent (all time)
  Future<double> getTotalSpent() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type IN ('PAYMENT', 'WITHDRAWAL', 'AIRTIME', 'PAYBILL', 'BUY_GOODS')
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total spent this month
  Future<double> getTotalSpentThisMonth() async {
    final db = await database;
    final now = DateTime.now();
    final monthYear = '${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}';

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type IN ('PAYMENT', 'WITHDRAWAL', 'AIRTIME', 'PAYBILL', 'BUY_GOODS')
      AND date LIKE ?
    ''', ['%/$monthYear']);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get spending by category
  Future<Map<String, double>> getSpendingByCategory() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, SUM(amount) as total FROM transactions
      WHERE type IN ('PAYMENT', 'WITHDRAWAL', 'AIRTIME', 'PAYBILL', 'BUY_GOODS')
      GROUP BY category
      ORDER BY total DESC
    ''');

    Map<String, double> categorySpending = {};
    for (var row in result) {
      categorySpending[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return categorySpending;
  }

  // ===== CATEGORY OPERATIONS =====

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // ===== CATEGORY RULE OPERATIONS =====

  Future<int> insertCategoryRule(CategoryRule rule) async {
    final db = await database;
    return await db.insert('category_rules', rule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryRule>> getAllCategoryRules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('category_rules');
    return List.generate(maps.length, (i) => CategoryRule.fromMap(maps[i]));
  }

  Future<String?> getCategoryForRecipient(String recipient) async {
    final rules = await getAllCategoryRules();
    final upperRecipient = recipient.toUpperCase();

    for (var rule in rules) {
      if (upperRecipient.contains(rule.recipientKeyword.toUpperCase())) {
        return rule.category;
      }
    }
    return null;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
