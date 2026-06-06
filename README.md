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
│   │   ├── main.dart
│   │   ├── models/
│   │   │   ├── manga_model.dart
│   │   │   ├── chapter_model.dart
│   │   │   ├── user_model.dart
│   │   │   └── chat_model.dart
│   │   ├── services/
│   │   │   ├── auth/
│   │   │   │   └── auth_service.dart
│   │   │   ├── firestore/
│   │   │   │   └── firestore_service.dart
│   │   │   └── storage/
│   │   │       └── storage_service.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── manga_detail_screen.dart
│   │   │   ├── search/
│   │   │   │   └── search_screen.dart
│   │   │   ├── bookmarks/
│   │   │   │   └── bookmarks_screen.dart
│   │   │   ├── reader/
│   │   │   │   └── reader_screen.dart
│   │   │   ├── chat/
│   │   │   │   ├── chat_list_screen.dart
│   │   │   │   └── chat_screen.dart
│   │   │   ├── creator/
│   │   │   │   ├── creator_dashboard_screen.dart
│   │   │   │   ├── add_manga_screen.dart
│   │   │   │   ├── edit_manga_screen.dart
│   │   │   │   └── add_chapter_screen.dart
│   │   │   └── profile/
│   │   │       ├── profile_screen.dart
│   │   │       ├── about_screen.dart
│   │   │       ├── notifications_screen.dart
│   │   │       └── privacy_policy_screen.dart
│   │   ├── utils/
│   │   │   ├── auth_provider.dart
│   │   │   └── theme_provider.dart
│   │   └── main_screen.dart
│   ├── assets/
│   │   └── logo/
│   │       └── mangabd_logo.png
│   └── pubspec.yaml
├── android/
└── firestore_rules/
```

---

## Features

| Feature | Status |
| --- | --- |
| Email / Password Authentication | ✅ Done |
| Home Feed — For You tab | ✅ Done |
| Home Feed — Following tab | ✅ Done |
| Manga Detail Page | ✅ Done |
| Chapter Reader | ✅ Done |
| Search Manga by Title | ✅ Done |
| Bookmark Manga | ✅ Done |
| Follow / Unfollow Creators | ✅ Done |
| Follower / Following Count | ✅ Done |
| Creator Dashboard | ✅ Done |
| Upload New Manga with Cover | ✅ Done |
| Upload Chapters with Pages | ✅ Done |
| Edit Manga | ✅ Done |
| Delete Manga (with bookmark cleanup) | ✅ Done |
| Profile Screen with Stats | ✅ Done |
| Reader Stats (chapters read, bookmarks) | ✅ Done |
| Creator Stats (total works, chapters uploaded) | ✅ Done |
| Edit Profile Username | ✅ Done |
| Profile Picture Upload | ✅ Done |
| Dark / Light Theme Toggle | ✅ Done |
| Real-time Chat (one-to-one messaging) | ✅ Done |
| Unread Message Badge | ✅ Done |
| About Screen | ✅ Done |
| Notifications Settings | ✅ Done |
| Privacy Policy Screen | ✅ Done |
| Android APK Build | ✅ Done |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Cloudinary |
| State Management | Provider |

---

## Setup Instructions

### Prerequisites

- Flutter SDK
- Firebase project (Authentication + Firestore enabled)
- Cloudinary account with an unsigned upload preset

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

### 3. Cloudinary setup

- Create a free account at [cloudinary.com](https://cloudinary.com)
- Go to Settings → Upload → Upload Presets
- Create an **unsigned** preset
- Update `lib/services/storage/storage_service.dart` with your cloud name and preset name

### 4. Firestore Security Rules

Go to Firestore → Rules and apply:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /mangas/{mangaId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /mangas/{mangaId}/chapters/{chapterId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /users/{userId}/bookmarks/{bookmarkId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /users/{userId}/following/{followId} {
      allow read, write: if request.auth != null;
    }

    match /users/{userId}/followers/{followerId} {
      allow read, write: if request.auth != null;
    }

    match /conversations/{conversationId} {
      allow read, write: if request.auth != null;
    }

    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Firestore Indexes

Go to Firestore → Indexes → Create index:

| Collection | Field 1 | Field 2 | Query Scope |
| --- | --- | --- | --- |
| `conversations` | `participantIds` (Arrays) | `lastMessageAt` (Descending) | Collection |

### 6. New User Firestore Document Fields

When a new user signs up, the following fields are automatically created in their Firestore document:

```
uid, email, displayName, photoUrl, isCreator, createdAt,
followersCount, followingCount, bookmarksCount, chaptersRead,
totalWorks, totalChaptersUploaded
```

> **Note:** If you have existing users created before v1.1.0, manually add the missing numeric fields (`followersCount`, `followingCount`, `bookmarksCount`, `chaptersRead`, `totalWorks`, `totalChaptersUploaded`) as `int64` with value `0` in Firestore Console.

> **Note (v1.2.0):** If a user exists in Firebase Auth but has no Firestore document, the app will now automatically create their Firestore document on login.

> **Note (v1.4.0):** Fixed a crash on Android where Firestore returned numeric fields as `double` instead of `int`.

### 7. Android SHA-1 Setup

```
cd android
.\gradlew signingReport
```

Copy the SHA1 value and add it in Firebase Console → Project Settings → Your Apps → Android app → Add fingerprint. Then download the updated `google-services.json` and replace it in `android/app/`.

### 8. Flutter setup

```
flutter pub get
```

### 9. Run the app

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
| `provider` | State management |
| `image_picker` | Pick images from gallery |
| `http` | HTTP requests for Cloudinary |
| `shared_preferences` | Local notification preferences |
| `url_launcher` | Open external links in browser |
| `flutter_launcher_icons` | Custom app launcher icon |
| `cupertino_icons` | iOS-style icons |

---

## Changelog

### v1.5.0
- Added real-time one-to-one chat system
- Added chat icon in HomeScreen AppBar replacing theme toggle
- Added unread message badge on chat icon
- Added ChatListScreen with conversation list and user search
- Added ChatScreen with message bubbles, timestamps and date labels
- Updated Firestore security rules for conversations and messages
- Added Firestore composite index for conversations query

### v1.4.0
- Fixed Android login crash caused by Firestore returning double instead of int
- Fixed Android authentication by adding SHA-1 fingerprint to Firebase
- Improved login error messages
- Added GitHub profile link in About screen

### v1.3.0
- Redesigned app with green (#00C853) theme
- New speech bubble style logo
- Added About, Notifications and Privacy Policy screens
- Fixed dark mode login/signup background

### v1.2.0
- Redesigned UI
- Fixed login failure for accounts missing a Firestore document
- Auto-creates Firestore document on login if missing

### v1.1.0
- Added profile picture upload
- Added reader and creator stats
- Added follower/following count
- Dark / Light theme toggle

### v1.0.0
- Initial release

---

## About

MangaBD is built for Bangladeshi manga readers and creators. Readers can discover, bookmark, and follow their favourite creators. Creators can upload and manage their manga series directly from the app.

## Developer

Made by [tamiie56](https://github.com/tamiie56)
