import 'package:flutter/material.dart';
import 'package:petwise/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user = UserModel(
    id: "100",
    firstName: "Andre",
    lastName: "Almazora",
    email: "andrealmazora19@gmail.com",
    nickname: "Hiyuki",
  );

  UserModel? get user => _user;

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateUserInfo(
    String newFirstName,
    String newLastName,
    String newNickname,
  ) {
    if (_user != null) {
      _user = UserModel(
        id: _user!.id,
        firstName: newFirstName.trim().isNotEmpty
            ? newFirstName.trim()
            : _user!.firstName,
        lastName: newLastName.trim().isNotEmpty
            ? newLastName.trim()
            : _user!.lastName,
        email: _user!.email,
        // dbId: _user!.dbId,
        // profileImageUrl: _user!.profileImageUrl,
        nickname: newNickname.trim().isNotEmpty
            ? newNickname.trim()
            : _user!.nickname,
      );

      print("Provider: Updated user to ${_user!.firstName} ${_user!.lastName}");
      notifyListeners();
    }
  }

  // void updatePicture(String pictureUrl) {
  //   if (_user != null) {
  //     _user!.profileImageUrl = pictureUrl;
  //     notifyListeners();
  //   }
  // }
}
