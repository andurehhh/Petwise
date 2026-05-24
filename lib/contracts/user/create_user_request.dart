class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String nickname;
  final String password;
  final String image_url;

  CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nickname,
    required this.password,
    required this.image_url,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      nickname: json['nickname'],
      image_url: json['image_url'],

      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'image_url': image_url,
      'nickname': nickname,
      'password': password,
    };
  }
}
