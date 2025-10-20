# Design Specifications
## M-Pesa Expense Tracker Mobile App

### 1. Design Philosophy

**Style:** Modern, Clean, Professional  
**Mood:** Trustworthy, Serious, Minimal  
**Target Feel:** Premium banking app aesthetic with M-Pesa brand familiarity

---

### 2. Color Palette

#### Primary Colors
```dart
// M-Pesa Brand Green
primaryGreen: Color(0xFF00A651)
darkGreen: Color(0xFF008A43)  // For pressed states, emphasis
successGreen: Color(0xFF10B981)  // For income/positive amounts
```

#### Neutral Colors
```dart
// Backgrounds
backgroundColor: Color(0xFFF8F9FA)  // Light gray, main background
cardBackground: Color(0xFFFFFFFF)  // Pure white for cards

// Text Colors
textPrimary: Color(0xFF1F2937)  // Dark gray for main text
textSecondary: Color(0xFF6B7280)  // Medium gray for labels, subtitles
textTertiary: Color(0xFF9CA3AF)  // Light gray for timestamps

// Borders & Dividers
borderColor: Color(0xFFE5E7EB)  // Very light gray
dividerColor: Color(0xFFF3F4F6)  // Ultra light gray for subtle dividers
```

#### Accent Colors
```dart
// Semantic Colors
expenseRed: Color(0xFFEF4444)  // For negative amounts, expenses
warningOrange: Color(0xFFF59E0B)  // For alerts, warnings
infoBlue: Color(0xFF3B82F6)  // For informational messages
```

---

### 3. Typography

#### Font Family
**Primary:** Inter (Google Fonts)
```dart
fontFamily: 'Inter'
```

#### Font Sizes & Weights
```dart
// Headings
heading1: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,  // 700
  color: textPrimary,
)

heading2: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,  // 600 (Semibold)
  color: textPrimary,
)

heading3: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: textPrimary,
)

// Body Text
bodyLarge: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,  // 400
  color: textPrimary,
)

bodyMedium: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: textSecondary,
)

bodySmall: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: textSecondary,
)

// Special
amountLarge: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: textPrimary,
)

amountMedium: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textPrimary,
)

caption: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: textTertiary,
)
```

---

### 4. Spacing System

**Use multiples of 4 for consistency:**

```dart
// Spacing Constants
spacing4: 4.0
spacing8: 8.0
spacing12: 12.0
spacing16: 16.0  // Most common - default padding
spacing24: 24.0  // Section spacing
spacing32: 32.0  // Large section spacing
spacing48: 48.0  // Extra large spacing
```

**Application:**
- Screen padding: 16px (left/right)
- Between cards: 16px vertical
- Inside cards: 16px padding
- Between sections: 24px vertical
- List item padding: 16px

---

### 5. Border Radius

```dart
// Rounded Corners
radiusSmall: 8.0   // Input fields, small elements
radiusMedium: 12.0  // Buttons, chips
radiusLarge: 16.0   // Cards, containers
radiusXLarge: 20.0  // Bottom sheets, modals
```

---

### 6. Shadows & Elevation

```dart
// Card Shadow (Soft, subtle)
cardShadow: BoxShadow(
  color: Colors.black.withOpacity(0.05),
  offset: Offset(0, 2),
  blurRadius: 8,
  spreadRadius: 0,
)

// Elevated Shadow (Slightly more pronounced)
elevatedShadow: BoxShadow(
  color: Colors.black.withOpacity(0.08),
  offset: Offset(0, 4),
  blurRadius: 12,
  spreadRadius: 0,
)

// Floating Action Button Shadow
fabShadow: BoxShadow(
  color: primaryGreen.withOpacity(0.3),
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: 0,
)
```

---

### 7. Screen-by-Screen Design Specs

### 7.1 Dashboard (Home Screen)

#### Header Component
```
Height: 80px
Background: primaryGreen (#00A651)
Padding: 16px horizontal

Elements:
- App Title "My Expenses"
  Position: Left aligned
  Font: heading2 (18px, Semibold)
  Color: White
  
- Bell Icon (Notification)
  Position: 56px from right edge
  Size: 24x24px
  Color: White
  
- Settings Icon (Gear)
  Position: 16px from right edge
  Size: 24x24px
  Color: White
```

