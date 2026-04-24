class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? nickname;

  UpdateUserRequest({this.firstName, this.lastName, this.nickname});

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRequest(
      firstName: json.containsKey('first_name') ? json['first_name'] : null,
      lastName: json.containsKey('last_name') ? json['last_name'] : null,
      nickname: json.containsKey('nickname') ? json['nickname'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (nickname != null) data['nickname'] = nickname;

    return data;
  }
}
