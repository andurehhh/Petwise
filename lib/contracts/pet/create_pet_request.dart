class CreatePetRequest {
  final String name;
  final String species;
  final String userId;
  final DateTime birthday;
  final String sex;
  final String breed;
  final double weight;

  CreatePetRequest({
    required this.name,
    required this.species,
    required this.userId,
    required this.birthday,
    required this.sex,
    required this.breed,
    required this.weight,
  });

  factory CreatePetRequest.fromJson(Map<String, dynamic> json) {
    return CreatePetRequest(
      name: json['name'],
      species: json['species'],
      userId: json['user_id'],
      birthday: DateTime.parse(json['birthday']),
      sex: json['sex'],
      breed: json['breed'],
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'user_id': userId,
      'birthday': birthday.toIso8601String(),
      'sex': sex,
      'breed': breed,
      'weight': weight,
    };
  }
}
