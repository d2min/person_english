import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalReminderService {
  LocalReminderService(this._settings);

  static const _enabledKey = 'daily_reminder_enabled';
  static const _hourKey = 'daily_reminder_hour';
  static const _minuteKey = 'daily_reminder_minute';
  static const _notificationId = 1001;

  final Box<dynamic> _settings;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool get isEnabled => _settings.get(_enabledKey, defaultValue: false) as bool;
  int get hour => _settings.get(_hourKey, defaultValue: 20) as int;
  int get minute => _settings.get(_minuteKey, defaultValue: 0) as int;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(createDeviceLocalTimezone());

    final initialized = await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    // On iOS the plugin returns the current permission state; false means
    // permission has not been granted yet, not that plugin setup failed.
    if (initialized == true && isEnabled) await _scheduleDaily();
  }

  Future<bool> setEnabled(bool enabled) async {
    if (!enabled) {
      await _notifications.cancel(id: _notificationId);
      await _settings.put(_enabledKey, false);
      return true;
    }

    final granted = await _requestPermission();
    if (!granted) return false;
    await _settings.put(_enabledKey, true);
    await _scheduleDaily();
    return true;
  }

  Future<void> setTime({required int hour, required int minute}) async {
    await _settings.putAll({_hourKey: hour, _minuteKey: minute});
    if (isEnabled) await _scheduleDaily();
  }

  Future<bool> _requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final result = await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        return result ?? false;
      case TargetPlatform.iOS:
        final result = await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: false, sound: true);
        return result ?? false;
      default:
        throw UnsupportedError(
          'Локальные напоминания доступны на Android и iOS.',
        );
    }
  }

  Future<void> _scheduleDaily() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    await _notifications.zonedSchedule(
      id: _notificationId,
      title: 'Время повторить слова',
      body: 'Открой словарь и продолжи занятие.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'word_review_reminder',
          'Напоминания о повторении',
          channelDescription: 'Ежедневные напоминания о повторении слов',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

tz.Location createDeviceLocalTimezone({
  Duration? offset,
  String? abbreviation,
}) {
  final deviceOffset = offset ?? DateTime.now().timeZoneOffset;
  final zoneName = abbreviation ?? DateTime.now().timeZoneName;
  return tz.Location('device-local', [tz.minTime], [0], [
    tz.TimeZone(deviceOffset, isDst: false, abbreviation: zoneName),
  ]);
}
