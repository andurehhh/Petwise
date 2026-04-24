class PetResponse {
  final int petId;
  final String name;
  final String species;
  final String userId;
  final DateTime birthday;
  final String sex;
  final String breed;
  final double weight;
  final DateTime createdAt;

  PetResponse({
    required this.petId,
    required this.name,
    required this.species,
    required this.userId,
    required this.birthday,
    required this.sex,
    required this.breed,
    required this.weight,
    required this.createdAt,
  });

  factory PetResponse.fromJson(Map<String, dynamic> json) {
    return PetResponse(
      petId: json['pet_id'] ?? 0,
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      userId: json['user_id'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday']).toLocal()
          : DateTime.now(),
      sex: json['sex'] ?? '',
      breed: json['breed'] ?? '',
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'name': name,
      'species': species,
      'user_id': userId,
      'birthday': birthday.toIso8601String(),
      'sex': sex,
      'breed': breed,
      'weight': weight,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
