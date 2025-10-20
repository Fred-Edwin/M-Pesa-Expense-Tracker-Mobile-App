# Quick Start Guide - M-Pesa Expense Tracker

## 🚀 Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Grant SMS Permission
- When the app opens, tap "Get Started"
- Grant SMS permission when prompted
- Wait for parsing to complete
- View your expense dashboard!

---

## 📁 Project Files Overview

### Core Application Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, splash screen |
| `lib/screens/welcome_screen.dart` | Onboarding & permission request |
| `lib/screens/dashboard_screen.dart` | Main home screen |
| `lib/screens/transaction_list_screen.dart` | View all transactions |
| `lib/screens/transaction_detail_screen.dart` | Individual transaction details |

### Business Logic
| File | Purpose |
|------|---------|
| `lib/services/sms_parser_service.dart` | Parse M-Pesa SMS messages |
| `lib/services/sms_reader_service.dart` | Read SMS & handle permissions |
| `lib/services/database_helper.dart` | SQLite database operations |
| `lib/services/transaction_provider.dart` | State management with Provider |

### Data Models
| File | Purpose |
|------|---------|
| `lib/models/transaction.dart` | Transaction data model |
| `lib/models/category.dart` | Category & rules models |

### UI Components
| File | Purpose |
|------|---------|
| `lib/widgets/summary_card.dart` | Total/Monthly cards on dashboard |
| `lib/widgets/transaction_list_item.dart` | Transaction row widget |
| `lib/widgets/category_row.dart` | Category spending row |

### Configuration
| File | Purpose |
|------|---------|
| `lib/utils/app_theme.dart` | Theme, colors, fonts, spacing |
| `lib/utils/currency_formatter.dart` | Format currency amounts |
| `pubspec.yaml` | Dependencies & app config |
| `android/app/src/main/AndroidManifest.xml` | SMS permissions |

---

## 🎨 Customization Tips

### Change Primary Color
Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryGreen = Color(0xFF00A651); // Change this
```

### Add New Merchant Rule
Edit `lib/services/database_helper.dart`, add to `_getDefaultCategoryRules()`:
```dart
CategoryRule(recipientKeyword: 'MERCHANT_NAME', category: CategoryConstants.foodDining),
```

### Modify Categories
Edit `lib/models/category.dart` → `getDefaultCategories()`:
```dart
Category(name: 'YOUR_CATEGORY', icon: '🎯'),
```

---

## 🐛 Troubleshooting

### Problem: App crashes on startup
**Solution**: Run `flutter clean` then `flutter pub get`

### Problem: SMS not parsing
**Solution**:
1. Check SMS permission is granted
2. Ensure SMS is from sender "MPESA"
3. Check logcat for parsing errors: `flutter logs`

### Problem: Build fails
**Solution**:
1. Check Flutter version: `flutter doctor`
2. Update dependencies: `flutter pub upgrade`
3. Clean build: `flutter clean`

### Problem: Permission dialog not showing
**Solution**:
1. Check `AndroidManifest.xml` has SMS permissions
2. Uninstall app and reinstall
3. Check Android version (requires API 23+)

---

## 📱 Testing with Sample Data

### Manual SMS Testing
1. Create test SMS messages in your phone
2. Use M-Pesa format from `PRD.md` Appendix A
3. Open app and sync

### Quick Test Messages
Send these to yourself from "MPESA":
```
SAF123ABC confirmed. Ksh500.00 sent to TEST USER 0700000000 on 15/3/24 at 2:30 PM. New M-PESA balance is Ksh2,450.00

SAF456DEF confirmed. Ksh1,200.00 paid to NAIVAS SUPERMARKET for account 12345 on 15/3/24 at 3:00 PM. New M-PESA balance is Ksh3,250.00
```

---

## 📦 Build Release APK

```bash
# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎯 Key Features to Test

1. ✅ **Dashboard** - View summary cards and recent transactions
2. ✅ **Search** - Search for merchants in transaction list
3. ✅ **Filter** - Filter transactions by category
4. ✅ **Edit Category** - Change transaction category
5. ✅ **Add Note** - Add personal notes to transactions
6. ✅ **Pull to Refresh** - Sync new M-Pesa SMS
7. ✅ **View Details** - Tap transaction to see full details

---

## 📚 Documentation

- **PRD.md** - Complete product requirements
- **design.md** - UI/UX design specifications
- **README.md** - Full setup & usage guide
- **IMPLEMENTATION_SUMMARY.md** - Complete implementation details

---

## 🆘 Need Help?

1. Check **README.md** for detailed instructions
2. Review **PRD.md** for feature requirements
3. See **design.md** for UI specifications
4. Read **IMPLEMENTATION_SUMMARY.md** for technical details

---

## ✅ Checklist Before Running

- [ ] Flutter SDK installed (3.0+)
- [ ] Android Studio or VS Code with Flutter
- [ ] Android device/emulator running
- [ ] Run `flutter pub get`
- [ ] Check `flutter doctor` (no issues)

---

**Ready to Go!** 🚀

Run `flutter run` and start tracking your M-Pesa expenses!
