class ActivityModel {
  final String id;
  final DateTime createdAt;
  final int petId;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final bool isCompleted;
  final String? recurrence;

  ActivityModel ({
    required this.id,
    required this.createdAt,
    required this.petId,
    required this.title,
    required this.scheduledDate,
    required this.isCompleted,
    this.description,
    this.recurrence,
  });

  factory ActivityModel.fromJson(Map<String,dynamic> json){
    return ActivityModel(
      id: json["activity_id"],
      createdAt: DateTime.parse(json["created_at"]),
      petId: json["pet_id"],
      title: json["title"],
      description: json["description"],
      scheduledDate: DateTime.parse(json["scheduled_date"]),
      isCompleted: json["is_completed"]?? false,
      recurrence: json["recurrence"],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "activity_id":id,
      "created_at":createdAt.toIso8601String(),
      "pet_id":petId,
      "title":title,
      "description":description,
      "scheduled_date":scheduledDate.toIso8601String(),
      "is_completed":isCompleted,
      "recurrence":recurrence,
    };
  }

}