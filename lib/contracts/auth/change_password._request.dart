class ChangePasswordRequest {
  final String email;
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.email,
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      email: json['email'],
      currentPassword: json['current_password'],
      newPassword: json['new_password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}
