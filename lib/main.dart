import 'package:flutter/material.dart';
import 'package:petwise/presentation/screens/user_homepage_screen.dart';
import 'package:petwise/presentation/test/auth_test_screen.dart';
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

// New Analytics Features Added Here
import 'package:petwise/services/analytics_service.dart';
import 'package:petwise/providers/analytics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifService().initNotification();

  try {
    await NotifService().cancelAllNotifications(); // clears broken cache
  } catch (_) {}

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
        // Just Added: Analytics Service Hook
        ProxyProvider<ApiClient, AnalyticsService>(
          update: (_, client, _) => AnalyticsService(client),
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

        ChangeNotifierProxyProvider<AnalyticsService, AnalyticsProvider>(
          create: (context) =>
              AnalyticsProvider(context.read<AnalyticsService>()),
          update: (_, analyticsService, analyticsProvider) {
            analyticsProvider!.updateAnalyticsService(analyticsService);
            return analyticsProvider;
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
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFF7A433),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7A433),
          primary: const Color(0xFFF7A433),
          surfaceTint: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A2D40)),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFF7A433),
          selectionColor: Color(0x4DF7A433),
          selectionHandleColor: Color(0xFFF7A433),
        ),
      ),
      initialRoute: AppRoute.loginOrSignup,
      routes: AppRoute.routes,
      home: UserHomePage(),
      //home: AuthTestScreen(),
    );
  }
}
