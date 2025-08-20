import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/l10n/intl_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _localizedStrings = jsonMap.map((key, value) {
      if (key.startsWith('@@')) {
        return MapEntry(key, value.toString());
      }
      return MapEntry(key, value.toString());
    });
    
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Convenience getters for common strings
  String get appTitle => _localizedStrings['appTitle'] ?? 'Quran Companion';
  String get home => _localizedStrings['home'] ?? 'Home';
  String get quranReader => _localizedStrings['quranReader'] ?? 'Quran Reader';
  String get search => _localizedStrings['search'] ?? 'Search';
  String get bookmarks => _localizedStrings['bookmarks'] ?? 'Bookmarks';
  String get settings => _localizedStrings['settings'] ?? 'Settings';
  String get dailyVerse => _localizedStrings['dailyVerse'] ?? 'Daily Verse';
  String get surahs => _localizedStrings['surahs'] ?? 'Surahs';
  String get juz => _localizedStrings['juz'] ?? 'Juz';
  String get page => _localizedStrings['page'] ?? 'Page';
  String get verse => _localizedStrings['verse'] ?? 'Verse';
  String get translation => _localizedStrings['translation'] ?? 'Translation';
  String get tafsir => _localizedStrings['tafsir'] ?? 'Tafsir';
  String get audio => _localizedStrings['audio'] ?? 'Audio';
  String get reciter => _localizedStrings['reciter'] ?? 'Reciter';
  String get playAudio => _localizedStrings['playAudio'] ?? 'Play Audio';
  String get pauseAudio => _localizedStrings['pauseAudio'] ?? 'Pause Audio';
  String get stopAudio => _localizedStrings['stopAudio'] ?? 'Stop Audio';
  String get nextVerse => _localizedStrings['nextVerse'] ?? 'Next Verse';
  String get previousVerse => _localizedStrings['previousVerse'] ?? 'Previous Verse';
  String get fontSize => _localizedStrings['fontSize'] ?? 'Font Size';
  String get nightMode => _localizedStrings['nightMode'] ?? 'Night Mode';
  String get dayMode => _localizedStrings['dayMode'] ?? 'Day Mode';
  String get language => _localizedStrings['language'] ?? 'Language';
  String get french => _localizedStrings['french'] ?? 'French';
  String get english => _localizedStrings['english'] ?? 'English';
  String get theme => _localizedStrings['theme'] ?? 'Theme';
  String get light => _localizedStrings['light'] ?? 'Light';
  String get dark => _localizedStrings['dark'] ?? 'Dark';
  String get system => _localizedStrings['system'] ?? 'System';
  String get notifications => _localizedStrings['notifications'] ?? 'Notifications';
  String get prayerTimes => _localizedStrings['prayerTimes'] ?? 'Prayer Times';
  String get qibla => _localizedStrings['qibla'] ?? 'Qibla';
  String get mosqueFinderTitle => _localizedStrings['mosqueFinderTitle'] ?? 'Nearby Mosques';
  String get quiz => _localizedStrings['quiz'] ?? 'Quiz';
  String get score => _localizedStrings['score'] ?? 'Score';
  String get highScore => _localizedStrings['highScore'] ?? 'High Score';
  String get startQuiz => _localizedStrings['startQuiz'] ?? 'Start Quiz';
  String get nextQuestion => _localizedStrings['nextQuestion'] ?? 'Next Question';
  String get submitAnswer => _localizedStrings['submitAnswer'] ?? 'Submit Answer';
  String get correctAnswer => _localizedStrings['correctAnswer'] ?? 'Correct Answer!';
  String get wrongAnswer => _localizedStrings['wrongAnswer'] ?? 'Wrong Answer';
  String get quizCompleted => _localizedStrings['quizCompleted'] ?? 'Quiz Completed!';
  String get yourScore => _localizedStrings['yourScore'] ?? 'Your Score';
  String get tryAgain => _localizedStrings['tryAgain'] ?? 'Try Again';
  String get share => _localizedStrings['share'] ?? 'Share';
  String get shareVerse => _localizedStrings['shareVerse'] ?? 'Share Verse';
  String get shareProgress => _localizedStrings['shareProgress'] ?? 'Share your progress';
  String get readingStreak => _localizedStrings['readingStreak'] ?? 'Reading Streak';
  String get tajweedRules => _localizedStrings['tajweedRules'] ?? 'Tajweed Rules';
  String get enableTajweed => _localizedStrings['enableTajweed'] ?? 'Enable Tajweed';
  String get disableTajweed => _localizedStrings['disableTajweed'] ?? 'Disable Tajweed';
  String get memorization => _localizedStrings['memorization'] ?? 'Memorization';
  String get startMemorizing => _localizedStrings['startMemorizing'] ?? 'Start Memorizing';
  String get hideText => _localizedStrings['hideText'] ?? 'Hide Text';
  String get showText => _localizedStrings['showText'] ?? 'Show Text';
  String get repeatVerse => _localizedStrings['repeatVerse'] ?? 'Repeat Verse';
  String get masteryLevel => _localizedStrings['masteryLevel'] ?? 'Mastery Level';
  String get beginner => _localizedStrings['beginner'] ?? 'Beginner';
  String get intermediate => _localizedStrings['intermediate'] ?? 'Intermediate';
  String get mastered => _localizedStrings['mastered'] ?? 'Mastered';
  String get spacedRepetition => _localizedStrings['spacedRepetition'] ?? 'Spaced Repetition';
  String get nextReview => _localizedStrings['nextReview'] ?? 'Next Review';
  String get memorizationProgress => _localizedStrings['memorizationProgress'] ?? 'Memorization Progress';
  String get versesMemorized => _localizedStrings['versesMemorized'] ?? 'Verses Memorized';
  String get downloadAudio => _localizedStrings['downloadAudio'] ?? 'Download Audio';
  String get downloadingSurah => _localizedStrings['downloadingSurah'] ?? 'Downloading Surah...';
  String get downloadComplete => _localizedStrings['downloadComplete'] ?? 'Download Complete';
  String get downloadFailed => _localizedStrings['downloadFailed'] ?? 'Download Failed';
  String get retryDownload => _localizedStrings['retryDownload'] ?? 'Retry Download';
  String get storageUsed => _localizedStrings['storageUsed'] ?? 'Storage Used';
  String get clearDownloads => _localizedStrings['clearDownloads'] ?? 'Clear Downloads';
  String get offlineMode => _localizedStrings['offlineMode'] ?? 'Offline Mode';
  String get onlineMode => _localizedStrings['onlineMode'] ?? 'Online Mode';
  String get error => _localizedStrings['error'] ?? 'Error';
  String get retry => _localizedStrings['retry'] ?? 'Retry';
  String get cancel => _localizedStrings['cancel'] ?? 'Cancel';
  String get confirm => _localizedStrings['confirm'] ?? 'Confirm';
  String get save => _localizedStrings['save'] ?? 'Save';
  String get delete => _localizedStrings['delete'] ?? 'Delete';
  String get edit => _localizedStrings['edit'] ?? 'Edit';
  String get add => _localizedStrings['add'] ?? 'Add';
  String get close => _localizedStrings['close'] ?? 'Close';
  String get back => _localizedStrings['back'] ?? 'Back';
  String get next => _localizedStrings['next'] ?? 'Next';
  String get previous => _localizedStrings['previous'] ?? 'Previous';
  String get loading => _localizedStrings['loading'] ?? 'Loading...';
  String get pleaseWait => _localizedStrings['pleaseWait'] ?? 'Please Wait';
  
  String daysStreak(int count) {
    final template = _localizedStrings['daysStreak'] ?? '{count} days streak';
    return template.replaceAll('{count}', count.toString());
  }
  
  String percentComplete(double percent) {
    final template = _localizedStrings['percentComplete'] ?? '{percent}% complete';
    return template.replaceAll('{percent}', percent.toStringAsFixed(1));
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}