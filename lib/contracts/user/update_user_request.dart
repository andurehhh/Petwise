class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? imageUrl;
  final String? contactNumber;
  final String? address;
  final bool? hasCompletedSetup;

  UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.nickname,
    this.imageUrl,
    this.contactNumber,
    this.address,
    this.hasCompletedSetup,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRequest(
      firstName: json.containsKey('first_name')
          ? json['first_name']
          : json['firstName'],
      lastName: json.containsKey('last_name')
          ? json['last_name']
          : json['lastName'],
      nickname: json.containsKey('nickname') ? json['nickname'] : null,
      imageUrl: json.containsKey('image_url')
          ? json['image_url']
          : json['imageUrl'],
      contactNumber: json.containsKey('contact_number')
          ? json['contact_number']
          : json['contactNumber'],
      address: json.containsKey('address') ? json['address'] : null,
      hasCompletedSetup: json.containsKey('has_completed_setup')
          ? json['has_completed_setup']
          : json['hasCompletedSetup'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (nickname != null) data['nickname'] = nickname;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (contactNumber != null) data['contact_number'] = contactNumber;
    if (address != null) data['address'] = address;
    if (hasCompletedSetup != null) {
      data['has_completed_setup'] = hasCompletedSetup;
    }
    return data;
  }
}
