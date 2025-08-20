# Quran Companion 📖

A comprehensive Quran reader and study tool built with Flutter for iOS and Android.

## Features ✨

### Core Features
- **Complete Quran Text**: Full Arabic text with verse-by-verse navigation
- **Multiple Translations**: French (default), English, and Urdu translations
- **Audio Recitation**: Stream recitations from multiple renowned reciters
- **Search**: Full-text search across surahs and verses with fuzzy matching
- **Bookmarks & Notes**: Save favorite verses and add personal notes
- **Offline Support**: Download Quran data for offline reading

### Islamic Tools
- **Prayer Times**: Accurate prayer time calculations based on location
- **Qibla Compass**: Find the direction to Mecca using device sensors
- **Mosque Finder**: Locate nearby mosques with map view and directions
- **Daily Verse**: Get inspired with a verse of the day

### Customization
- **Themes**: Light, dark, and system theme support
- **Languages**: French (default) and English UI languages
- **Font Sizes**: Adjustable Arabic and translation text sizes
- **Night Mode**: Eye-friendly reading in low light

## Getting Started 🚀

### Prerequisites

1. **Flutter SDK**: Version 3.0.0 or higher
   ```bash
   flutter --version
   ```

2. **Dart SDK**: Version 3.0.0 or higher (included with Flutter)

3. **Development Environment**:
   - Android Studio / Xcode for mobile development
   - VS Code or IntelliJ IDEA with Flutter plugins

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/quran_companion.git
   cd quran_companion
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate localization files**:
   ```bash
   flutter gen-l10n
   ```

4. **Run the app**:
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

### API Keys Setup

#### Geoapify API Key (for Mosque Finder)

The mosque finder feature requires a free Geoapify API key:

1. Visit [Geoapify](https://myprojects.geoapify.com/)
2. Sign up for a free account
3. Create a new project
4. Copy your API key
5. In the app, go to Settings > API > Enter your key

**Free tier includes**:
- 3,000 requests per day
- No credit card required

## Building for Production 📱

### Android APK

```bash
# Build APK for release
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Archive

```bash
# Build for iOS (requires Mac with Xcode)
flutter build ios --release

# Open in Xcode to archive
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Distribute App → App Store Connect

## Project Structure 📁

```
quran_companion/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   │   ├── surah.dart
│   │   ├── verse.dart
│   │   ├── bookmark.dart
│   │   ├── reciter.dart
│   │   └── mosque.dart
│   ├── services/              # API and local services
│   │   ├── quran_service.dart
│   │   ├── audio_service.dart
│   │   ├── mosque_service.dart
│   │   └── local_storage_service.dart
│   ├── providers/             # State management
│   │   ├── quran_provider.dart
│   │   ├── bookmark_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/               # App screens
│   │   ├── home_screen.dart
│   │   ├── quran_reader_screen.dart
│   │   ├── search_screen.dart
│   │   ├── bookmarks_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── prayer_times_screen.dart
│   │   ├── qibla_screen.dart
│   │   └── mosque_finder_screen.dart
│   ├── widgets/               # Reusable widgets
│   │   ├── verse_widget.dart
│   │   ├── surah_list_tile.dart
│   │   └── daily_verse_card.dart
│   └── l10n/                  # Localization files
│       ├── app_fr.arb         # French translations
│       └── app_en.arb         # English translations
├── test/                      # Unit tests
├── assets/                    # Assets (fonts, data)
└── pubspec.yaml              # Dependencies

```

## Dependencies 📦

### Core Dependencies
- **flutter**: UI framework
- **provider**: State management
- **http**: Network requests
- **intl**: Internationalization

### Storage
- **sqflite**: SQL database
- **hive**: NoSQL database
- **shared_preferences**: Key-value storage

### Islamic Features
- **adhan**: Prayer time calculations
- **flutter_qiblah**: Qibla compass
- **just_audio**: Audio playback

### Maps & Location
- **flutter_map**: OpenStreetMap integration
- **geolocator**: Device location
- **latlong2**: Coordinate calculations

### UI
- **google_fonts**: Typography
- **shimmer**: Loading animations

## Testing 🧪

Run tests with:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## Permissions 📋

The app requires the following permissions:

### Android (android/app/src/main/AndroidManifest.xml)
- `INTERNET`: For API calls and streaming audio
- `ACCESS_FINE_LOCATION`: For prayer times and mosque finder
- `ACCESS_COARSE_LOCATION`: For approximate location

### iOS (ios/Runner/Info.plist)
- `NSLocationWhenInUseUsageDescription`: Location for prayer times
- `NSLocationAlwaysUsageDescription`: Background location updates

## Contributing 🤝

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## Support 💬

For issues, questions, or suggestions:
- Open an issue on GitHub
- Email: support@qurancompanion.app

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments 🙏

- [Al Quran Cloud API](https://alquran.cloud/api) for Quran data
- [Geoapify](https://www.geoapify.com/) for mosque locations
- [Islamic Network](https://aladhan.com/) for prayer calculations
- All the reciters whose beautiful recitations are included

## Roadmap 🗺️

- [ ] Tajweed rules highlighting
- [ ] Verse-by-verse translation sync
- [ ] Social features (share progress)
- [ ] Multiple Tafsir sources
- [ ] Memorization tools
- [ ] Quiz improvements
- [ ] Offline audio downloads
- [ ] Widget for daily verse
- [ ] Apple Watch / Wear OS support

---

**Made with ❤️ for Muslims worldwide**