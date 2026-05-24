class HealthEventResponse {
  final int eventId;
  final int petId;
  final String eventName;
  final DateTime eventDate;
  final String type; // e.g., "vaccination", "illness", "checkup"
  final bool isCompleted;
  final DateTime createdAt;

  HealthEventResponse({
    required this.eventId,
    required this.petId,
    required this.eventName,
    required this.eventDate,
    required this.type,
    required this.isCompleted,
    required this.createdAt,
  });

  factory HealthEventResponse.fromJson(Map<String, dynamic> json) {
    return HealthEventResponse(
      eventId: json['event_id'] as int,
      petId: json['pet_id'] as int,
      eventName: json['event_name'] as String,
      // DateTime.parse cleanly reads the ISO strings sent from ASP.NET Core
      eventDate: DateTime.parse(json['event_date'] as String),
      type: json['type'] as String,
      isCompleted: json['is_completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'pet_id': petId,
      'event_name': eventName,
      'event_date': eventDate.toIso8601String(),
      'type': type,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
