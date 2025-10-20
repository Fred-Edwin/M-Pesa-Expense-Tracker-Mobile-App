class Transaction {
  final int? id;
  final String transactionId;
  final double amount;
  final String type; // 'PAYMENT', 'RECEIVE', 'WITHDRAWAL', 'DEPOSIT', 'AIRTIME', 'REVERSAL'
  final String? recipient;
  final String category;
  final String date; // Format: DD/MM/YY
  final String? time; // Format: HH:MM AM/PM
  final double? balance;
  final String? smsBody;
  final String? notes;
  final String createdAt;

  Transaction({
    this.id,
    required this.transactionId,
    required this.amount,
    required this.type,
    this.recipient,
    required this.category,
    required this.date,
    this.time,
    this.balance,
    this.smsBody,
    this.notes,
    required this.createdAt,
  });

  // Convert Transaction to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount,
      'type': type,
      'recipient': recipient,
      'category': category,
      'date': date,
      'time': time,
      'balance': balance,
      'sms_body': smsBody,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  // Create Transaction from Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      recipient: map['recipient'] as String?,
      category: map['category'] as String,
      date: map['date'] as String,
      time: map['time'] as String?,
      balance: map['balance'] != null ? (map['balance'] as num).toDouble() : null,
      smsBody: map['sms_body'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  // Check if transaction is an expense
  bool get isExpense {
    return type == 'PAYMENT' ||
           type == 'WITHDRAWAL' ||
           type == 'AIRTIME' ||
           type == 'PAYBILL' ||
           type == 'BUY_GOODS';
  }

  // Check if transaction is income
  bool get isIncome {
    return type == 'RECEIVE' || type == 'DEPOSIT' || type == 'REVERSAL';
  }

  // Copy with method for updates
  Transaction copyWith({
    int? id,
    String? transactionId,
    double? amount,
    String? type,
    String? recipient,
    String? category,
    String? date,
    String? time,
    double? balance,
    String? smsBody,
    String? notes,
    String? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      recipient: recipient ?? this.recipient,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      balance: balance ?? this.balance,
      smsBody: smsBody ?? this.smsBody,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, transactionId: $transactionId, amount: $amount, type: $type, recipient: $recipient, category: $category, date: $date}';
  }
}
