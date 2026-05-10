<div align="center">

# 🕋 HaramainQu
### Umrah & Hajj Companion App — Built with Flutter

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-00B0FF?style=for-the-badge)
![REST API](https://img.shields.io/badge/REST-API-009688?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In_Development-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

> 🚧 **This project is currently under active development.** Features and UI are subject to change.

A comprehensive mobile companion app for Umrah & Hajj pilgrims, powered by the Haramain Tour backend.

</div>

---

## 📌 About

**HaramainQu** is a mobile application designed to accompany pilgrims throughout their Umrah and Hajj journey in the Holy Land. It provides step-by-step ibadah guidance, progress tracking, doa collections, and practical tools — all in one app.

HaramainQu connects to the **[Haramain Tour](https://github.com/JunichiGetCode/haramain-tour)** Laravel backend via REST API, authenticated using token-based auth with Laravel Sanctum.

---

## ✨ Features

| Module | Description |
|---|---|
| 🔐 **Auth** | Login, logout, and splash screen session management |
| 🏠 **Home** | Main dashboard with pilgrimage summary and info |
| 📖 **Panduan Ibadah** | Step-by-step Umrah & Hajj ritual instructions |
| ✅ **Progress Ibadah** | Checklist to track completed rukun of Umrah/Hajj |
| 🔢 **Tracking Ibadah** | Counter to track Thawaf, Sa'i rounds, and other rituals |
| 🤲 **Doa & Dzikir** | Collection of essential prayers and daily dhikr |
| 📖 **Kamus Arab** | Mini Arabic dictionary for practical pilgrim communication |
| ⏰ **Reminder** | Notifications for ibadah schedules and trip agenda |
| 👤 **Profile** | Pilgrim profile management and account settings |
| 📰 **Berita** | Latest news and updates from Haramain Tour |

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter |
| **State Management** | flutter_riverpod |
| **Navigation** | go_router (with deep linking support) |
| **HTTP Client** | dio (with token interceptor) |
| **Local Storage** | shared_preferences + Hive (NoSQL local DB) |
| **Fonts** | google_fonts |
| **Animations** | lottie, flutter_animate, shimmer |
| **Backend** | Haramain Tour (Laravel 11 + REST API) |

---

## 🏗️ Architecture

This project follows a **Feature-First Clean Architecture** approach, separating code by feature for scalability and maintainability.

```
lib/
├── core/                   # Global utilities & services
│   ├── api_service.dart    # Dio HTTP client with auth interceptor
│   ├── theme/              # App theme & design tokens
│   ├── constants/          # App-wide constants
│   └── services/           # Notification & storage services
│
├── features/               # Feature modules (UI + Business Logic)
│   ├── auth/               # Login, logout, splash screen
│   ├── home/               # Main dashboard
│   ├── panduan_ibadah/     # Ibadah step-by-step guide
│   ├── progress_ibadah/    # Rukun checklist tracker
│   ├── tracking_ibadah/    # Thawaf/Sa'i counter
│   ├── doa_dzikir/         # Prayers & dhikr collection
│   ├── kamus_arab/         # Arabic dictionary
│   ├── reminder/           # Schedule reminders
│   └── profile/            # User profile & settings
│
└── data/                   # Data models & sources
    ├── models/             # Data models
    └── repositories/       # Local & remote data sources
```

---

## 🔗 System Architecture

```
HaramainQu (Flutter Mobile App)
          ↓  REST API (Dio + Token Interceptor)
 Haramain Tour (Laravel 11 Backend)
          ↓  Query
      MySQL Database
```

> Authentication is handled via **Laravel Sanctum** token-based auth. The token is stored locally using `shared_preferences` and automatically attached to every API request via a Dio interceptor.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.x
- Dart >= 3.x
- Android Studio / VS Code
- Android Emulator or physical device

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/JunichiGetCode/haramainqu.git
cd haramainqu

# 2. Install dependencies
flutter pub get

# 3. Configure API base URL
# Open lib/core/constants/ and set your Haramain Tour backend URL

# 4. Run the app
flutter run
```

---

## 📸 Screenshots

> 🚧 This app is currently under active development. Screenshots will be added upon release.

---

## 🔗 Related Repository

This app is the mobile frontend for the **Haramain Tour** web platform.

👉 [Haramain Tour — Laravel Backend](https://github.com/JunichiGetCode/haramain-tour)

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  Built with ❤️ using Flutter — لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ
</div>
