import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/petwise_user_textField.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showEmailValidationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xffFFF9EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Email Validation',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xff0B4A72),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            "We're waiting for your email validation.",
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xffA5927D),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/UserProfileSignupScreen');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/LoginOrSignupScreen');
                  },
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 180),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF9EE),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to PetWise!',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xff0B4A72),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        'Create an account to check on your pets.',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xffA5927D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          PetwiseUserTextfield(
                            textLabel: 'EMAIL',
                            textHint: 'Enter your email address',
                            isEditable: true,
                            controller: _emailController,
                          ),
                          PetwiseUserTextfield(
                            textLabel: 'PASSWORD',
                            textHint: 'Enter your password',
                            isEditable: true,
                            controller: _passwordController,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                // Use read instead of watch inside the function to prevent unnecessary rebuilds during the async call
                                final provider = context.read<AuthProvider>();

                                bool success = await provider.signUp(
                                  SignUpRequest(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );

                                if (!mounted) return;

                                if (success) {
                                  // Success! Show the dialog.
                                  _showEmailValidationDialog();
                                } else {
                                  // Only show the SnackBar if success is FALSE
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.error ?? "Signup failed",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF4AD44),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'CREATE ACCOUNT',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
