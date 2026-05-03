import 'package:flutter/material.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/presentation/test/auth_test_screen.dart';
import 'package:petwise/providers/AuthProvider.dart';
import 'package:petwise/providers/PetProvider.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';
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
        Provider(create: (_) => ApiClient()),

        // Services
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, __) => AuthService(client),
        ),
        ProxyProvider<ApiClient, UserService>(
          update: (_, client, __) => UserService(client),
        ),
        ProxyProvider<ApiClient, PetService>(
          update: (_, client, __) => PetService(client),
        ),

        // Providers
        // 1. UserProvider needs to "watch" UserService
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, userService, userProvider) {
            // This is the missing handshake!
            userProvider!.updateUserService(userService);
            return userProvider;
          },
        ),

        ChangeNotifierProxyProvider<PetService, PetProvider>(
          create: (context) => PetProvider(),
          update: (context, petService, petProvider) {
            petProvider!.updatePetService(petService);
            return petProvider;
          },
        ),
        ChangeNotifierProxyProvider2<AuthService, UserProvider, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserProvider>(),
          ),
          update: (context, authService, userProvider, authProvider) {
            authProvider!.updateDependencies(authService, userProvider);
            return authProvider;
          },
        ),
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
      //initialRoute: AppRoute.loginOrSignup,
      routes: AppRoute.routes,
      //home: UserHomePage(),
      home: AuthTestScreen(),
    );
  }
}
