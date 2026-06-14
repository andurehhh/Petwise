import 'package:flutter/material.dart';

//pages go here
import '../presentation/screens/user_profile_screen.dart';
import '../presentation/screens/user_login_screen.dart';
import '../presentation/screens/login_or_signup_screen.dart';
import '../presentation/screens/edit_user_profile_screen.dart';
import '../presentation/screens/pet_profile_screen.dart';
import '../presentation/screens/edit_pet_profile_screen.dart';
import '../presentation/screens/user_signup_screen.dart';
import '../presentation/screens/user_homepage_screen.dart';
import '../presentation/screens/user_profile_signup_screen.dart';
import '../presentation/screens/pet_card_screen.dart';
import '../presentation/screens/add_pet_profile_screen.dart';
import '../presentation/screens/pet_activity_planner_screen.dart';
import '../presentation/screens/vaccination_screen.dart';
import '../presentation/screens/analytics_screen.dart';
//Create class

class AppRoute {
  static const String userProfile = '/UserProfileScreen';
  static const String userLogin = '/UserLoginScreen';
  static const String loginOrSignup = '/LoginOrSignupScreen';
  static const String editUserProfile = '/EditUserProfileScreen';
  static const String petProfile = '/PetProfileScreen';
  static const String editPetProfile = '/EditPetProfileScreen';
  static const String userHomePage = '/UserHomePage';
  static const String userProfileSignup = '/UserProfileSignupScreen';
  static const String userSignup = '/UserSignupScreen';
  static const String petCardScreen = '/PetCardScreen';
  static const String addPetProfile = '/AddPetProfileScreen';
  static const String petActivityPlanner = '/PetActivityPlannerScreen';
  static const String vaccinationScreen = '/VaccinationScreen';
  static const String analyticsScreen = '/AnalyticsScreen';

  static Map<String, WidgetBuilder> get routes {
    return {
      userProfile: (context) => const UserProfileScreen(),
      userLogin: (context) => const UserLoginScreen(),
      loginOrSignup: (context) => const LoginOrSignupScreen(),
      editUserProfile: (context) => const EditUserProfileScreen(),
      editPetProfile: (context) => const EditPetProfileScreen(),
      petProfile: (context) => const PetProfileScreen(),
      userSignup: (context) => const UserSignupScreen(),
      userProfileSignup: (context) => const UserProfileSignupScreen(),
      userHomePage: (context) => const UserHomePage(),
      petCardScreen: (context) => const PetCardScreen(),
      addPetProfile: (context) => const AddPetProfileScreen(),
      petActivityPlanner: (context) => const PlannerScreen(),
      vaccinationScreen: (context) => const VaccinationScreen(),
      analyticsScreen: (context) => const AnalyticsScreen(),
    };
  }
}
