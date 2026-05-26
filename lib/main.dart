import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/notif_service.dart';
import 'package:petwise/services/notification_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';
import 'package:petwise/services/activity_service.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/routes/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService().init();
  await NotifService().initNotification();


  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),

        // Services
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, _) => AuthService(client),
        ),
        ProxyProvider<ApiClient, UserService>(
          update: (_, client, _) => UserService(client),
        ),
        ProxyProvider<ApiClient, PetService>(
          update: (_, client, _) => PetService(client),
        ),
        ProxyProvider<ApiClient, ActivityService>(
          update: (_, client, _) => ActivityService(client),
        ),

        // Providers
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, userService, userProvider) {
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
        ChangeNotifierProxyProvider<ActivityService, ActivityProvider>(
          create: (context) => ActivityProvider(),
          update: (context, activityService, activityProvider) {
            activityProvider!.updateActivityService(activityService);
            return activityProvider;
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
      initialRoute: AppRoute.loginOrSignup,
      routes: AppRoute.routes,
      home: UserHomePage(),
    );
  }
}
