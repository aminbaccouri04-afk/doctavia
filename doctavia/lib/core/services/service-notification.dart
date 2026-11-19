import 'package:flutter/foundation.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

/// Singleton service for scheduling local alarm notifications.
/// Used by the Medicine Reminder feature to fire alerts 15 min before dose time.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Must be called once in main() before scheduling any notifications.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    String timeZoneName;
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = tzInfo.identifier;
    } catch (e) {
      debugPrint('Timezone detection failed, trying manual detection: $e');
      // On some platforms/emulators, identifier might fail but we can try other methods
      timeZoneName = 'Africa/Algiers'; // Default fallback for this project context
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Could not set location $timeZoneName, falling back to UTC: $e');
      timeZoneName = 'UTC';
      tz.setLocalLocation(tz.UTC);
    }
    debugPrint('NotificationService: Final Timezone set to $timeZoneName');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the high-importance alarm channel (Android)
    final channel = AndroidNotificationChannel(
      'medicine_reminder_channel',
      AppContent.get('notifications.medicineChannel.name'),
      description: AppContent.get('notifications.medicineChannel.description'),
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Request permissions on Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();

    await androidPlugin?.requestNotificationsPermission();
    
    // Check and request Exact Alarms permission (Android 12+)
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.scheduleExactAlarm.status;
        debugPrint('NotificationService: Exact alarm status: $status');
      }
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
    }

    _initialized = true;
  }

  /// Checks if the exact alarm permission is granted.
  Future<bool> hasExactAlarmPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.scheduleExactAlarm.isGranted;
    }
    return true;
  }

  /// Opens the Android settings for "Alarms & Reminders".
  Future<void> requestExactAlarmPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      
      // If still denied, open settings
      if (await Permission.scheduleExactAlarm.isDenied) {
        await openAppSettings();
      }
    }
  }

  /// Schedules a notification at an exact local time.
  /// [id] must be a unique integer for each alarm slot.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Create TZDateTime using the same components as the local DateTime
    // This ensures that 10:05 AM Local becomes 10:05 AM in the tz.local location
    final tzTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    // Don't schedule if the time is in the past
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      AppContent.get('notifications.medicineChannel.name'),
      channelDescription: AppContent.get(
        'notifications.medicineChannel.description',
      ),
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    debugPrint(
      'Scheduling notification ID: $id at $tzTime (Local: $scheduledTime)',
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at same time
      );
      debugPrint('Notification $id scheduled successfully at $tzTime');
    } catch (e) {
      debugPrint('CRITICAL: Failed to schedule notification $id: $e');
      // If exact alarm fails, try with a less restrictive mode as fallback
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzTime,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('Scheduled with fallback (inexact mode)');
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
      }
    }
  }

  /// Cancels a specific scheduled notification.
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Fires an immediate notification for testing purposes.
  Future<void> testNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      999,
      '🔔 Test Notification',
      'If you see this, the notification system is working correctly!',
      notificationDetails,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Could navigate to reminders screen in the future
  }
}
