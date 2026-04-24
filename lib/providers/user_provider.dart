import 'package:flutter/material.dart';
import 'package:petwise/contracts/user/update_user_request.dart';
import 'package:petwise/contracts/user/user_response.dart';
import 'package:petwise/data/models/user_model.dart';
import 'package:petwise/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserService? _userService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get userId => _user?.id;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  //proxyProvider
  void updateUserService(UserService service) {
    _userService = service;
  }

  Future<void> loadUser(String id) async{
    if (_userService == null) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService!.getUser(id);
      _user = _mapResponseToModel(response);

      print("DEBUG PROVIDER: _user.id is ${_user?.id}");
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String nickname,
  }) async {
    if (_userService == null || _user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateUserRequest(
        firstName: firstName,
        lastName: lastName,
        nickname: nickname,
      );

      final response = await _userService!.updateUser(_user!.id, request);

      _user = _mapResponseToModel(response);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }


  // UserModel? _user= UserModel(
  //   id: "cc",
  //   firstName: "Andre",
  //   lastName: "Almazora",
  //   email: "andrealmazora19@gmail.com",
  //   nickname: "Hiyuki",
  // );

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  // void updateUserInfo(
  //   String newFirstName,
  //   String newLastName,
  //   String newNickname,
  //     )
  // {
  //   if (_user != null) {
  //     _user = UserModel(
  //       id: _user!.id,
  //       firstName: newFirstName.trim().isNotEmpty
  //           ? newFirstName.trim()
  //           : _user!.firstName,
  //       lastName: newLastName.trim().isNotEmpty
  //           ? newLastName.trim()
  //           : _user!.lastName,
  //       email: _user!.email,
  //       // dbId: _user!.dbId,
  //       // profileImageUrl: _user!.profileImageUrl,
  //       nickname: newNickname.trim().isNotEmpty
  //           ? newNickname.trim()
  //           : _user!.nickname,
  //     );
  //
  //     print("Provider: Updated user to ${_user!.firstName} ${_user!.lastName}");
  //     notifyListeners();
  //   }
  // }

  // void updatePicture(String pictureUrl) {
  //   if (_user != null) {
  //     _user!.profileImageUrl = pictureUrl;
  //     notifyListeners();
  //   }
  // }

UserModel _mapResponseToModel(UserResponse response){
    return UserModel(
      id: response.userId,
      firstName: response.firstName ?? 'Guest',
      lastName: response.lastName ?? '',
      email: response.email,
      nickname: response.nickname,
    );
}
}
