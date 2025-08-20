import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en')
  ];

  /// Le titre de l'application
  ///
  /// In fr, this message translates to:
  /// **'Compagnon du Coran'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In fr, this message translates to:
  /// **'Coran'**
  String get quran;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @bookmarks.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get bookmarks;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @dailyVerse.
  ///
  /// In fr, this message translates to:
  /// **'Verset du jour'**
  String get dailyVerse;

  /// No description provided for @surahs.
  ///
  /// In fr, this message translates to:
  /// **'Sourates'**
  String get surahs;

  /// No description provided for @juz.
  ///
  /// In fr, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @page.
  ///
  /// In fr, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @verse.
  ///
  /// In fr, this message translates to:
  /// **'Verset'**
  String get verse;

  /// No description provided for @translation.
  ///
  /// In fr, this message translates to:
  /// **'Traduction'**
  String get translation;

  /// No description provided for @tafsir.
  ///
  /// In fr, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @audio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @reciter.
  ///
  /// In fr, this message translates to:
  /// **'Récitateur'**
  String get reciter;

  /// No description provided for @play.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt'**
  String get stop;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @downloaded.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé'**
  String get downloaded;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la note'**
  String get editNote;

  /// No description provided for @deleteNote.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la note'**
  String get deleteNote;

  /// No description provided for @bookmark.
  ///
  /// In fr, this message translates to:
  /// **'Marquer'**
  String get bookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le marque-page'**
  String get removeBookmark;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème système'**
  String get systemTheme;

  /// No description provided for @fontSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille de police'**
  String get fontSize;

  /// No description provided for @arabicFontSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille de police arabe'**
  String get arabicFontSize;

  /// No description provided for @translationFontSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille de police de traduction'**
  String get translationFontSize;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dailyReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get dailyReminder;

  /// No description provided for @prayerTimes.
  ///
  /// In fr, this message translates to:
  /// **'Heures de prière'**
  String get prayerTimes;

  /// No description provided for @qibla.
  ///
  /// In fr, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @mosques.
  ///
  /// In fr, this message translates to:
  /// **'Mosquées'**
  String get mosques;

  /// No description provided for @nearbyMosques.
  ///
  /// In fr, this message translates to:
  /// **'Mosquées à proximité'**
  String get nearbyMosques;

  /// No description provided for @findMosques.
  ///
  /// In fr, this message translates to:
  /// **'Trouver des mosquées'**
  String get findMosques;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @apiKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé API'**
  String get apiKey;

  /// No description provided for @enterApiKey.
  ///
  /// In fr, this message translates to:
  /// **'Entrer la clé API Geoapify'**
  String get enterApiKey;

  /// No description provided for @apiKeyRequired.
  ///
  /// In fr, this message translates to:
  /// **'Clé API requise pour trouver des mosquées'**
  String get apiKeyRequired;

  /// No description provided for @noInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet'**
  String get noInternet;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @searchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans le Coran...'**
  String get searchPlaceholder;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get noResults;

  /// No description provided for @aboutApp.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In fr, this message translates to:
  /// **'Développeur'**
  String get developer;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @shareVerse.
  ///
  /// In fr, this message translates to:
  /// **'Partager le verset'**
  String get shareVerse;

  /// No description provided for @copyVerse.
  ///
  /// In fr, this message translates to:
  /// **'Copier le verset'**
  String get copyVerse;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get copied;

  /// No description provided for @quiz.
  ///
  /// In fr, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @startQuiz.
  ///
  /// In fr, this message translates to:
  /// **'Commencer le quiz'**
  String get startQuiz;

  /// No description provided for @nextQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Question suivante'**
  String get nextQuestion;

  /// No description provided for @score.
  ///
  /// In fr, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correct.
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In fr, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @downloadOfflineData.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les données hors ligne'**
  String get downloadOfflineData;

  /// No description provided for @offlineDataReady.
  ///
  /// In fr, this message translates to:
  /// **'Données hors ligne prêtes'**
  String get offlineDataReady;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Permission de localisation requise'**
  String get locationPermissionRequired;

  /// No description provided for @enableLocation.
  ///
  /// In fr, this message translates to:
  /// **'Activer la localisation'**
  String get enableLocation;

  /// No description provided for @fajr.
  ///
  /// In fr, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In fr, this message translates to:
  /// **'Lever du soleil'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In fr, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In fr, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In fr, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In fr, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @readingMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode lecture'**
  String get readingMode;

  /// No description provided for @nightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode nuit'**
  String get nightMode;

  /// No description provided for @pageMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode page'**
  String get pageMode;

  /// No description provided for @verseMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode verset'**
  String get verseMode;

  /// No description provided for @continuousMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode continu'**
  String get continuousMode;

  /// No description provided for @makkah.
  ///
  /// In fr, this message translates to:
  /// **'Mecquois'**
  String get makkah;

  /// No description provided for @madinah.
  ///
  /// In fr, this message translates to:
  /// **'Médinois'**
  String get madinah;

  /// No description provided for @verses.
  ///
  /// In fr, this message translates to:
  /// **'versets'**
  String get verses;

  /// No description provided for @revelation.
  ///
  /// In fr, this message translates to:
  /// **'Révélation'**
  String get revelation;

  /// No description provided for @bismillah.
  ///
  /// In fr, this message translates to:
  /// **'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux'**
  String get bismillah;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
