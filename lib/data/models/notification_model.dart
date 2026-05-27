class ActivityNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduleTime;
  final String? recurrence;

  ActivityNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduleTime,
    this.recurrence,
  });
}
