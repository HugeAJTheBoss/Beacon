# Beacon

Beacon is a Flutter + Firebase web/mobile app that helps students discover nearby STEM opportunities and helps organizations register and manage their listings.

This project was created for the 2026 Apps for Good challenge by Atharv Joshi, Ishan Kasam, Ashley Li, and Aashriya Das.

## Project Status (April 2026)

Beacon is actively developed and currently supports:

- Student onboarding and preference-based opportunity discovery
- Organization registration with approval-gated sign-in
- Organization dashboard UI for creating and managing listings
- Firebase-backed organization account storage and authentication

The app is currently optimized for web and Android development.

## Core User Flows

### 1) Student discovery flow

- Students open the app and select **Browse Events**
- First-time users complete onboarding (DOB, ZIP code, interests, and opportunity types)
- Preferences are persisted locally via `SharedPreferences`
- The student view filters opportunities by:
	- distance
	- age range
	- selected categories
	- selected opportunity type (Club, Event, Volunteering)
- Students can open event details and submit event reports (UI is implemented)

### 2) Organization onboarding flow

- Organizations register with email/password and profile information
- On registration, a Firestore `organizations/{uid}` record is created with `status: pending`
- Organization sign-in is blocked until status is `approved`
- Pending/unapproved accounts are signed out and shown an approval message

### 3) Organization dashboard flow

- Approved organizations can access a dashboard
- Dashboard supports add/edit/delete event interactions in the UI
- Current dashboard event list is local/demo data (not yet fully connected to Firestore)

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend services:** Firebase Auth, Cloud Firestore, Firebase Core
- **Web utilities:** `url_launcher`
- **Local persistence:** `shared_preferences`
- **Platforms configured in Firebase options:** Web, Android

## Current Architecture

### Authentication and organization records

- `lib/services/auth_service.dart`
	- Creates org auth accounts (`createUserWithEmailAndPassword`)
	- Writes org profile into Firestore with approval status
	- Enforces approval checks on login

### Student preferences

- `lib/preferences_service.dart`
	- Persists onboarding state and filter preferences
	- Calculates age from stored DOB

### UI screens

- `lib/main.dart`: app bootstrap and home/welcome screen
- `lib/student_screen.dart`: student filtering and event browsing
- `lib/org_signup_screen.dart`: organization registration flow
- `lib/signin_screen.dart`: organization sign-in flow
- `lib/org_dashboard_screen.dart`: organization dashboard management UI

## Prerequisites

Install the following tools before running Beacon:

- Flutter SDK (stable channel)
- Dart SDK (included with Flutter)
- A Firebase project (already configured in this repository for web/android)
- Chrome (for local web testing)
- Android Studio/emulator (optional, for Android testing)

## Local Development

From the project root:

```bash
flutter pub get
flutter run -d chrome
```

Useful commands:

```bash
flutter analyze
flutter test
flutter build web
```

## Firebase Notes

- Firebase options are generated in `lib/firebase_options.dart`
- Current Firebase setup includes **web** and **android**
- iOS/macOS/windows/linux Firebase configs are not yet generated in code, so those targets will throw `UnsupportedError` if used without reconfiguration

If you need additional platform support, regenerate Firebase options with FlutterFire CLI.

## Deployment (Web)

Build the web app:

```bash
flutter build web
```

Firebase project metadata exists in `firebase.json`. If Firebase Hosting is desired, initialize hosting and deploy from this project root.

## Team

- Atharv Joshi
- Ashley Li
- Ishan Kasam
- Aashriya Das