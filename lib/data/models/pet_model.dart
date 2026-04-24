class Pet {
  final int id; // matches pet_id (IMPORTANT FIX)
  final DateTime createdAt;
  final String userId;
  final String name;
  final String species;
  final DateTime birthday;
  final String sex;
  final String? breed;
  final double? weight;

  Pet({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.name,
    required this.species,
    required this.birthday,
    required this.sex,
    this.breed,
    this.weight,
  });

  int get age {
    final now = DateTime.now();
    int years = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      years--;
    }

    return years < 0 ? 0 : years;
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['pet_id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      userId: json['user_id'],
      name: json['name'],
      species: json['species'],
      birthday: DateTime.parse(json['birthday']).toLocal(),
      sex: json['sex'],
      breed: json['breed'],
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'name': name,
      'species': species,
      'birthday': birthday.toIso8601String(),
      'sex': sex,
      'breed': breed,
      'weight': weight,
    };
  }
}
