import 'package:flutter/material.dart';
import 'package:petwise/data/models/user_model.dart';

class UserProvider extends ChangeNotifier{
  UserModel? _user;
  UserModel? get user => _user;

  void updateName(String newName){
    if (_user != null){
      _user!.firstName = newName;
      notifyListeners();
    }
  }
}