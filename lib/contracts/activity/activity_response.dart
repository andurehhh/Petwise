class ActivityResponse {
  final int activityId;
  final int petId;
  final String title;
  final String description;
  final String timeScheduled;
  final String recurrence;
  final bool isActive;
  final DateTime createdAt;

  ActivityResponse({
    required this.activityId,
    required this.petId,
    required this.title,
    required this.description,
    required this.timeScheduled,
    required this.recurrence,
    required this.isActive,
    required this.createdAt,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      activityId: json['activity_id'] as int,
      petId: json['pet_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      timeScheduled: json['time_scheduled'] as String,
      recurrence: json['recurrence'] as String? ?? 'none',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'pet_id': petId,
      'title': title,
      'description': description,
      'time_scheduled': timeScheduled,
      'recurrence': recurrence,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
