import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/routes/app_route.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AppRoute.loginOrSignup,
      routes: AppRoute.routes,
    );
  }
}
