import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../features/medications/domain/entities/medication.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'medication_reminders';
  static const String _channelName = 'Medication Reminders';
  static const String _channelDesc = 'Scheduled medication dose reminders';

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Request notification and alarm permissions at runtime (Android 13+).
  Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // ─── Schedule ────────────────────────────────────────────────────────────────

  /// Schedule all reminders for a medication, replacing any existing ones.
  Future<void> scheduleMedicationReminders(Medication medication) async {
    await cancelMedicationReminders(medication);
    if (medication.frequencyType == FrequencyType.asNeeded) return;
    if (medication.reminderTimes.isEmpty) return;

    for (final timeStr in medication.reminderTimes) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      switch (medication.frequencyType) {
        case FrequencyType.daily:
        case FrequencyType.interval:
          await _scheduleDailyNotification(medication, hour, minute);
          break;
        case FrequencyType.specificDays:
          for (final day in medication.frequencyDays) {
            await _scheduleWeeklyNotification(medication, hour, minute, day);
          }
          break;
        case FrequencyType.asNeeded:
          break;
      }
    }
  }

  Future<void> _scheduleDailyNotification(
      Medication medication, int hour, int minute) async {
    final id = _notificationId(medication.id, hour, minute);
    await _plugin.zonedSchedule(
      id,
      'Time to take ${medication.name}',
      '${medication.dosage}${medication.unit} · ${medication.type}',
      _nextInstanceOfTime(hour, minute),
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeeklyNotification(
      Medication medication, int hour, int minute, String dayName) async {
    final dayOfWeek = _dayNameToWeekday(dayName);
    if (dayOfWeek == null) return;
    final id = _notificationId(medication.id, hour, minute, dayOfWeek);
    await _plugin.zonedSchedule(
      id,
      'Time to take ${medication.name}',
      '${medication.dosage}${medication.unit} · ${medication.type}',
      _nextInstanceOfTimeOnDay(hour, minute, dayOfWeek),
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ─── Snooze ───────────────────────────────────────────────────────────────

  /// Re-schedule a fired notification [minutes] into the future (default 10).
  Future<void> snoozeReminder({
    required int notificationId,
    required String medicationName,
    required String body,
    int minutes = 10,
  }) async {
    await _plugin.cancel(notificationId);
    final snoozeTime =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
    await _plugin.zonedSchedule(
      notificationId,
      'Snoozed: $medicationName',
      body,
      snoozeTime,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ─── Refill alert ─────────────────────────────────────────────────────────

  /// Show an immediate low-stock notification.
  Future<void> showRefillAlert(Medication medication) async {
    const refillDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'refill_reminders',
        'Refill Reminders',
        channelDescription: 'Alerts when medication stock is running low',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      _notificationId(medication.id, 0, 0, 99),
      'Refill needed: ${medication.name}',
      'Only ${medication.currentStock} ${medication.unit} remaining.',
      refillDetails,
    );
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────

  /// Cancel all scheduled reminders for a medication.
  Future<void> cancelMedicationReminders(Medication medication) async {
    for (final timeStr in medication.reminderTimes) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (medication.frequencyType == FrequencyType.specificDays) {
        for (final day in medication.frequencyDays) {
          final dow = _dayNameToWeekday(day);
          if (dow != null) {
            await _plugin.cancel(_notificationId(medication.id, hour, minute, dow));
          }
        }
      } else {
        await _plugin.cancel(_notificationId(medication.id, hour, minute));
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  NotificationDetails _buildDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Deterministic, stable notification ID from medication ID + time + day.
  /// Uses a large multiplier to ensure (hour, minute, dayOfWeek) combinations
  /// don't collide with each other within or across medications.
  int _notificationId(String medicationId, int hour, int minute,
      [int dayOfWeek = 0]) {
    int hash = 0;
    for (int i = 0; i < medicationId.length; i++) {
      hash = (hash * 31 + medicationId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    // (hour*1000 + minute*10 + dayOfWeek) is unique for all valid combinations
    // max = 23*1000 + 59*10 + 7 = 23597 < 100000
    return (hash % 10000) * 100000 + hour * 1000 + minute * 10 + dayOfWeek;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var dt =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
    return dt;
  }

  tz.TZDateTime _nextInstanceOfTimeOnDay(
      int hour, int minute, int targetWeekday) {
    var dt = _nextInstanceOfTime(hour, minute);
    while (dt.weekday != targetWeekday) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  /// Convert abbreviated day name to ISO weekday (Mon=1 … Sun=7).
  int? _dayNameToWeekday(String day) {
    const map = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };
    return map[day];
  }
}
