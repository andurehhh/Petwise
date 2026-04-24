class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String nickname;
  final String password;

  CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nickname,
    required this.password,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      nickname: json['nickname'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'nickname': nickname,
      'password': password,
    };
  }
}
