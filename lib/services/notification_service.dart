import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:petwise/data/models/notification_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Get the device's timezone
    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    debugPrint("Timezone: ${timeZoneName.identifier}");

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    // Request permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification(ActivityNotification activity) async {
    // 1. Calculate time - Using a more robust conversion
    // First convert to UTC, then back to the specific local TZ to avoid offset errors
    var scheduledDate = tz.TZDateTime.from(activity.scheduleTime.toUtc(), tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // 2. Buffer check: Ensure it's at least 10 seconds in the future
    if (scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
      debugPrint("Setting test buffer: Moving schedule to +5s from now.");
      scheduledDate = now.add(const Duration(seconds: 5));
    }

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // 3. ANDROID 13/14 PROTECTION
    // canScheduleExactNotifications can return true while the system still blocks it
    // if the app was just installed.
    bool? hasPermission = await androidImplementation?.canScheduleExactNotifications();

    if (hasPermission == false) {
      debugPrint("❌ ALARM PERMISSION MISSING: Attempting to request...");
      // This will open the system settings for the user if permission is missing
      await androidImplementation?.requestNotificationsPermission();
      return;
    }

    debugPrint("📅 Raw scheduleTime: ${activity.scheduleTime}");
    debugPrint("📅 Converted TZ: $scheduledDate");
    debugPrint("📅 Now: $now");
    debugPrint("📅 Diff in seconds: ${scheduledDate.difference(now).inSeconds}");
    try {
      await _notifications.zonedSchedule(
        activity.id.hashCode,
        activity.title,
        activity.body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'petwise_urgent_channel_v3', // INCREMENTED ID: Forces fresh OS registration
            'Activity Reminders',
            channelDescription: 'Urgent alerts for pet tasks',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            // This is vital for scheduled tasks to pop up
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("✅ Notification SUCCESS: Scheduled for $scheduledDate (ID: ${activity.id.hashCode})");
    } catch (e) {
      debugPrint("❌ Notification FAILED: $e");
    }
  }
  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'petwise_instant_v1',
      'Instant Alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}