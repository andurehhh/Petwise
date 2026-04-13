import 'package:flutter/material.dart';

//pages go here
import '../presentation/screens/user_profile_screen.dart';
import '../presentation/screens/edit_user_profile_screen.dart';
//Create class

class AppRoute {
  static const String userProfile ='/UserProfileScreen';
  static const String editUserProfile ='/EditUserProfileScreen';

  static Map<String, WidgetBuilder> get routes {

    return{
      userProfile: (context) => const UserProfileScreen(),
      editUserProfile: (context) => const EditUserProfileScreen(),
  };

  }
}
