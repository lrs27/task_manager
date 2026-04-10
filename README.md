# TASK MANAGER

A Flutter + Firebase Task Manager application with real‑time Firestore syncing, nested subtasks, search filtering, and manual theme switching.

## Enhanced Features

### 1. Real‑Time Search / Filter Bar

#### What it does:

A search bar above the task list filters tasks instantly as the user types. The filtering is case‑insensitive and updates in real time without additional Firestore reads. This makes it easy to quickly locate tasks in long lists.

#### Why I chose it:

Search is a practical enhancement that improves usability and demonstrates dynamic UI updates, efficient state handling, and smooth integration with Firestore streams.

### 2. Manual Theme Toggle (Light ↔ Dark Mode)

#### What it does:

A theme toggle icon in the AppBar allows users to manually switch between light and dark mode. The app still respects ThemeMode.system on startup, but users can override it at any time.

#### Why I chose it:

Dark mode is a modern accessibility and comfort feature. Implementing a manual toggle shows understanding of global theming, state lifting, and Material 3 design principles.

## Setup Instructions

Follow these steps to run the project locally:

### 1. Install Flutter

Download the Flutter SDK and set up your environment:
https://docs.flutter.dev/get-started/install

### 2. Install dependencies

Run:

    flutter pub get

### 3. Configure Firebase

This project uses Firebase. Set it up using the FlutterFire CLI:

    dart pub global activate flutterfire_cli
    flutterfire configure

This generates the required firebase_options.dart file.

### 4. Enable Firestore

In the Firebase console:

- Create a Firestore database

- Set rules to allow authenticated or test access

- Enable offline persistence (optional but recommended)

### 5. Run the app

Open an emulator and copy the below code in the terminal:

    flutter run

## Known Limitations

No authentication — All tasks belong to a single shared Firestore collection.

No edit functionality — Tasks and subtasks can be added or deleted, but not renamed.

No priority or due‑date system — Tasks are simple text items without metadata.

No notifications — The app does not send reminders or alerts.

Theme preference is not saved — The theme resets when the app restarts.
