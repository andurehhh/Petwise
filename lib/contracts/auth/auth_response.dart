class AuthResponse {
  final String userId;
  final String email;
  final String accessToken;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      accessToken: json['access_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email, 'accessToken': accessToken};
  }
}
