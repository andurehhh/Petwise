class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? nickname;
  final String? imageUrl;
  final DateTime? createdAt;
  final bool hasCompletedSetup;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.nickname,
    this.createdAt,
    this.hasCompletedSetup = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      imageUrl: json['image_url'],
      nickname: json['nickname'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      hasCompletedSetup: json['has_completed_setup'] ?? false,
    );
  }
}