#### Summary Cards Section
```
Margin: 16px from screen edge
Gap between cards: 12px

Card Specifications:
- Background: cardBackground (white)
- Border Radius: 16px
- Shadow: cardShadow
- Padding: 16px
- Width: (screenWidth - 44px) / 2  // Equal width

Card Content:
- Label (top)
  Font: bodySmall (12px)
  Color: textSecondary
  Margin bottom: 8px
  
- Currency Symbol "KSh"
  Font: heading3 (16px, Semibold)
  Color: textPrimary
  
- Amount "45,230"
  Font: amountLarge (28px, Bold)
  Color: textPrimary
  Line height: 1.2
```

#### Category Breakdown Card
```
Margin: 24px from top of previous section
Margin: 16px horizontal
Background: cardBackground (white)
Border Radius: 16px
Shadow: cardShadow
Padding: 16px

Header:
- "Spending by Category"
  Font: heading2 (18px, Semibold)
  Color: textPrimary
  Margin bottom: 16px

Category Row:
- Height: 56px
- Padding: 12px 0
- Border bottom: 1px solid dividerColor (except last item)

Row Layout:
- Emoji/Icon (left)
  Size: 24x24px
  Margin right: 12px
  
- Category Name (middle)
  Font: bodyLarge (14px)
  Color: textPrimary
  Flex: 1 (takes remaining space)
  
- Amount (right)
  Font: bodyLarge (14px, Semibold)
  Color: textPrimary
```

#### Recent Transactions Card
```
Margin: 24px from top
Margin: 16px horizontal
Background: cardBackground (white)
Border Radius: 16px
Shadow: cardShadow
Padding: 16px

Header:
- "Recent Transactions"
  Font: heading2 (18px, Semibold)
  Color: textPrimary
  Margin bottom: 16px

Transaction Row:
- Padding: 12px 0
- Border bottom: 1px solid dividerColor (except last)
- Min height: 60px

Row Layout (Two rows):
Row 1:
- Merchant Name (left)
  Font: bodyLarge (14px, Medium)
  Color: textPrimary
  
- Amount (right)
  Font: bodyLarge (14px, Bold)
  Color: expenseRed (for expenses) or successGreen (for income)

Row 2:
- Date/Time (left)
  Font: caption (12px)
  Color: textTertiary
  Margin top: 4px
```

---

### 7.2 Transaction List Screen

#### App Bar
```
Height: 56px
Background: cardBackground (white)
Elevation: cardShadow

Elements:
- Back Button (left)
  Icon: arrow_back
  Size: 24x24px
  Color: textPrimary
  Padding: 16px
  
- Title "Transactions"
  Font: heading2 (18px, Semibold)
  Color: textPrimary
  
- Filter Icon (right)
  Icon: filter_list
  Size: 24x24px
  Color: textPrimary
  Padding: 16px
```

#### Search Bar
```
Margin: 16px
Background: backgroundColor (#F8F9FA)
Border Radius: 12px
Height: 48px
Padding: 12px 16px

Elements:
- Search Icon (left)
  Size: 20x20px
  Color: textSecondary
  
- Input Field
  Font: bodyLarge (14px)
  Color: textPrimary
  Placeholder: "Search transactions..."
  Placeholder Color: textSecondary
```

#### Transaction List Item
```
Background: cardBackground (white)
Margin: 8px 16px
Border Radius: 12px
Shadow: cardShadow (subtle)
Padding: 16px

Layout: Same as Dashboard Recent Transactions
Include Category Badge:
- Position: Below merchant name
- Font: bodySmall (12px)
- Color: textSecondary
- Background: backgroundColor with 8px border radius
- Padding: 4px 8px
```

---

### 7.3 Transaction Detail Screen

#### Top Section (Card)
```
Margin: 16px
Background: cardBackground (white)
Border Radius: 16px
Shadow: cardShadow
Padding: 24px

Elements:
- Amount (centered)
  Font: amountLarge (32px, Bold)
  Color: expenseRed or successGreen
  Margin bottom: 8px
  
- Merchant Name (centered)
  Font: heading2 (18px, Semibold)
  Color: textPrimary
  Margin bottom: 24px
  
- Details Grid (2 columns)
  Label Font: bodySmall (12px)
  Label Color: textSecondary
  Value Font: bodyLarge (14px)
  Value Color: textPrimary
  Row height: 40px
  
  Fields:
  - Category
  - Transaction ID
  - Date
  - Time
  - Balance After
```

