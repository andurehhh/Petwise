class UpdateActivityRequest {
  final String? title;
  final String? description;
  final String? timeScheduled;
  final String? recurrence;
  final bool? isActive;

  UpdateActivityRequest({
    this.title,
    this.description,
    this.timeScheduled,
    this.recurrence,
    this.isActive,
  });

  factory UpdateActivityRequest.fromJson(Map<String, dynamic> json) {
    return UpdateActivityRequest(
      title: json['title'],
      description: json['description'],
      timeScheduled: json['time_scheduled'],
      recurrence: json['recurrence'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (timeScheduled != null) data['time_scheduled'] = timeScheduled;
    if (recurrence != null) data['recurrence'] = recurrence;
    if (isActive != null) data['is_active'] = isActive;

    return data;
  }
}
