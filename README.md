# Nduthi - Motorbike Ride-Hailing App

Nduthi is a production-grade motorbike ride-hailing application built with Flutter, Firebase, and Riverpod. It features a dual-interface for both Riders (Passengers) and Drivers (Boda Boda operators).

## 🚀 Features

- **Authentication**: Secure Email/Password authentication via Firebase Auth.
- **Role Selection**: Persistent user roles (Rider/Driver) stored in Firestore.
- **Real-time Map**: Integrated Google Maps with real-time location tracking using Geolocator.
- **Reactive State**: Built with Riverpod for efficient and predictable state management.
- **Cloud Database**: User profiles and ride data persisted in Cloud Firestore.

## 🛠️ Architecture

The project follows a feature-first folder structure:
- `lib/core`: Reusable widgets, constants, and global utilities.
- `lib/features/auth`: Authentication logic, user data models, and profile persistence.
- `lib/features/home`: Main dashboards for both Riders and Drivers.
- `lib/features/ride`: Ride request and acceptance workflow (In Progress).

## 📦 Setup & Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/nduthi.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   This project requires Firebase. You must generate your own `firebase_options.dart` using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🔐 Security Note

The `.gitignore` is configured to exclude sensitive Firebase configuration files (`google-services.json`, `firebase_options.dart`, etc.). Ensure you configure these locally for your development environment.

---
Built with ❤️ for the Boda Boda community.
