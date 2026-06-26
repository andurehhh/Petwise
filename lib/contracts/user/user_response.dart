class UserResponse {
  final String userId;
  final String email;
  final DateTime createdAt;
  final String? image_url;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final bool hasCompletedSetup;

  UserResponse({
    required this.userId,
    required this.email,
    required this.createdAt,
    this.image_url,
    this.firstName,
    this.lastName,
    this.nickname,
    this.hasCompletedSetup = false,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      image_url: json['image_url'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      nickname: json['nickname'],
      hasCompletedSetup: json['has_completed_setup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'image_url': image_url,
      'last_name': lastName,
      'nickname': nickname,
      'has_completed_setup': hasCompletedSetup,
    };
  }
}
