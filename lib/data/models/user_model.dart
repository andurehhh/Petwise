class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? nickname;
  final String? imageUrl;
  final String? contactNumber;
  final String? address;
  final DateTime? createdAt;
  final bool hasCompletedSetup;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.nickname,
    this.contactNumber,
    this.address,
    this.createdAt,
    this.hasCompletedSetup = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['userId'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      nickname: json['nickname'],
      contactNumber: json['contact_number'] ?? json['contactNumber'],
      address: json['address'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      hasCompletedSetup: json['has_completed_setup'] ?? json['hasCompletedSetup'] ?? false,
    );
  }
}
