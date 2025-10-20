# Product Requirements Document (PRD)
## M-Pesa Expense Tracker Mobile App

### 1. Product Overview

**Product Name:** M-Pesa Expense Tracker  
**Platform:** Android (Flutter)  
**Target Users:** Kenyan M-Pesa users who want to track their spending  
**Core Value:** Automatically parse M-Pesa SMS messages to provide spending insights

---

### 2. Project Objectives

- Parse M-Pesa transaction SMS messages automatically
- Categorize transactions intelligently
- Provide spending summaries and analytics
- Help users understand their spending patterns
- Simple, professional, trustworthy interface

---

### 3. Technical Stack

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Database:** SQLite (sqflite package)
- **SMS Reading:** flutter_sms_inbox package
- **Charts:** fl_chart package
- **State Management:** Provider or Riverpod
- **Permissions:** permission_handler package

---

### 4. Core Features (MVP - Phase 1)

#### 4.1 SMS Reading & Parsing
**Requirement:** Automatically read and parse M-Pesa SMS messages

**Functionality:**
- Request SMS read permission on first launch
- Read all SMS messages from "MPESA" sender
- Parse transaction details: amount, recipient, date, transaction type, balance
- Store parsed transactions in local SQLite database

**M-Pesa Message Types to Support:**
1. Send Money (Person-to-Person)
2. Lipa Na M-PESA (PayBill)
3. Lipa Na M-PESA (Till Number)
4. Buy Goods and Services
5. Paybill (Utilities)
6. Withdraw Cash (Agent/ATM)
7. Deposit Cash
8. Receive Money
9. Airtime Purchase
10. Reversal

**Parsing Logic:**
```
Example SMS: "SAF123ABC confirmed. Ksh1,200.00 paid to NAIVAS SUPERMARKET on 15/3/24 at 3:00 PM. New M-PESA balance is Ksh3,250.00"

Extract:
- Transaction ID: SAF123ABC
- Amount: 1200.00
- Type: PAYMENT
- Recipient: NAIVAS SUPERMARKET
- Date: 15/3/24
- Time: 3:00 PM
- Balance: 3250.00
```

#### 4.2 Automatic Categorization
**Requirement:** Intelligently categorize transactions

**Categories:**
- FOOD & DINING (Restaurants, supermarkets, groceries)
- TRANSPORT (Uber, matatus, fuel)
- UTILITIES (Electricity, water, internet)
- SHOPPING (Retail stores, online shopping)
- ENTERTAINMENT (Movies, streaming, betting)
- HEALTH (Pharmacy, hospitals)
- EDUCATION (Schools, courses)
- CASH_OUT (Withdrawals)
- TRANSFER (Person-to-person)
- AIRTIME (Mobile credit)
- OTHER (Uncategorized)

**Categorization Rules:**
- Use keyword matching on recipient names
- Common merchants pre-mapped (Naivas→FOOD, Uber→TRANSPORT, KPLC→UTILITIES)
- Transaction type hints (WITHDRAWAL→CASH_OUT, AIRTIME→AIRTIME)
- User can manually re-categorize
- App learns from user corrections

#### 4.3 Dashboard (Home Screen)
**Requirement:** Show spending overview at a glance

**Components:**
1. **Summary Cards (Top):**
   - Total Spent (all time)
   - This Month spending

2. **Spending by Category:**
   - List view with category emoji/icon
   - Category name
   - Amount spent in that category
   - Top 4-5 categories by spending

3. **Recent Transactions:**
   - Last 5-10 transactions
   - Merchant name
   - Amount (red for expenses, green for income)
   - Date and time
   - Tap to view details

**Data Display:**
- Currency format: KSh with comma separators (KSh 45,230)
- Expenses shown as negative with red color (-KSh 1,200)
- Income shown as positive with green color (+KSh 5,000)

#### 4.4 Transaction List View
**Requirement:** View all transactions with search and filter

**Functionality:**
- Display all transactions in chronological order (newest first)
- Search by merchant name
- Filter by:
  - Category
  - Date range
  - Transaction type (expense/income)
  - Amount range
- Sort by date or amount
- Pull-to-refresh to sync new SMS
- Tap transaction to view full details

**Transaction Detail View:**
- Full M-Pesa transaction details
- Edit category option
- Add personal notes
- View original SMS message

#### 4.5 Local Data Storage
**Requirement:** Store all data locally on device

**Database Schema:**

**Table: transactions**
```sql
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
);
```

