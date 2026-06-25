import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/presentation/widgets/petwise_confirmation_dialog.dart';
import 'package:provider/provider.dart';

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
                Navigator.pop(context); // close the dialog
                Navigator.pushNamed(
                  context,
                  '/UserLoginScreen',
                ); // or whatever your login route is named
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
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_bg.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
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
                            color: Colors.black.withValues(alpha: 0.1),
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
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      final provider = context.read<AuthProvider>();
                                      bool success = await provider.signUp(
                                        SignUpRequest(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text.trim(),
                                        ),
                                      );
                                      if (!mounted) return;
                                      if (success) {
                                        _showEmailValidationDialog();
                                      } else {
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
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
                                      'Create Account',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 0.8,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xffA5927D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      final success =
                                          await authProvider.loginWithGoogle();
                                      if (!mounted) return;
                                      if (success) {
                                        await PetwiseConfirmationDialog.show(
                                          context: context,
                                          success: true,
                                          title: 'Welcome!',
                                          message:
                                              "Your account is ready. Let's check on your pets.",
                                          buttonLabel: 'Let\'s Go',
                                        );
                                        if (mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/UserHomePage',
                                          );
                                        }
                                      }
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xff0B4A72),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 20,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.g_mobiledata,
                                      size: 22,
                                      color: Color(0xff0B4A72),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Continue with Google',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff0B4A72),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
