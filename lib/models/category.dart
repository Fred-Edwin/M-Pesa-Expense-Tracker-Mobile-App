class Category {
  final int? id;
  final String name;
  final String icon; // Emoji or icon name
  final bool userCreated;

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.userCreated = false,
  });

  // Convert Category to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'user_created': userCreated ? 1 : 0,
    };
  }

  // Create Category from Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      userCreated: (map['user_created'] as int) == 1,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon, userCreated: $userCreated}';
  }
}

// Predefined categories
class CategoryConstants {
  static const String foodDining = 'FOOD & DINING';
  static const String transport = 'TRANSPORT';
  static const String utilities = 'UTILITIES';
  static const String shopping = 'SHOPPING';
  static const String entertainment = 'ENTERTAINMENT';
  static const String health = 'HEALTH';
  static const String education = 'EDUCATION';
  static const String cashOut = 'CASH_OUT';
  static const String transfer = 'TRANSFER';
  static const String airtime = 'AIRTIME';
  static const String other = 'OTHER';

  static List<Category> getDefaultCategories() {
    return [
      Category(name: foodDining, icon: '🍽️'),
      Category(name: transport, icon: '🚗'),
      Category(name: utilities, icon: '💡'),
      Category(name: shopping, icon: '🛍️'),
      Category(name: entertainment, icon: '🎬'),
      Category(name: health, icon: '⚕️'),
      Category(name: education, icon: '📚'),
      Category(name: cashOut, icon: '💵'),
      Category(name: transfer, icon: '💸'),
      Category(name: airtime, icon: '📱'),
      Category(name: other, icon: '📌'),
    ];
  }
}

class CategoryRule {
  final int? id;
  final String recipientKeyword;
  final String category;

  CategoryRule({
    this.id,
    required this.recipientKeyword,
    required this.category,
  });

  // Convert CategoryRule to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipient_keyword': recipientKeyword,
      'category': category,
    };
  }

  // Create CategoryRule from Map
  factory CategoryRule.fromMap(Map<String, dynamic> map) {
    return CategoryRule(
      id: map['id'] as int?,
      recipientKeyword: map['recipient_keyword'] as String,
      category: map['category'] as String,
    );
  }
}
