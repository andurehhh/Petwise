class UpdatePetRequest {
  final String? name;
  final String? species;
  final DateTime? birthday;
  final String? sex;
  final String? breed;
  final double? weight;

  UpdatePetRequest({
    this.name,
    this.species,
    this.birthday,
    this.sex,
    this.breed,
    this.weight,
  });

  factory UpdatePetRequest.fromJson(Map<String, dynamic> json) {
    return UpdatePetRequest(
      name: json['name'],
      species: json['species'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      sex: json['sex'],
      breed: json['breed'],
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (species != null) data['species'] = species;
    if (birthday != null) {
      data['birthday'] = birthday!.toIso8601String();
    }
    if (sex != null) data['sex'] = sex;
    if (breed != null) data['breed'] = breed;
    if (weight != null) data['weight'] = weight;

    return data;
  }
}
