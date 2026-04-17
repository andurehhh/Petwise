class UserModel {
  final String id;
  String firstName;
  String lastName;
  final String email;
  final String dbId;
  String? profileImageUrl;

  UserModel({
   required this.id,
   required this.firstName,
   required this.lastName,
   required this.email,
   required this.dbId,
   this.profileImageUrl,
});

  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['LastName'],
        email: json['Email'],
        dbId: json['dbId'],
        profileImageUrl: json['profileImageUrl'],
);
  }

  Map<String,dynamic> toJson(){
    return {
      'id':id,
      'firstName':firstName,
      'lastName':lastName,
      'email':email,
      'profileImageUrl':profileImageUrl
    };
  }

}