**Table: categories**
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  icon TEXT,
  user_created INTEGER DEFAULT 0
);
```

**Table: category_rules**
```sql
CREATE TABLE category_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipient_keyword TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL
);
```

---

### 5. User Flow

#### First-Time User Flow:
1. Open app
2. Welcome screen with app explanation
3. Request SMS permission
4. Request notification permission (for future features)
5. Parse existing M-Pesa SMS messages (show progress)
6. Navigate to Dashboard

#### Returning User Flow:
1. Open app
2. App automatically checks for new M-Pesa SMS
3. Parse and categorize new transactions
4. Display updated Dashboard

---

### 6. Permissions Required

**Android Permissions:**
```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
```

**Permission Handling:**
- Request at appropriate time (not immediately on launch)
- Explain why permission is needed
- Handle permission denial gracefully
- Provide settings link if permission permanently denied

---

### 7. Non-Functional Requirements

#### Performance:
- Parse 1000 SMS messages in < 3 seconds
- Dashboard load time: < 1 second
- Smooth 60fps scrolling

#### Reliability:
- Handle malformed SMS gracefully
- No data loss
- Crash-free experience

#### Security:
- All data stored locally (no cloud sync in MVP)
- No external API calls
- No data leaves the device

#### Usability:
- Intuitive navigation
- Clear visual hierarchy
- Accessible text sizes
- Support for screen readers (basic)

---

### 8. Out of Scope (Future Phases)

**Phase 2 Features:**
- Budget setting and alerts
- Spending trends and analytics charts
- Export to CSV/PDF
- Custom categories

**Phase 3 Features:**
- Cloud backup
- Multi-device sync
- Recurring transaction detection
- Bill reminders

**Phase 4 Features:**
- Shared accounts (family tracking)
- Receipt photo attachment
- Integration with other payment methods

---

### 9. Success Metrics

**MVP Success Criteria:**
- Successfully parse 95%+ of M-Pesa SMS messages
- Automatically categorize 70%+ of transactions correctly
- App crashes < 1% of sessions
- User can find any transaction within 5 seconds

---

### 10. Development Phases

**Phase 1: Foundation (Week 1)**
- Project setup
- SMS reading and basic parsing
- Database implementation
- Basic UI skeleton

**Phase 2: Core Features (Week 2)**
- Complete transaction parsing
- Categorization logic
- Dashboard implementation
- Transaction list

**Phase 3: Polish (Week 3)**
- Search and filters
- Edit categories
- Error handling
- Performance optimization

**Phase 4: Testing (Week 4)**
- Manual testing with real data
- Bug fixes
- Final polish
- APK generation

---

### 11. Technical Considerations

#### SMS Parsing Challenges:
- M-Pesa message format variations
- Different transaction types
- Date/time format handling
- Currency formatting
- Special characters in merchant names

#### Solutions:
- Regex patterns for each message type
- Fallback parsing logic
- Test with real SMS data samples
- Graceful degradation for unparsed messages

---

### 12. Acceptance Criteria

**The app is ready when:**
- [x] User can grant SMS permission
- [x] All M-Pesa SMS are parsed and displayed
- [x] Transactions are automatically categorized
- [x] Dashboard shows accurate spending summary
- [x] User can search/filter transactions
- [x] User can manually edit categories
- [x] App handles 1000+ transactions smoothly
- [x] No crashes during normal usage
- [x] UI matches design specifications

---

### 13. Constraints

- Android only (no iOS in MVP)
- Requires Android 6.0+ (API level 23+)
- Kenyan M-Pesa format only
- No internet connection required
- No user accounts or authentication

---

### Appendix A: Sample M-Pesa SMS Messages

```
1. SEND MONEY:
SAF123ABC confirmed. Ksh500.00 sent to JOHN DOE 0712345678 on 15/3/24 at 2:30 PM. New M-PESA balance is Ksh2,450.00

2. PAYBILL:
SAF456DEF confirmed. Ksh1,200.00 paid to NAIVAS SUPERMARKET for account 12345 on 15/3/24 at 3:00 PM. New M-PESA balance is Ksh3,250.00

3. WITHDRAWAL:
SAF789GHI confirmed. Withdraw Ksh1,000.00 from ABC AGENCY 98765 on 16/3/24 at 10:00 AM. New M-PESA balance is Ksh450.00

4. RECEIVE MONEY:
SAF111JKL confirmed. You have received Ksh5,000.00 from JANE SMITH 0798765432 on 17/3/24 at 9:00 AM. New M-PESA balance is Ksh5,450.00

5. AIRTIME:
SAF222MNO confirmed. Ksh100.00 sent to 0712345678 for airtime on 18/3/24 at 8:00 PM. New M-PESA balance is Ksh5,350.00
```