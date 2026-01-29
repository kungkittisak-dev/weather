# Weather App Setup Guide

## Project Overview
A simple Flutter weather application using OpenWeatherMap API.
- **Bundle ID:** `com.weather.weatherApp`
- **Platforms:** iOS 13.0+, Android
- **No State Management** - Pure StatefulWidget implementation

## Initial Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. iOS Setup (First Time)
```bash
# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Build once to generate Flutter.framework
flutter build ios --simulator --debug --no-codesign
```

### 3. Fix VS Code Swift Indexing Errors

If you see errors like `'Flutter/Flutter.h' file not found` in VS Code:

**Option 1: Restart VS Code**
```bash
# Close VS Code and reopen
# Or press: Cmd + Shift + P → "Developer: Reload Window"
```

**Option 2: Build the project**
```bash
flutter build ios --simulator --debug --no-codesign
```

**Option 3: Open in Xcode** (Already done for you)
```bash
cd ios
open Runner.xcworkspace
# Wait for Xcode indexing to complete, then close Xcode
```

## Running the App

### iOS Simulator
```bash
flutter run
```

### Android Emulator
```bash
flutter run
```

### Using VS Code Debug
1. Open Debug panel (Cmd + Shift + D)
2. Select configuration:
   - "Debug - iOS Simulator"
   - "Debug - Android"
3. Press F5 or click "Start Debugging"

## Project Structure

```
lib/
├── main.dart                 # App entry point with error handling
├── models/
│   └── weather.dart          # Weather data model with validation
├── services/
│   └── weather_api.dart      # OpenWeatherMap API service
└── screens/
    └── weather_screen.dart   # Main weather UI screen

.vscode/
├── launch.json              # Debug configurations
├── settings.json            # Format on save enabled
└── tasks.json               # Build tasks
```

## Features

### Error Handling
✅ Full error handling with user-friendly messages
✅ Network error detection (no internet, timeout)
✅ API error handling (404, 401, 429, 5xx)
✅ Input validation
✅ Retry logic with smart detection

### API Configuration
- **Service:** OpenWeatherMap
- **API Key:** Pre-configured (replace if needed)
- **Endpoint:** `https://api.openweathermap.org/data/2.5/weather`
- **Units:** Metric (Celsius)

### UI Features
- City search with validation
- Loading states
- Error states with retry button
- Weather information display:
  - Temperature
  - Weather description
  - Feels like temperature
  - Humidity
  - Wind speed
  - Pressure

## Troubleshooting

### iOS Build Issues

**Problem:** Flutter.h not found
```bash
# Solution: Rebuild iOS
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --simulator --debug --no-codesign
```

**Problem:** CocoaPods version conflict
```bash
# Solution: Update CocoaPods
sudo gem install cocoapods
cd ios
pod repo update
pod install
```

### Android Build Issues

**Problem:** Gradle sync failed
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

## Development Tips

### Format on Save
Already enabled in `.vscode/settings.json`

### Hot Reload
- Press `r` in terminal while app is running
- Or save a file (Cmd + S) in VS Code

### Debug Mode
- All debug prints are enabled
- Error logs show in console
- Use `flutter logs` to see device logs

### API Key Configuration
To use your own API key:
1. Get a free key at https://openweathermap.org/api
2. Edit `lib/services/weather_api.dart`
3. Replace the `apiKey` constant

## VS Code Settings

### Enabled Features
- ✅ Format on save
- ✅ Fix imports on save
- ✅ 80 character ruler for Dart
- ✅ Debug configurations for iOS and Android

### Recommended Extensions
- Dart
- Flutter
- Flutter Widget Snippets

## Common Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build release
flutter build ios --release
flutter build apk --release

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Notes

- The app loads Bangkok weather by default
- SSL certificate validation is bypassed for development (iOS simulator)
- For production, ensure proper SSL certificate handling
- The API key included is for development only

## Support

For Flutter issues:
- https://docs.flutter.dev/
- https://api.flutter.dev/

For Weather API:
- https://openweathermap.org/api
