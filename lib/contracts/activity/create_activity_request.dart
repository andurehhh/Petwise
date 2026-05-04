class CreateActivityRequest {
  final int petId;
  final String title;
  final String description;
  final String timeScheduled;
  final String recurrence;

  CreateActivityRequest({
    required this.petId,
    required this.title,
    required this.description,
    required this.timeScheduled,
    required this.recurrence,
  });

  factory CreateActivityRequest.fromJson(Map<String, dynamic> json) {
    return CreateActivityRequest(
      petId: json['pet_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      timeScheduled: json['time_scheduled'] as String,
      recurrence: json['recurrence'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'title': title,
      'description': description,
      'time_scheduled': timeScheduled,
      'recurrence': recurrence,
    };
  }
}
