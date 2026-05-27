class CreateHealthEventRequest {
  final int petId;
  final String eventName;
  final DateTime eventDate;
  final String type;

  CreateHealthEventRequest({
    required this.petId,
    required this.eventName,
    required this.eventDate,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'event_name': eventName,
      'event_date': eventDate.toIso8601String(),
      'type': type,
    };
  }
}
