# BMI Tracker - Assignment Submission

A comprehensive, production-ready BMI tracking application built with Flutter, featuring secure authentication, relational local persistence, and multi-user support.

## Key Features

- **Advanced Authentication**: Secure sign-in via Email/Password and Google using Firebase Auth.
- **State-Driven Onboarding**: Intelligent routing that identifies new users and guides them through profile creation.
- **Relational Persistence**: Powered by **Drift (SQLite)** for type-safe, reactive data storage with foreign key constraints and cascade deletes.
- **Real-time BMI Calculation**: Precise calculation logic using modern Dart 3 switch expressions, with classification for Underweight, Normal, Overweight, and Obese categories.
- **Multi-User Profiles**: Netflix-style profile management allowing multiple family members to track data independently on one device.
- **Weight Intelligence**: 
    - **One Entry Per Day**: Logic to prevent duplicate logs by automatically overwriting entries on the same date.
    - **Interactive History**: 7-day trend visualization using `fl_chart` with high-contrast tooltips.
- **Modern UX Components**:
    - **Numeric Step Input**: Custom widget with **+** and **-** buttons for quick 0.1 unit adjustments.
    - **Reactive UI**: Immediate interface updates across the entire app when logging weight or switching profiles.
    - **User Feedback**: Confirmation SnackBars for all data persistence actions.

## Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (latest stable)
- **State Management**: [Riverpod 3.0](https://riverpod.dev) (using `AsyncNotifier` and `Notifier` patterns)
- **Local Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth) & [Google Sign-In](https://pub.dev/packages/google_sign_in)
- **Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Architecture**: Domain-Driven Design (DDD) inspired structure with clear separation between Models, Services, Providers, and UI.

## Project Structure

```text
lib/
├── core/           # App theme, colors, validators, and BMI logic
├── models/         # Clean domain data classes
├── providers/      # Reactive state management (Riverpod)
├── screens/        # Feature-specific UI screens
├── services/       # Auth, SQLite Database (Drift), and Repositories
└── widgets/        # Reusable components (Charts, Step Inputs, Gauges)
```

## Setup & Running the App

### Prerequisites

- Flutter SDK (3.24.x or later)
- Android Studio / VS Code
- A Firebase project with Google Sign-in enabled

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd bmi_calc
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Database Code**:
   This project leverages Drift's powerful code generation for SQL safety. Run:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration**:
   - Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the correct platform folders.
   - The app uses the `DefaultFirebaseOptions` pattern.

5. **Execute the Application**:
   ```bash
   flutter run
   ```
