# 😗 HerPeso

**Your Friendly Peso Tracker** — A Philippine-focused personal finance PWA that combines expense tracking with AI-powered financial coaching.

---

## 📱 Overview

HerPeso is designed specifically for Filipino users who want to take control of their spending. Built as a Progressive Web App (PWA) using Flutter, it works seamlessly on mobile and desktop browsers with offline support.

The app features a unique **bi-weekly budget system** aligned with typical Filipino salary schedules (1st-15th and 16th-end of month), making it intuitive for users to track their spending between paydays.

---

## ✨ Key Features

### 💰 Expense Tracking
- **Manual Entry** — Quickly log expenses with amount, merchant, category, and notes
- **Receipt Scanning** — Take a photo or upload a receipt image, and AI automatically extracts the total amount
- **8 Pre-built Categories** — Food & Dining, Transportation, Shopping, Bills & Utilities, Entertainment, Healthcare, Personal Care, and Others
- **Custom Categories** — Create your own categories for personalized tracking

### 🎯 Budget Goals
- Set spending limits for different periods:
  - **Daily** — Daily spending cap
  - **Weekly** — 7-day budget
  - **Bi-Weekly** ⭐ — Aligned with Philippine salary cutoffs (recommended)
  - **Monthly** — Full month budget
- Visual progress tracking with color-coded status indicators
- Remaining budget and days countdown

### 🤖 AI-Powered Insights
- **Quick Insights** — Daily AI-generated tips on your dashboard
- **Deep Analysis** — Select any date range and get a detailed spending narrative
- **Taglish Support** — AI responses in natural Filipino-English mix
- **Category Breakdown** — Visual charts showing where your money goes
- **Personalized Suggestions** — Actionable tips based on your spending patterns

### 📊 Dashboard
- At-a-glance view of total spending for current period
- Budget progress bar with status (On Track 🎉 / Caution ⚠️ / Over Budget 🚨)
- Recent transactions list
- Quick action buttons for common tasks

### 📜 Transaction History
- Browse all expenses grouped by date
- Search by merchant or category
- Filter by category
- Swipe to delete
- Tap to view/edit details

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.2+
- **State Management:** Provider
- **Local Storage:** Hive (offline-first)
- **AI Integration:** Google Gemini API
- **Platform:** PWA (Web, installable on mobile)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.2 or higher
- A Google Gemini API key

### Installation

1. **Clone/Extract the project**
   ```bash
   cd pesopal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your Gemini API key**
   
   Open `lib/config/api_config.dart` and replace:
   ```dart
   static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
   ```

4. **Run the app**
   ```bash
   flutter run -d chrome
   ```

### Building for Production

```bash
flutter build web --release
```

The built files will be in `build/web/` — deploy to any static hosting service.

---

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # MaterialApp configuration
├── config/                   # API keys and app settings
├── core/
│   ├── constants/            # Colors, typography, spacing
│   ├── enums/                # Category, period, budget status
│   ├── theme/                # App theme
│   └── utils/                # Formatters, validators, helpers
├── data/
│   ├── models/               # Expense, Goal, Category models
│   ├── repositories/         # Data access layer
│   └── local/                # Hive database setup
├── services/                 # Gemini AI, receipt scanner, connectivity
├── providers/                # State management
├── navigation/               # Routes and navigation
├── shared/                   # Reusable widgets and dialogs
└── features/
    ├── dashboard/            # Home screen
    ├── expense_entry/        # Manual expense form
    ├── receipt_upload/       # Receipt scanning flow
    ├── ai_insights/          # AI analysis screens
    ├── goals/                # Budget goal management
    └── transactions/         # History and details
```

---

## 🎨 Design Highlights

- **Lavender primary theme** with coral accents
- **Friendly UI** with emojis and encouraging messages
- **Gradient cards** for visual hierarchy
- **Smooth animations** for delightful interactions
- **Mobile-first** responsive design

---

## 📋 Currency & Date Formats

- **Currency:** Philippine Peso (₱) with 2 decimal places
- **Date Format:** MMMM DD, YYYY (e.g., January 26, 2026)
- **Time Format:** 12-hour with AM/PM

---

## 🔒 Privacy

- All data is stored locally on your device using Hive
- Receipt images are processed via Gemini API but not stored on servers
- No account or sign-up required

---

## 📄 License

MIT License — Feel free to use, modify, and distribute.

---

**Made with 💜 for Filipino budget-conscious individuals**