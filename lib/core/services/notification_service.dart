import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:aula/features/exams/domain/entities/exam.dart';

class NotificationService {
  NotificationService() {
    _initPlugin();
  }

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> _initPlugin() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _isInitialized = true;
  }

  /// Request POST_NOTIFICATIONS permission for Android 13+
  Future<bool> requestPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImplementation?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Schedule reminders for an exam (1 day before + morning of the exam at 08:00 AM)
  Future<void> scheduleExamReminders(Exam exam, String subjectName) async {
    if (!exam.reminderEnabled) return;

    final examTz = tz.TZDateTime.from(exam.dateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // Reminder 1: 24 hours before
    final oneDayBefore = examTz.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      final notifId1 = (exam.id.hashCode ^ 1).abs();
      await _scheduleSingle(
        id: notifId1,
        title: 'Mañana rinde: ${exam.title}',
        body: '$subjectName • Hora: ${exam.dateTime.hour.toString().padLeft(2, '0')}:${exam.dateTime.minute.toString().padLeft(2, '0')}',
        scheduledDate: oneDayBefore,
      );
    }

    // Reminder 2: Morning of the exam (8:00 AM)
    final morningOf = tz.TZDateTime(
      tz.local,
      examTz.year,
      examTz.month,
      examTz.day,
      8,
      0,
    );
    if (morningOf.isAfter(now) && morningOf.isBefore(examTz)) {
      final notifId2 = (exam.id.hashCode ^ 2).abs();
      await _scheduleSingle(
        id: notifId2,
        title: '¡Hoy rinde: ${exam.title}!',
        body: '$subjectName • Duración: ${exam.durationMinutes} min',
        scheduledDate: morningOf,
      );
    }
  }

  Future<void> cancelExamReminders(Exam exam) async {
    final notifId1 = (exam.id.hashCode ^ 1).abs();
    final notifId2 = (exam.id.hashCode ^ 2).abs();
    await _plugin.cancel(notifId1);
    await _plugin.cancel(notifId2);
  }

  Future<void> _scheduleSingle({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aula_exams_channel',
      'Recordatorios de Evaluaciones',
      channelDescription: 'Avisos previos a parciales, finales y entregas de TP',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // Battery friendly & API compliant
      );
    } catch (_) {
      // Graceful fallback
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
