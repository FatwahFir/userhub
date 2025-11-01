# UserHub

UserHub is a Flutter application that showcases authentication, profile management, and user listing features built with BLoC, GoRouter, Retrofit, and Hydrated storage.

## Prerequisites

- Flutter SDK (3.5 or newer) with the Flutter binary available on your `PATH`
- Dart SDK (bundled with Flutter)
- An Android/iOS emulator or a connected device
- Backend API reachable at the URL configured in `.env` (defaults to `http://localhost:8000/api/v1`)

## Environment Setup

1. Copy the example environment file and provide your backend settings:
   ```bash
   cp .env.example .env
   ```
   Update `API_BASE_URL` (and other variables if needed) inside `.env`.

2. Make sure the Flutter cache directory is writable. If you see permission errors when running commands, fix them with:
   ```bash
   sudo chown -R $(whoami) /Users/user/Development/flutter/bin/cache
   sudo chown -R $(whoami) /Users/user/.dart-tool
   ```

## Installing Dependencies

```bash
flutter pub get
```

## Generate Retrofit & JSON Files

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running the App

### On a Connected Device or Emulator

```bash
flutter run
```

### With a Specific Flavor / Target (Optional)

```bash
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

## Running Static Analysis

```bash
flutter analyze
dart format lib test
```

## Testing

```bash
flutter test
```

## Additional Notes

- The application persists authentication state using Hydrated BLoC. Delete the app or clear storage if you want to reset local auth data.
- Make sure the backend is running and allows connections from your device/emulator IP.
