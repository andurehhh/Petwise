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
  Future<void> initNotification() async{
    if(_isInitialized) return;

    //initialize TimeZone
    tz.initializeTimeZones();

    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    print("This is the timezone: " + timeZoneName.identifier);
    final String timeZoneNameString = timeZoneName.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneNameString));

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
        android: initSettingsAndroid
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;

    final androidImpl = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidImpl?.requestNotificationsPermission();
    debugPrint("Notification permission granted: $granted");

    // v18 REQUIRED for exact alarms
    final exactGranted = await androidImpl?.requestExactAlarmsPermission();
    debugPrint("Exact alarm permission granted: $exactGranted");
  }

  //NotifDetails
  NotificationDetails notificationDetails(){
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'testChannelId',
            'testChannelName',
            channelDescription: 'testChannelDescription',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher'
        )
    );
  }

  //Show Notif
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body}) async {
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

    //date time for today specified
    var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        activityNotif.scheduleTime.hour,
        activityNotif.scheduleTime.minute,
        );

    await notificationsPlugin.zonedSchedule(
        activityNotif.id,
        activityNotif.title,
        activityNotif.body,
        scheduledDate,
        notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      //repeats daily
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("SCHEDULED NOTIF: NOTIF SCHED TO: $scheduledDate");
  }

  //cancel notifs
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

//Cancel specific notif
  Future<void> cancelNotification(String id) async {
    await notificationsPlugin.cancel(id.hashCode.abs());
  }
}