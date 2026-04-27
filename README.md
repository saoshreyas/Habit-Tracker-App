# 🌱 Habit Tracker

A clean, modern habit tracking app built with **Flutter** and **Firebase** — helping you build streaks, stay consistent, and visualize your progress over time.



---

## ✨ Features

- ✅ **Daily Habit Tracking** — Check off habits each day and watch your streaks grow
- 🔥 **Streak Counter** — Tracks your current and longest streaks automatically
- 📊 **Progress View** — See your completion history in a calendar-style grid
- 📋 **History Log** — Full log of completed habits grouped by date
- 🎨 **Custom Habits** — Add habits with a name, emoji, and accent color
- 🔐 **Authentication** — Secure email/password login with Firebase Auth
- ☁️ **Cloud Sync** — All data stored in Firestore and synced in real time

---

## 🗂️ Screens

| Screen | Description |
|---|---|
| **Login / Register** | Sign up or log in with email and password |
| **Home** | Today's habits with completion status and streaks |
| **Add / Edit Habit** | Create or update a habit with emoji and color |
| **Habit Detail** | Full progress view with stats and completion grid |
| **History** | Chronological log of all completed habits |
| **Profile** | Account info, app stats, and logout |

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross-platform mobile UI framework |
| [Firebase Auth](https://firebase.google.com/docs/auth) | User authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Real-time NoSQL database |
| [Provider](https://pub.dev/packages/provider) | State management |
| [Intl](https://pub.dev/packages/intl) | Date formatting |

---

## 🗄️ Firestore Data Structure

```
users/
  {uid}/
    habits/
      {habitId}/
        name: string
        emoji: string
        color: int
        createdAt: timestamp
    completions/
      {dateString_habitId}/
        habitId: string
        date: string (YYYY-MM-DD)
        completedAt: timestamp
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- [Android Studio](https://developer.android.com/studio) with an emulator set up
- A [Firebase](https://console.firebase.google.com) project with Auth and Firestore enabled

### Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/saoshreyas/Habit-Tracker-App-.git
   cd Habit-Tracker-App-
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── habit.dart
│   ├── habit_stats.dart
│   └── completion_entry.dart
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart
│   ├── home_screen.dart
│   ├── add_edit_habit_screen.dart
│   ├── habit_detail_screen.dart
│   ├── history_screen.dart
│   ├── profile_screen.dart
│   └── main_navigation_screen.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/
│   └── auth_form_provider.dart
├── widgets/
│   ├── habit_card.dart
│   └── empty_state.dart
└── utils/
    └── date_helpers.dart
```

---


