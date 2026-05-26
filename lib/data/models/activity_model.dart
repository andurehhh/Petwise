class ActivityModel {
  final int id;
  final DateTime createdAt;
  int petId;
  String title;
  String? description;
  DateTime scheduledDate;
  bool isCompleted;
  String? recurrence;

  ActivityModel({
    required this.id,
    required this.createdAt,
    required this.petId,
    required this.title,
    required this.scheduledDate,
    required this.isCompleted,
    this.description,
    this.recurrence,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json["activity_id"] as int,
      createdAt: DateTime.parse(json["created_at"]),
      petId: json["pet_id"] as int,
      title: json["title"] as String,
      description: json["description"] as String?,
      scheduledDate: DateTime.parse(json["time_scheduled"] ?? json["scheduled_date"]),
      isCompleted: json["is_active"] ?? false, // Mapping isActive from backend to isCompleted locally
      recurrence: json["recurrence"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "activity_id": id,
      "created_at": createdAt.toIso8601String(),
      "pet_id": petId,
      "title": title,
      "description": description,
      "time_scheduled": scheduledDate.toIso8601String(),
      "is_active": isCompleted,
      "recurrence": recurrence,
    };
  }
}
