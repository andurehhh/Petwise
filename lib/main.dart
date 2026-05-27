import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/notif_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';
import 'package:petwise/services/activity_service.dart';
<<<<<<< HEAD
import 'package:petwise/services/health_event_service.dart';
=======
>>>>>>> 4f1e79f90fa6c73255530a635373d13edfc24ce8
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService().init();
  await NotifService().initNotification();


  runApp(
    MultiProvider(
      providers: [
<<<<<<< HEAD
        Provider<ApiClient>(create: (_) => ApiClient()),
=======
        Provider(create: (_) => ApiClient()),

        // Services
>>>>>>> 4f1e79f90fa6c73255530a635373d13edfc24ce8
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, __) => AuthService(client),
        ),
        ProxyProvider<ApiClient, UserService>(
          update: (_, client, __) => UserService(client),
        ),
        ProxyProvider<ApiClient, PetService>(
          update: (_, client, __) => PetService(client),
        ),
        ProxyProvider<ApiClient, ActivityService>(
          update: (_, client, __) => ActivityService(client),
        ),
        ProxyProvider<ApiClient, HealthEventService>(
          update: (_, client, __) => HealthEventService(client),
        ),
<<<<<<< HEAD
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, userService, userProvider) {
=======
        ProxyProvider<ApiClient, ActivityService>(
          update: (_, client, _) => ActivityService(client),
        ),

        // Providers
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, userService, userProvider) {
>>>>>>> 4f1e79f90fa6c73255530a635373d13edfc24ce8
            userProvider!.updateUserService(userService);
            return userProvider;
          },
        ),
        ChangeNotifierProxyProvider<PetService, PetProvider>(
          create: (_) => PetProvider(),
          update: (_, petService, petProvider) {
            petProvider!.updatePetService(petService);
            return petProvider;
          },
        ),
        ChangeNotifierProxyProvider<ActivityService, ActivityProvider>(
<<<<<<< HEAD
          create: (context) =>
              ActivityProvider(context.read<ActivityService>()),
          update: (_, activityService, activityProvider) {
=======
          create: (context) => ActivityProvider(),
          update: (context, activityService, activityProvider) {
>>>>>>> 4f1e79f90fa6c73255530a635373d13edfc24ce8
            activityProvider!.updateActivityService(activityService);
            return activityProvider;
          },
        ),
<<<<<<< HEAD
        ChangeNotifierProxyProvider<HealthEventService, HealthEventProvider>(
          create: (_) => HealthEventProvider(),
          update: (_, healthEventService, healthEventProvider) {
            healthEventProvider!.updateHealthEventService(healthEventService);
            return healthEventProvider;
          },
        ),
=======
>>>>>>> 4f1e79f90fa6c73255530a635373d13edfc24ce8
        ChangeNotifierProxyProvider2<AuthService, UserProvider, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserProvider>(),
          ),
          update: (_, authService, userProvider, authProvider) {
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
