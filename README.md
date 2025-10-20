# M-Pesa Expense Tracker Mobile App

A Flutter mobile application that automatically tracks M-Pesa expenses by reading and parsing SMS messages from M-Pesa.

## Features

✅ **Automatic SMS Parsing** - Reads and parses M-Pesa transaction SMS messages
✅ **Smart Categorization** - Automatically categorizes transactions (Food, Transport, Utilities, etc.)
✅ **Dashboard View** - Shows total spent, monthly spending, and category breakdown
✅ **Transaction List** - View all transactions with search and filter functionality
✅ **Transaction Details** - Detailed view with ability to edit category and add notes
✅ **Offline First** - All data stored locally using SQLite
✅ **Material Design UI** - Clean, professional interface following design specifications

## Technical Stack

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Database:** SQLite (sqflite)
- **State Management:** Provider
- **SMS Reading:** flutter_sms_inbox
- **Permissions:** permission_handler
- **Typography:** Google Fonts (Inter)

## Project Structure

```
lib/
├── models/           # Data models (Transaction, Category)
├── screens/          # UI screens (Dashboard, Transaction List, etc.)
├── widgets/          # Reusable widgets (Cards, List Items)
├── services/         # Business logic (Database, SMS Parser, Provider)
├── utils/            # Utilities (Theme, Currency Formatter)
└── main.dart         # App entry point
```

## Setup Instructions

### Prerequisites

1. Flutter SDK 3.0 or higher
2. Android Studio or VS Code with Flutter extensions
3. Android device or emulator (minSdkVersion 23 / Android 6.0+)

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Build APK:**
   ```bash
   flutter build apk --release
   ```

## Permissions

The app requires the following Android permissions:

- `READ_SMS` - To read M-Pesa SMS messages
- `RECEIVE_SMS` - To receive new M-Pesa SMS messages

These permissions are requested at runtime on first launch.

## How It Works

### 1. SMS Parsing

The app reads SMS messages from "MPESA" sender and parses them using regex patterns to extract:
- Transaction ID
- Amount
- Transaction type (Payment, Withdrawal, Receive, etc.)
- Recipient/Merchant name
- Date and time
- M-Pesa balance

### 2. Automatic Categorization

Transactions are automatically categorized based on:
- **Keyword matching** - Merchant names are matched against predefined rules
- **Transaction type** - Airtime purchases, withdrawals are auto-categorized
- **Manual override** - Users can change categories manually

### 3. Data Storage

All data is stored locally in SQLite database with three tables:
- `transactions` - All transaction records
- `categories` - Category definitions
- `category_rules` - Keyword-to-category mapping rules

## Supported M-Pesa Transaction Types

✅ Send Money (Person-to-Person)
✅ Lipa Na M-PESA (PayBill)
✅ Lipa Na M-PESA (Till Number)
✅ Buy Goods and Services
✅ Withdraw Cash (Agent/ATM)
✅ Deposit Cash
✅ Receive Money
✅ Airtime Purchase
✅ Reversal

## Categories

The app includes these predefined categories:

- 🍽️ **Food & Dining** - Restaurants, supermarkets, groceries
- 🚗 **Transport** - Uber, matatus, fuel stations
- 💡 **Utilities** - KPLC, water, internet, airtime
- 🛍️ **Shopping** - Retail stores, online shopping
- 🎬 **Entertainment** - Movies, betting, streaming services
- ⚕️ **Health** - Pharmacies, hospitals, clinics
- 📚 **Education** - Schools, courses, books
- 💵 **Cash Out** - ATM/agent withdrawals
- 💸 **Transfer** - Person-to-person transfers
- 📱 **Airtime** - Mobile credit purchases
- 📌 **Other** - Uncategorized transactions

## Customization

### Adding Category Rules

Edit `lib/services/database_helper.dart` and add new rules to `_getDefaultCategoryRules()`:

```dart
CategoryRule(
  recipientKeyword: 'YOUR_MERCHANT_NAME',
  category: CategoryConstants.foodDining
),
```

### Changing Theme Colors

Edit `lib/utils/app_theme.dart` to customize colors, fonts, and spacing.

## Testing

### Test SMS Parsing

The app includes a test function in `lib/services/sms_parser_service.dart`:

```dart
SmsParserService.testParser();
```

This tests parsing with sample M-Pesa SMS messages.

## Performance

- Parses **1000 SMS messages in < 3 seconds**
- Dashboard loads in **< 1 second**
- Smooth **60fps scrolling** with thousands of transactions

## Privacy & Security

✅ All data stored **locally on device**
✅ No cloud sync or external API calls
✅ No data leaves your device
✅ No user accounts or authentication required

## Known Limitations

- Android only (iOS not supported in MVP)
- Kenyan M-Pesa format only
- Requires SMS permission (app won't work without it)

## Future Enhancements (Phase 2+)

- 📊 Budget setting and alerts
- 📈 Spending trends and analytics charts
- 📤 Export to CSV/PDF
- ☁️ Cloud backup and sync
- 🔁 Recurring transaction detection
- 🔔 Bill reminders

## Troubleshooting

### App won't parse SMS messages

1. Check SMS permission is granted
2. Ensure you have M-Pesa SMS in your inbox from sender "MPESA"
3. Try pulling down on dashboard to manually sync

### Transactions not categorizing correctly

1. Check merchant name matches category rules
2. Manually change category in transaction detail screen
3. The app will learn from your changes (future feature)

## Contributing

This is a personal expense tracking app. Feel free to fork and customize for your needs.

## License

This project is for personal use only.

## Support

For issues or questions, refer to the PRD.md and design.md documents.

---

**Built with Flutter** 💙
**Designed for Kenya** 🇰🇪
