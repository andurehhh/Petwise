class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String nickname;
  final String password;
  final String imageUrl;
  final String? contactNumber;
  final String? address;

  CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.nickname,
    required this.password,
    this.imageUrl = '',
    this.contactNumber,
    this.address,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      email: json['email'],
      nickname: json['nickname'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      password: json['password'],
      contactNumber: json['contact_number'] ?? json['contactNumber'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'image_url': imageUrl,
      'nickname': nickname,
      'password': password,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (address != null) 'address': address,
    };
  }
}
