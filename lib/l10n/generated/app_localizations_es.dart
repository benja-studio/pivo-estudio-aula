// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Aula';

  @override
  String get appTagline =>
      'Tu vida académica organizada, offline y sin fricción';

  @override
  String get onboardingWelcomeTitle => 'Organiza tu carrera sin esfuerzo';

  @override
  String get onboardingWelcomeSubtitle =>
      'Tus parciales, temas a estudiar, notas y promedios en un solo lugar. 100% privado y offline.';

  @override
  String get onboardingStudentInfoTitle => 'Cuéntanos sobre tus estudios';

  @override
  String get onboardingStudentInfoSubtitle =>
      'Estos datos personalizarán tu experiencia y cálculos de materias.';

  @override
  String get onboardingProfilePhotoTitle => 'Foto de perfil';

  @override
  String get onboardingProfilePhotoSubtitle =>
      'Elegí una foto para reconocerte o usá tu avatar por defecto.';

  @override
  String get onboardingPreferencesTitle => 'Tus preferencias';

  @override
  String get onboardingPreferencesSubtitle =>
      'Elegí tu escala de notas y ajustá cómo quieres que se vea Aula.';

  @override
  String get fullNameLabel => 'Nombre y apellido';

  @override
  String get fullNameError => 'Por favor ingresa tu nombre';

  @override
  String get careerLabel => 'Carrera';

  @override
  String get careerError => 'Por favor ingresa tu carrera';

  @override
  String get institutionLabel => 'Instituto o Universidad';

  @override
  String get institutionError => 'Por favor ingresa tu institución';

  @override
  String get academicLevelLabel => 'Año o nivel que cursas (ej. 3er año)';

  @override
  String get studentIdLabel => 'Legajo o matrícula (opcional)';

  @override
  String get emailLabel => 'Email de contacto (opcional)';

  @override
  String get currentPeriodLabel => 'Período académico actual';

  @override
  String get currentPeriodHint => 'Ej: 1er cuatrimestre 2026';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get accentColorLabel => 'Color de acento';

  @override
  String get gradeScaleLabel => 'Escala de notas';

  @override
  String get passingGradeLabel => 'Nota mínima de aprobación';

  @override
  String get notificationsEnable => 'Activar recordatorios de exámenes';

  @override
  String get buttonContinue => 'Continuar';

  @override
  String get buttonStart => 'Comenzar en Aula';

  @override
  String get buttonSkip => 'Omitir por ahora';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonUndo => 'Deshacer';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navSubjects => 'Materias';

  @override
  String get navGrades => 'Notas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homeUpcomingExams => 'Próximas evaluaciones';

  @override
  String get homeThisWeek => 'Esta semana';

  @override
  String get homeOverdueExams => 'Evaluaciones pendientes de nota';

  @override
  String get homeOverallAverage => 'Promedio general';

  @override
  String get homePeriodProgress => 'Progreso del período';

  @override
  String homeDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltan $days días',
      one: 'Falta 1 día',
      zero: '¡Es hoy!',
    );
    return '$_temp0';
  }

  @override
  String get subjectsTitle => 'Materias';

  @override
  String get subjectsEmpty => 'Aún no tienes materias agregadas';

  @override
  String get subjectsAdd => 'Nueva materia';

  @override
  String get subjectStatusTaking => 'Cursando';

  @override
  String get subjectStatusRegular => 'Regular';

  @override
  String get subjectStatusPassed => 'Aprobada';

  @override
  String get subjectStatusFailed => 'Libre';

  @override
  String get subjectStatusRetaking => 'Recursando';

  @override
  String get examsTitle => 'Evaluaciones';

  @override
  String get examsEmpty => 'No hay evaluaciones registradas';

  @override
  String get examsAdd => 'Nueva evaluación';

  @override
  String get examTypeMidterm => 'Parcial';

  @override
  String get examTypeRetake => 'Recuperatorio';

  @override
  String get examTypeFinal => 'Final';

  @override
  String get examTypeAssignment => 'Trabajo Práctico';

  @override
  String get examTypeQuiz => 'Quiz / Control';

  @override
  String get examTypeOral => 'Examen Oral';

  @override
  String get examStatusPending => 'Pendiente';

  @override
  String get examStatusTaken => 'Rendido';

  @override
  String get examStatusPassed => 'Aprobado';

  @override
  String get examStatusFailed => 'Desaprobado';

  @override
  String get examStatusAbsent => 'Ausente';

  @override
  String get topicStatusNotStarted => 'Sin empezar';

  @override
  String get topicStatusStudying => 'Estudiando';

  @override
  String get topicStatusReviewed => 'Repasado';

  @override
  String get topicStatusMastered => 'Dominado';

  @override
  String get gradesTitle => 'Notas y Promedios';

  @override
  String get gradesAverage => 'Promedio acumulado';

  @override
  String get gradesCalculator => 'Calculadora ¿Qué nota necesito?';

  @override
  String get gradesTargetAverage => 'Promedio objetivo';

  @override
  String get searchPlaceholder => 'Buscar materias, exámenes, notas o temas...';

  @override
  String get searchNoResults => 'No se encontraron resultados';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsProfile => 'Perfil del estudiante';

  @override
  String get settingsAppearance => 'Apariencia y tema';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get settingsSecurity => 'Seguridad y bloqueo';

  @override
  String get settingsBackup => 'Respaldo y restauración';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsDeleteAll => 'Borrar todos los datos';

  @override
  String get settingsDeleteAllConfirm =>
      'Esta acción borrará de manera permanente todas tus materias, notas y evaluaciones locales. No se puede deshacer a menos que tengas un archivo de respaldo. ¿Deseas continuar?';
}
