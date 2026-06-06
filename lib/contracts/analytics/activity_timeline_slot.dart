class ActivityTimelineSlot {
  final String timeSlot;
  final int count;

  ActivityTimelineSlot({required this.timeSlot, required this.count});

  factory ActivityTimelineSlot.fromJson(Map<String, dynamic> json) {
    return ActivityTimelineSlot(
      timeSlot:
          json['timeSlot']?.toString() ?? json['time_slot']?.toString() ?? '',
      count: num.tryParse(json['count']?.toString() ?? '0')?.toInt() ?? 0,
    );
  }
}
