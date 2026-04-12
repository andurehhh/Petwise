class HealthEvent{
  final id;
  final createdAt;
  final eventName;
  final eventDate;
  final type;
  final isCompleted;
  final petId;

  HealthEvent({
    required this.id,
    required this.createdAt,
    required this.eventName,
    required this.eventDate,
    required this.type,
    required this.isCompleted,
    required this.petId,
});

  factory HealthEvent.fromJson(Map<String,dynamic> json){
    return HealthEvent(
      id: json['event_id'],
      createdAt: DateTime.parse(json['created_at']),
      eventName: json['event_name'],
      eventDate: DateTime.parse(json['event_date']),
      type: json['type'],
      isCompleted: json['is_completed']?? false,
      petId: json['pet_id'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'event_id':id,
      'created_at':createdAt.toIso8601String(),
      'event_name':eventName,
      'event_date':eventDate.toIso8601String(),
      'type':type,
      'is_completed':isCompleted,
      'pet_id':petId,
    };
  }
}