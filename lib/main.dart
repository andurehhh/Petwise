import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/presentation/test/auth_test_screen.dart';
import 'package:petwise/providers/PetProvider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/routes/app_route.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.userLogin,
      routes: AppRoute.routes,
      home: UserHomePage(),
      //home: AuthTestScreen(),
    );
  }
}
