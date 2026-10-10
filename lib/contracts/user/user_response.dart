class UserResponse {
  final String userId;
  final String email;
  final DateTime createdAt;
  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? contactNumber;
  final String? address;
  final bool hasCompletedSetup;

  UserResponse({
    required this.userId,
    required this.email,
    required this.createdAt,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.nickname,
    this.contactNumber,
    this.address,
    this.hasCompletedSetup = false,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      nickname: json['nickname'],
      contactNumber: json['contact_number'] ?? json['contactNumber'],
      address: json['address'],
      hasCompletedSetup: json['has_completed_setup'] ?? json['hasCompletedSetup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'image_url': imageUrl,
      'last_name': lastName,
      'nickname': nickname,
      'contact_number': contactNumber,
      'address': address,
      'has_completed_setup': hasCompletedSetup,
    };
  }
}
