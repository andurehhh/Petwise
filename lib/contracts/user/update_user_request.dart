class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? imageUrl;
  final bool? hasCompletedSetup;

  UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.nickname,
    this.imageUrl,
    this.hasCompletedSetup,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRequest(
      firstName: json.containsKey('first_name') ? json['first_name'] : null,
      lastName: json.containsKey('last_name') ? json['last_name'] : null,
      nickname: json.containsKey('nickname') ? json['nickname'] : null,
      imageUrl: json.containsKey('image_url') ? json['image_url'] : null,
      hasCompletedSetup: json.containsKey('has_completed_setup')
          ? json['has_completed_setup']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (nickname != null) data['nickname'] = nickname;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (hasCompletedSetup != null) {
      data['has_completed_setup'] = hasCompletedSetup;
    }
    return data;
  }
}
