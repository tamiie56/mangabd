# MangaBD — Flutter Manga Reading App

A manga reading and publishing platform built for Bangladeshi readers and creators.

## Download APK

Get the latest release from [Releases](https://github.com/tamiie56/mangabd/releases).

---

## Project Structure

```
mangabd/
├── mangabd_app/
│   ├── lib/
│   │   ├── main.dart                            # App entry point & auth wrapper
│   │   ├── models/
│   │   │   ├── manga_model.dart                 # Manga model
│   │   │   └── chapter_model.dart               # Chapter model
│   │   ├── services/
│   │   │   ├── auth/
│   │   │   │   └── auth_service.dart            # Firebase auth service
│   │   │   ├── firestore/
│   │   │   │   └── firestore_service.dart       # Firestore CRUD + queries
│   │   │   └── storage/
│   │   │       └── storage_service.dart         # Cloudinary upload service
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart            # Login screen
│   │   │   │   └── signup_screen.dart           # Signup screen
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart             # Home feed (For You + Following tabs)
│   │   │   │   └── manga_detail_screen.dart     # Manga detail + chapter list
│   │   │   ├── search/
│   │   │   │   └── search_screen.dart           # Search manga by title
│   │   │   ├── bookmarks/
│   │   │   │   └── bookmarks_screen.dart        # Saved bookmarks
│   │   │   ├── reader/
│   │   │   │   └── reader_screen.dart           # Chapter reader
│   │   │   ├── creator/
│   │   │   │   ├── creator_dashboard_screen.dart  # Creator manga management
│   │   │   │   ├── add_manga_screen.dart          # Upload new manga
│   │   │   │   ├── edit_manga_screen.dart         # Edit existing manga
│   │   │   │   └── add_chapter_screen.dart        # Upload new chapter
│   │   │   └── profile/
│   │   │       └── profile_screen.dart          # User profile + logout
│   │   ├── utils/
│   │   │   └── auth_provider.dart               # Auth state management
│   │   └── main_screen.dart                     # Bottom navigation controller
│   ├── assets/
│   │   └── logo/
│   │       └── mangabd_logo.png                 # App launcher icon
│   └── pubspec.yaml
├── android/
└── firestore_rules/
```

---

## Features

| Feature | Status |
| --- | --- |
| Email / Password Authentication | Done |
| Home Feed — For You tab | Done |
| Home Feed — Following tab | Done |
| Manga Detail Page | Done |
| Chapter Reader | Done |
| Search Manga by Title | Done |
| Bookmark Manga | Done |
| Follow / Unfollow Creators | Done |
| Follower Count | Done |
| Creator Dashboard | Done |
| Upload New Manga with Cover | Done |
| Upload Chapters with Pages | Done |
| Edit Manga | Done |
| Delete Manga | Done |
| User Profile Screen | Done |
| Dark Themed UI | Done |
| Android APK Build | Done |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter (Android) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Cloudinary |
| State Management | Provider |

---

## Setup Instructions

### Prerequisites

- Flutter SDK
- Firebase project (with Authentication and Firestore enabled)
- Cloudinary account

### 1. Clone the repo

```
git clone https://github.com/tamiie56/mangabd.git
cd mangabd/mangabd_app
```

### 2. Firebase setup

- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Enable Email/Password Authentication
- Enable Cloud Firestore
- Download `google-services.json` and place it in `android/app/`
- Run `flutterfire configure` to generate `lib/firebase_options.dart`

### 3. Firestore Security Rules

Go to Firestore > Rules and apply:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /mangas/{mangaId} {
      allow read: if true;
      allow write: if request.auth != null;

      match /chapters/{chapterId} {
        allow read: if true;
        allow write: if request.auth != null;
      }
    }

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /bookmarks/{bookmarkId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /following/{followingId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /followers/{followerId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

### 4. Flutter setup

```
flutter pub get
```

### 5. Run the app

```
flutter run
```

---

## Build APK

```
flutter build apk --release
```

APK will be at `build/app/outputs/flutter-apk/app-release.apk`

---

## Dependencies

| Package | Purpose |
| --- | --- |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | File storage (backup) |
| `provider` | State management |
| `image_picker` | Pick images from gallery |
| `http` | HTTP requests for Cloudinary |
| `flutter_launcher_icons` | Custom app launcher icon |
| `cupertino_icons` | iOS-style icons |

---

## About

MangaBD is built for Bangladeshi manga readers and creators. Readers can discover, bookmark, and follow their favourite creators. Creators can upload and manage their manga series directly from the app.

## Developer

Made by [tamiie56](https://github.com/tamiie56)
