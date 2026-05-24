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

  // proxyProvider
  void updateUserService(UserService service) {
    _userService = service;
  }

  Future<void> loadUser(String id) async {
    if (_user != null && _user!.id == id) {
      return;
    }

    if (_userService == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _userService!.getUser(id);
      _user = _mapResponseToModel(response);
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
    String? image_url, // FIXED: Changed to snake_case style
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
        image_url: image_url ?? _user!.image_url,
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

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updatePicture(String pictureUrl) {
    if (_user != null) {
      _user = UserModel(
        id: _user!.id,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        email: _user!.email,
        nickname: _user!.nickname,
        image_url: pictureUrl,
      );
      notifyListeners();
    }
  }

  UserModel _mapResponseToModel(UserResponse response) {
    return UserModel(
      id: response.userId,
      firstName: response.firstName ?? 'Guest',
      lastName: response.lastName ?? '',
      email: response.email,
      nickname: response.nickname,
      image_url: response.image_url,
    );
  }
}
