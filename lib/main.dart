import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
import 'package:petwise/providers/vaccination_provider.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/notif_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';
import 'package:petwise/services/activity_service.dart';
import 'package:petwise/services/health_event_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService().init();
  await NotifService().initNotification();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
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
        ProxyProvider<ApiClient, HealthEventService>(
          update: (_, client, _) => HealthEventService(client),
        ),
        ChangeNotifierProxyProvider<UserService, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, userService, userProvider) {
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
          create: (context) =>
              ActivityProvider(context.read<ActivityService>()),
          update: (_, activityService, activityProvider) {
            activityProvider!.updateActivityService(activityService);
            return activityProvider;
          },
        ),
        ChangeNotifierProxyProvider<HealthEventService, HealthEventProvider>(
          create: (_) => HealthEventProvider(),
          update: (_, healthEventService, healthEventProvider) {
            healthEventProvider!.updateHealthEventService(healthEventService);
            return healthEventProvider;
          },
        ),
        ChangeNotifierProxyProvider<HealthEventService, VaccinationProvider>(
          create: (_) => VaccinationProvider(),
          update: (_, healthEventService, vaccinationProvider) {
            vaccinationProvider!.updateHealthEventService(healthEventService);
            return vaccinationProvider;
          },
        ),
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
