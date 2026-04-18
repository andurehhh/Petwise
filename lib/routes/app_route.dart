import 'package:flutter/material.dart';

//pages go here
import '../presentation/screens/user_profile_screen.dart';
import '../presentation/screens/user_login_screen.dart';
import '../presentation/screens/login_or_signup_screen.dart';
import '../presentation/screens/edit_user_profile_screen.dart';
import '../presentation/screens/pet_profile_screen.dart';
import '../presentation/screens/edit_pet_profile_screen.dart';

//Create class



class AppRoute {
  static const String userProfile = '/UserProfileScreen';
  static const String userLogin = '/UserLoginScreen';
  static const String loginOrSignup = '/LoginOrSignupScreen';
  static const String editUserProfile = '/EditUserProfileScreen';
  static const String petProfile = '/PetProfileScreen';
  static const String editPetProfile = '/EditPetProfileScreen';

  static Map<String, WidgetBuilder> get routes {
    return {
      userProfile: (context) => const UserProfileScreen(),
      userLogin: (context) => const UserLoginScreen(),
      loginOrSignup: (context) => const LoginOrSignupScreen(),
      editUserProfile: (context) => const EditUserProfileScreen(),
      editPetProfile: (context) => const EditPetProfileScreen(),
      petProfile: (context) => const PetProfileScreen()
    };
  }
}
