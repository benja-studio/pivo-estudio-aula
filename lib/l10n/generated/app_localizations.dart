import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Aula'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu vida académica organizada, offline y sin fricción'**
  String get appTagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza tu carrera sin esfuerzo'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus parciales, temas a estudiar, notas y promedios en un solo lugar. 100% privado y offline.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingStudentInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos sobre tus estudios'**
  String get onboardingStudentInfoTitle;

  /// No description provided for @onboardingStudentInfoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Estos datos personalizarán tu experiencia y cálculos de materias.'**
  String get onboardingStudentInfoSubtitle;

  /// No description provided for @onboardingProfilePhotoTitle.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get onboardingProfilePhotoTitle;

  /// No description provided for @onboardingProfilePhotoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí una foto para reconocerte o usá tu avatar por defecto.'**
  String get onboardingProfilePhotoSubtitle;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus preferencias'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elegí tu escala de notas y ajustá cómo quieres que se vea Aula.'**
  String get onboardingPreferencesSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get fullNameLabel;

  /// No description provided for @fullNameError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu nombre'**
  String get fullNameError;

  /// No description provided for @careerLabel.
  ///
  /// In es, this message translates to:
  /// **'Carrera'**
  String get careerLabel;

  /// No description provided for @careerError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu carrera'**
  String get careerError;

  /// No description provided for @institutionLabel.
  ///
  /// In es, this message translates to:
  /// **'Instituto o Universidad'**
  String get institutionLabel;

  /// No description provided for @institutionError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu institución'**
  String get institutionError;

  /// No description provided for @academicLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'Año o nivel que cursas (ej. 3er año)'**
  String get academicLevelLabel;

  /// No description provided for @studentIdLabel.
  ///
  /// In es, this message translates to:
  /// **'Legajo o matrícula (opcional)'**
  String get studentIdLabel;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Email de contacto (opcional)'**
  String get emailLabel;

  /// No description provided for @currentPeriodLabel.
  ///
  /// In es, this message translates to:
  /// **'Período académico actual'**
  String get currentPeriodLabel;

  /// No description provided for @currentPeriodHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 1er cuatrimestre 2026'**
  String get currentPeriodHint;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @accentColorLabel.
  ///
  /// In es, this message translates to:
  /// **'Color de acento'**
  String get accentColorLabel;

  /// No description provided for @gradeScaleLabel.
  ///
  /// In es, this message translates to:
  /// **'Escala de notas'**
  String get gradeScaleLabel;

  /// No description provided for @passingGradeLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota mínima de aprobación'**
  String get passingGradeLabel;

  /// No description provided for @notificationsEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar recordatorios de exámenes'**
  String get notificationsEnable;

  /// No description provided for @buttonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get buttonContinue;

  /// No description provided for @buttonStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar en Aula'**
  String get buttonStart;

  /// No description provided for @buttonSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir por ahora'**
  String get buttonSkip;

  /// No description provided for @buttonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get buttonDelete;

  /// No description provided for @buttonUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get buttonUndo;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get navCalendar;

  /// No description provided for @navSubjects.
  ///
  /// In es, this message translates to:
  /// **'Materias'**
  String get navSubjects;

  /// No description provided for @navGrades.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get navGrades;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @homeUpcomingExams.
  ///
  /// In es, this message translates to:
  /// **'Próximas evaluaciones'**
  String get homeUpcomingExams;

  /// No description provided for @homeThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get homeThisWeek;

  /// No description provided for @homeOverdueExams.
  ///
  /// In es, this message translates to:
  /// **'Evaluaciones pendientes de nota'**
  String get homeOverdueExams;

  /// No description provided for @homeOverallAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio general'**
  String get homeOverallAverage;

  /// No description provided for @homePeriodProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso del período'**
  String get homePeriodProgress;

  /// No description provided for @homeDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{¡Es hoy!} =1{Falta 1 día} other{Faltan {days} días}}'**
  String homeDaysLeft(int days);

  /// No description provided for @subjectsTitle.
  ///
  /// In es, this message translates to:
  /// **'Materias'**
  String get subjectsTitle;

  /// No description provided for @subjectsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes materias agregadas'**
  String get subjectsEmpty;

  /// No description provided for @subjectsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva materia'**
  String get subjectsAdd;

  /// No description provided for @subjectStatusTaking.
  ///
  /// In es, this message translates to:
  /// **'Cursando'**
  String get subjectStatusTaking;

  /// No description provided for @subjectStatusRegular.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get subjectStatusRegular;

  /// No description provided for @subjectStatusPassed.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get subjectStatusPassed;

  /// No description provided for @subjectStatusFailed.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get subjectStatusFailed;

  /// No description provided for @subjectStatusRetaking.
  ///
  /// In es, this message translates to:
  /// **'Recursando'**
  String get subjectStatusRetaking;

  /// No description provided for @examsTitle.
  ///
  /// In es, this message translates to:
  /// **'Evaluaciones'**
  String get examsTitle;

  /// No description provided for @examsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay evaluaciones registradas'**
  String get examsEmpty;

  /// No description provided for @examsAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva evaluación'**
  String get examsAdd;

  /// No description provided for @examTypeMidterm.
  ///
  /// In es, this message translates to:
  /// **'Parcial'**
  String get examTypeMidterm;

  /// No description provided for @examTypeRetake.
  ///
  /// In es, this message translates to:
  /// **'Recuperatorio'**
  String get examTypeRetake;

  /// No description provided for @examTypeFinal.
  ///
  /// In es, this message translates to:
  /// **'Final'**
  String get examTypeFinal;

  /// No description provided for @examTypeAssignment.
  ///
  /// In es, this message translates to:
  /// **'Trabajo Práctico'**
  String get examTypeAssignment;

  /// No description provided for @examTypeQuiz.
  ///
  /// In es, this message translates to:
  /// **'Quiz / Control'**
  String get examTypeQuiz;

  /// No description provided for @examTypeOral.
  ///
  /// In es, this message translates to:
  /// **'Examen Oral'**
  String get examTypeOral;

  /// No description provided for @examStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get examStatusPending;

  /// No description provided for @examStatusTaken.
  ///
  /// In es, this message translates to:
  /// **'Rendido'**
  String get examStatusTaken;

  /// No description provided for @examStatusPassed.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get examStatusPassed;

  /// No description provided for @examStatusFailed.
  ///
  /// In es, this message translates to:
  /// **'Desaprobado'**
  String get examStatusFailed;

  /// No description provided for @examStatusAbsent.
  ///
  /// In es, this message translates to:
  /// **'Ausente'**
  String get examStatusAbsent;

  /// No description provided for @topicStatusNotStarted.
  ///
  /// In es, this message translates to:
  /// **'Sin empezar'**
  String get topicStatusNotStarted;

  /// No description provided for @topicStatusStudying.
  ///
  /// In es, this message translates to:
  /// **'Estudiando'**
  String get topicStatusStudying;

  /// No description provided for @topicStatusReviewed.
  ///
  /// In es, this message translates to:
  /// **'Repasado'**
  String get topicStatusReviewed;

  /// No description provided for @topicStatusMastered.
  ///
  /// In es, this message translates to:
  /// **'Dominado'**
  String get topicStatusMastered;

  /// No description provided for @gradesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas y Promedios'**
  String get gradesTitle;

  /// No description provided for @gradesAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio acumulado'**
  String get gradesAverage;

  /// No description provided for @gradesCalculator.
  ///
  /// In es, this message translates to:
  /// **'Calculadora ¿Qué nota necesito?'**
  String get gradesCalculator;

  /// No description provided for @gradesTargetAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio objetivo'**
  String get gradesTargetAverage;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar materias, exámenes, notas o temas...'**
  String get searchPlaceholder;

  /// No description provided for @searchNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get searchNoResults;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil del estudiante'**
  String get settingsProfile;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia y tema'**
  String get settingsAppearance;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In es, this message translates to:
  /// **'Reducir movimiento'**
  String get settingsReduceMotion;

  /// No description provided for @settingsSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad y bloqueo'**
  String get settingsSecurity;

  /// No description provided for @settingsBackup.
  ///
  /// In es, this message translates to:
  /// **'Respaldo y restauración'**
  String get settingsBackup;

  /// No description provided for @settingsDangerZone.
  ///
  /// In es, this message translates to:
  /// **'Zona de peligro'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar todos los datos'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllConfirm.
  ///
  /// In es, this message translates to:
  /// **'Esta acción borrará de manera permanente todas tus materias, notas y evaluaciones locales. No se puede deshacer a menos que tengas un archivo de respaldo. ¿Deseas continuar?'**
  String get settingsDeleteAllConfirm;
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
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
