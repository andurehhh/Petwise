class UserModel {
  final String id; // maps to user_id
  final String firstName;
  final String lastName;
  final String email;
  final String? nickname;
  final String? image_url;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.image_url,
    this.nickname,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      image_url: json['image_url'],
      nickname: json['nickname'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
