# Quran Companion 📖

A comprehensive Quran reader and study tool for iOS, Android, Apple Watch, and Wear OS devices.

## Features

### Core Features
- **Quran Reader**: Arabic text with translations, navigation, font adjustment, night mode
- **Audio Playback**: Multiple reciters with offline download support
- **Search**: Full-text search with fuzzy matching
- **Bookmarks & Notes**: Save and organize your favorite verses
- **Prayer Times**: Accurate prayer times based on location
- **Qibla Compass**: Find the direction to Mecca
- **Mosque Finder**: Locate nearby mosques using Geoapify

### New Features (v2.0)
- **Tajweed Rules Highlighting**: Color-coded Tajweed rules in Arabic text
- **Verse-by-Verse Translation Sync**: Real-time synchronization with audio playback
- **Social Sharing**: Share verses and progress on social media
- **Multiple Tafsir Sources**: Ibn Kathir, Jalalayn, Maariful Quran
- **Memorization Tools**: Spaced repetition, progress tracking, mastery levels
- **Enhanced Quiz**: Multiple categories, timed mode, score tracking
- **Offline Audio Downloads**: Download recitations for offline use
- **Daily Verse Widget**: Home screen widget for iOS and Android
- **Watch Apps**: Companion apps for Apple Watch and Wear OS

## Getting Started

### Prerequisites

1. Flutter SDK 3.x
2. Dart SDK 3.x
3. Android Studio / Xcode
4. Geoapify API Key (for mosque finder)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/quran-companion.git
cd quran-companion
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Geoapify:
   - Sign up at https://myprojects.geoapify.com/
   - Get your API key
   - Add to your environment variables or configuration file

### Build Instructions

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```
Then open the project in Xcode and archive for distribution.

#### Wear OS
1. Ensure Wear OS dependencies are configured in `android/app/build.gradle`
2. Build the Wear OS variant:
```bash
flutter build apk --release --flavor wear
```

#### Apple Watch
1. Open the iOS project in Xcode
2. Add the Watch App target if not already present
3. Build and archive both the iOS app and Watch app together

### Widget Setup

#### Android Widget
The widget is automatically included in the Android build. Users can add it from their home screen widget menu.

#### iOS Widget
1. Add the widget extension in Xcode
2. Configure the app group for data sharing
3. Build and include with the main app

## Configuration

### Localization
The app supports French (default) and English. To add more languages:
1. Add new `.arb` files in `lib/l10n/`
2. Update supported locales in `main.dart`

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to customize colors and styles.

### Audio Sources
Configure audio sources in `lib/core/services/download_service.dart`

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## Deployment

### Google Play Store
1. Build the app bundle
2. Upload to Google Play Console
3. Configure store listing and content rating
4. Submit for review

### Apple App Store
1. Archive the app in Xcode
2. Upload to App Store Connect
3. Configure app information and screenshots
4. Submit for review

## Permissions

The app requires the following permissions:
- **Internet**: For downloading content and API calls
- **Storage**: For offline content and downloads
- **Location**: For prayer times and Qibla direction
- **Notifications**: For prayer reminders and memorization reviews

## Architecture

The app follows a clean architecture pattern with:
- **Presentation Layer**: Flutter widgets and screens
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Services, repositories, and data sources
- **State Management**: Riverpod for reactive state management

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: support@qurancompanion.app

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Quran text and translations from authenticated sources
- Audio recitations from QuranicAudio.com
- Prayer time calculations using Adhan library
- Icons and design inspired by Material Design 3

## Version History

### v2.0.0 (Current)
- Added Tajweed highlighting
- Implemented memorization tools
- Enhanced quiz system
- Added social sharing
- Introduced watch app support
- Implemented offline audio downloads
- Added home screen widget

### v1.0.0
- Initial release with core features
- Basic Quran reader and audio playback
- Prayer times and Qibla compass
- Search and bookmarks

---

Made with ❤️ for Muslims worldwide