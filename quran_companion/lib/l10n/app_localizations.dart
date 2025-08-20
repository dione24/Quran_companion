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

  /// No description provided for @showTranslation.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la traduction'**
  String get showTranslation;

  /// No description provided for @showTafsir.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le tafsir'**
  String get showTafsir;

  /// No description provided for @surah.
  ///
  /// In fr, this message translates to:
  /// **'Sourate'**
  String get surah;

  /// No description provided for @ayah.
  ///
  /// In fr, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @quiz.
  ///
  /// In fr, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @memorization.
  ///
  /// In fr, this message translates to:
  /// **'Mémorisation'**
  String get memorization;

  /// No description provided for @progress.
  ///
  /// In fr, this message translates to:
  /// **'Progrès'**
  String get progress;

  /// No description provided for @statistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistics;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

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

  /// No description provided for @contact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get copied;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get loading;

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

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

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

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previous;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @continueText.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueText;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @select.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get deselectAll;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sort;

  /// No description provided for @sortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get sortBy;

  /// No description provided for @ascending.
  ///
  /// In fr, this message translates to:
  /// **'Croissant'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In fr, this message translates to:
  /// **'Décroissant'**
  String get descending;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @size.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get size;

  /// No description provided for @type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @enabled.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get disabled;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// No description provided for @connected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get disconnected;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get unavailable;

  /// No description provided for @visible.
  ///
  /// In fr, this message translates to:
  /// **'Visible'**
  String get visible;

  /// No description provided for @hidden.
  ///
  /// In fr, this message translates to:
  /// **'Masqué'**
  String get hidden;

  /// No description provided for @public.
  ///
  /// In fr, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @private.
  ///
  /// In fr, this message translates to:
  /// **'Privé'**
  String get private;

  /// No description provided for @read.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get read;

  /// No description provided for @write.
  ///
  /// In fr, this message translates to:
  /// **'Écrire'**
  String get write;

  /// No description provided for @execute.
  ///
  /// In fr, this message translates to:
  /// **'Exécuter'**
  String get execute;

  /// No description provided for @permission.
  ///
  /// In fr, this message translates to:
  /// **'Permission'**
  String get permission;

  /// No description provided for @permissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @access.
  ///
  /// In fr, this message translates to:
  /// **'Accès'**
  String get access;

  /// No description provided for @denied.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get denied;

  /// No description provided for @granted.
  ///
  /// In fr, this message translates to:
  /// **'Accordé'**
  String get granted;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In fr, this message translates to:
  /// **'Approuvé'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In fr, this message translates to:
  /// **'Échoué'**
  String get failed;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @debug.
  ///
  /// In fr, this message translates to:
  /// **'Débogage'**
  String get debug;

  /// No description provided for @trace.
  ///
  /// In fr, this message translates to:
  /// **'Trace'**
  String get trace;

  /// No description provided for @log.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get log;

  /// No description provided for @logs.
  ///
  /// In fr, this message translates to:
  /// **'Journaux'**
  String get logs;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @recent.
  ///
  /// In fr, this message translates to:
  /// **'Récent'**
  String get recent;

  /// No description provided for @favorite.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get favorite;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @popular.
  ///
  /// In fr, this message translates to:
  /// **'Populaire'**
  String get popular;

  /// No description provided for @trending.
  ///
  /// In fr, this message translates to:
  /// **'Tendance'**
  String get trending;

  /// No description provided for @newItem.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get newItem;

  /// No description provided for @updated.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour'**
  String get updated;

  /// No description provided for @created.
  ///
  /// In fr, this message translates to:
  /// **'Créé'**
  String get created;

  /// No description provided for @modified.
  ///
  /// In fr, this message translates to:
  /// **'Modifié'**
  String get modified;

  /// No description provided for @deleted.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé'**
  String get deleted;

  /// No description provided for @restored.
  ///
  /// In fr, this message translates to:
  /// **'Restauré'**
  String get restored;

  /// No description provided for @archived.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get archived;

  /// No description provided for @unarchived.
  ///
  /// In fr, this message translates to:
  /// **'Désarchivé'**
  String get unarchived;

  /// No description provided for @published.
  ///
  /// In fr, this message translates to:
  /// **'Publié'**
  String get published;

  /// No description provided for @unpublished.
  ///
  /// In fr, this message translates to:
  /// **'Non publié'**
  String get unpublished;

  /// No description provided for @draft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get draft;

  /// No description provided for @finalItem.
  ///
  /// In fr, this message translates to:
  /// **'Final'**
  String get finalItem;

  /// No description provided for @temporary.
  ///
  /// In fr, this message translates to:
  /// **'Temporaire'**
  String get temporary;

  /// No description provided for @permanent.
  ///
  /// In fr, this message translates to:
  /// **'Permanent'**
  String get permanent;

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

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

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