#### Actions Section
```
Margin: 16px horizontal
Gap: 12px between buttons

Button Specifications:
- Height: 48px
- Border Radius: 12px
- Font: bodyLarge (14px, Semibold)

Primary Button (Edit Category):
- Background: primaryGreen
- Text Color: White
- Full width

Secondary Button (Add Note):
- Background: backgroundColor
- Text Color: textPrimary
- Border: 1px solid borderColor
- Full width
```

---

### 8. Component Library

#### 8.1 Buttons

**Primary Button**
```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    color: primaryGreen,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Button Text',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
)
```

**Secondary Button**
```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
  ),
  child: Text(
    'Button Text',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
  ),
)
```

#### 8.2 Cards

**Standard Card**
```dart
Container(
  decoration: BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [cardShadow],
  ),
  padding: EdgeInsets.all(16),
  child: // Card content
)
```

#### 8.3 List Items

**Transaction List Item**
```dart
Container(
  decoration: BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [cardShadow],
  ),
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      // Icon/Emoji
      // Merchant name & date
      Spacer(),
      // Amount
    ],
  ),
)
```

---

### 9. Icons & Imagery

#### Icon Library
Use **Material Icons** (built into Flutter)

**Common Icons:**
```
- Home: Icons.home
- Transactions: Icons.receipt_long
- Categories: Icons.category
- Settings: Icons.settings
- Notifications: Icons.notifications
- Search: Icons.search
- Filter: Icons.filter_list
- Back: Icons.arrow_back
- Edit: Icons.edit
- Delete: Icons.delete
```

#### Category Icons/Emojis
```
Food & Dining: 🍽️ or Icons.restaurant
Transport: 🚗 or Icons.directions_car
Utilities: 💡 or Icons.bolt
Shopping: 🛍️ or Icons.shopping_bag
Entertainment: 🎬 or Icons.movie
Health: ⚕️ or Icons.medical_services
Education: 📚 or Icons.school
Cash Out: 💵 or Icons.account_balance_wallet
Transfer: 💸 or Icons.swap_horiz
Airtime: 📱 or Icons.phone_android
Other: 📌 or Icons.more_horiz
```

---

### 10. Animations & Transitions

#### Screen Transitions
```dart
Duration: 300ms
Curve: Curves.easeInOut
Type: Slide from right (for forward navigation)
```

#### Button Press
```dart
Scale: 0.95
Duration: 100ms
Curve: Curves.easeInOut
```

#### Card Tap
```dart
Opacity: 0.7
Duration: 150ms
```

#### Pull to Refresh
```dart
Color: primaryGreen
Stroke Width: 3
```

---

### 11. Responsive Behavior

#### Small Screens (<360px width)
- Reduce font sizes by 10%
- Reduce padding to 12px
- Stack summary cards vertically

#### Large Screens (>600px width)
- Max content width: 600px
- Center content
- Increase padding to 24px

---

### 12. Dark Mode (Future Phase)

**Not implemented in MVP, but prepared colors:**
```dart
// Dark Mode Colors (for future)
darkBackground: Color(0xFF1F2937)
darkCardBackground: Color(0xFF374151)
darkTextPrimary: Color(0xFFF9FAFB)
darkTextSecondary: Color(0xFFD1D5DB)
```

---

### 13. Accessibility

#### Minimum Touch Targets
```
Buttons: 48x48px minimum
Icons: 44x44px minimum tap area
List items: 56px minimum height
```

#### Text Contrast Ratios
```
Primary text on white: 14:1 (Exceeds WCAG AAA)
Secondary text on white: 7:1 (Exceeds WCAG AA)
Green on white: 4.5:1 (Meets WCAG AA)
```

---

### 14. Design Assets Checklist

- [ ] App icon (1024x1024px)
- [ ] Splash screen logo
- [ ] Empty state illustrations
- [ ] Error state illustrations
- [ ] Category icons (if not using emojis)

---

### 15. Design Review Checklist

Before considering design complete:
- [ ] All spacing uses 4px multiples
- [ ] All text uses defined typography styles
- [ ] All colors from color palette
- [ ] Touch targets meet 44px minimum
- [ ] Text contrast ratios meet WCAG AA
- [ ] Consistent border radius throughout
- [ ] Card shadows are subtle and consistent
- [ ] Screens work on 360px and 400px widths