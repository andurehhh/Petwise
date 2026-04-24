class UserResponse {
  final String userId;
  final String email;
  final DateTime createdAt;

  final String? firstName;
  final String? lastName;
  final String? nickname;

  UserResponse({
    required this.userId,
    required this.email,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.nickname,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),

      firstName: json['first_name'],
      lastName: json['last_name'],
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'nickname': nickname,
    };
  }
}
