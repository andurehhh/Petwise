import 'package:flutter/material.dart';

class LoginOrSignupScreen extends StatefulWidget {
  const LoginOrSignupScreen({super.key});

  @override
  State<LoginOrSignupScreen> createState() => _LoginOrSignupScreenState();
}

class _LoginOrSignupScreenState extends State<LoginOrSignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_or_signup_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffF4AD44),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  // Navigate to signup screen
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 35),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
