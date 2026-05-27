import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:petwise/data/models/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotifService {
  static final NotifService _instance = NotifService._internal();
  factory NotifService() => _instance;
  NotifService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

// initialize
  Future<void> initNotification() async {
    if (_isInitialized) return;

    //initialize TimeZone
    tz.initializeTimeZones();

    try {
      final TimezoneInfo tzData = await FlutterTimezone.getLocalTimezone();
      // Handle potential object vs string return from different versions
      String timeZoneName = tzData.identifier;

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ Timezone Initialized: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Timezone match failed, falling back to UTC: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;

    final androidImpl = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  //NotifDetails
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'petwise_activity_channel',
            'Pet Activity Alerts',
            channelDescription: 'Reminders for your pets activity',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher'));
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

  //scheduled notif
  Future<void> scheduledNotification(ActivityNotification activityNotif) async {
    final now = tz.TZDateTime.now(tz.local);
    // Convert to lowercase to match UI values: 'none', 'daily', 'weekly', 'monthly'
    final String r = (activityNotif.recurrence?.trim() ?? "none").toLowerCase();

    // Fix for the 2026 placeholder year bug:
    // If it's a recurring task, we start counting from TODAY's year/month/day.
    // If it's a one-off ('none'), we use the actual year/month/day provided.
    var scheduledDate = tz.TZDateTime(
      tz.local,
      r == "none" ? activityNotif.scheduleTime.year : now.year,
      r == "none" ? activityNotif.scheduleTime.month : now.month,
      r == "none" ? activityNotif.scheduleTime.day : now.day,
      activityNotif.scheduleTime.hour,
      activityNotif.scheduleTime.minute,
    );

    // If Weekly, ensure we match the intended Weekday (e.g., if the user wants Wednesdays)
    if (r == 'weekly') {
      while (scheduledDate.weekday != activityNotif.scheduleTime.weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } 
    // If Monthly, ensure we match the intended Day of Month
    else if (r == 'monthly') {
      while (scheduledDate.day != activityNotif.scheduleTime.day) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    // Move to the next period if the target time has already passed today
    if (scheduledDate.isBefore(now)) {
      if (r == "daily") {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      } else if (r == "weekly") {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      } else if (r == "monthly") {
        // Correctly jump to next month
        scheduledDate = tz.TZDateTime(
          tz.local,
          scheduledDate.month == 12 ? scheduledDate.year + 1 : scheduledDate.year,
          scheduledDate.month == 12 ? 1 : scheduledDate.month + 1,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
        );
      } else {
        // For 'none', if it's already past, set for 5 seconds from now for an immediate alert
        scheduledDate = now.add(const Duration(seconds: 5));
      }
    }

    DateTimeComponents? matchComponents;
    if (r == "daily") {
      matchComponents = DateTimeComponents.time;
    } else if (r == "weekly") {
      matchComponents = DateTimeComponents.dayOfWeekAndTime;
    } else if (r == "monthly") {
      matchComponents = DateTimeComponents.dayOfMonthAndTime;
    }

    await notificationsPlugin.zonedSchedule(
      activityNotif.id,
      activityNotif.title,
      activityNotif.body,
      scheduledDate,
      notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
    );

    debugPrint("✅ SCHEDULED NOTIF: ID ${activityNotif.id} on $scheduledDate (Recurrence: $r)");
  }

  //cancel notifs
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

//Cancel specific notif
  Future<void> cancelNotification(String id) async {
    int baseId = int.tryParse(id) ?? id.hashCode.abs();
    await notificationsPlugin.cancel(baseId);
    debugPrint("🚫 CANCELLED NOTIF: ID $baseId");
  }
}
