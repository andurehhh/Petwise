import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/presentation/widgets/petwise_confirmation_dialog.dart';
import 'package:petwise/presentation/widgets/petwise_onboarding_flow.dart';
import 'package:provider/provider.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider authProvider) async {
    authProvider.clearError();
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      authProvider.setError('Please fill in all fields.');
      return;
    }
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final user = context.read<UserProvider>().user;
      if (user != null && !user.hasCompletedSetup) {
        await showOnboardingFlow(context);
        if (mounted) {
          final updatedUser = context.read<UserProvider>().user;
          if (updatedUser != null && updatedUser.hasCompletedSetup) {
            return;
          }
          Navigator.pushReplacementNamed(context, '/UserHomePage');
        }
      } else {
        await PetwiseConfirmationDialog.show(
          context: context,
          success: true,
          title: 'Welcome Back!',
          message: "You're in. Let's check on your pets.",
          buttonLabel: "Let's Go",
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/UserHomePage');
      }
    }
  }

  void _showForgotPasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    _forgotEmailController.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ForgotPasswordDialog(
        emailController: _forgotEmailController,
        authProvider: authProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        authProvider.clearError();
                        Navigator.pushNamed(context, '/LoginOrSignupScreen');
                      },
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 210),
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
                          'Welcome Back!',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xff0B4A72),
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Login to check on your pets.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xffA5927D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (authProvider.error != null)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: authProvider.clearError,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        PetwiseUserTextfield(
                          textLabel: 'EMAIL',
                          textHint: 'Enter your email address',
                          isEditable: true,
                          controller: _emailController,
                          textInputAction: TextInputAction.next,
                        ),
                        PetwiseUserTextfield(
                          textLabel: 'PASSWORD',
                          textHint: 'Enter your password',
                          isEditable: true,
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: authProvider.isLoading
                              ? null
                              : () => _login(authProvider),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(
                                context,
                                authProvider,
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xffA5927D),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _login(authProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffF4AD44),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                      final user =
                                          context.read<UserProvider>().user;
                                      if (user != null &&
                                          !user.hasCompletedSetup) {
                                        await showOnboardingFlow(context);
                                        if (mounted) {
                                          final updatedUser = context
                                              .read<UserProvider>()
                                              .user;
                                          if (updatedUser != null &&
                                              updatedUser.hasCompletedSetup) {
                                            return;
                                          }
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/UserHomePage',
                                          );
                                        }
                                      } else {
                                        await PetwiseConfirmationDialog.show(
                                          context: context,
                                          success: true,
                                          title: 'Welcome Back!',
                                          message:
                                              "You're in. Let's check on your pets.",
                                          buttonLabel: "Let's Go",
                                        );
                                        if (mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/UserHomePage',
                                          );
                                        }
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
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
        if (authProvider.isLoading) const _PetwiseLoader(label: 'Signing you in...'),
      ],
    );
  }
}

class _PetwiseLoader extends StatelessWidget {
  final String label;
  const _PetwiseLoader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo_no_name.png',
                width: 88,
                height: 88,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'PetWise',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                value: null,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(8),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final TextEditingController emailController;
  final AuthProvider authProvider;

  const _ForgotPasswordDialog({
    required this.emailController,
    required this.authProvider,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xffFFF9EE),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: _sent
            ? _SentView(onDone: () => Navigator.pop(context))
            : _EmailInputView(
                emailController: widget.emailController,
                authProvider: widget.authProvider,
                onSent: () => setState(() => _sent = true),
              ),
      ),
    );
  }
}

class _EmailInputView extends StatelessWidget {
  final TextEditingController emailController;
  final AuthProvider authProvider;
  final VoidCallback onSent;

  const _EmailInputView({
    required this.emailController,
    required this.authProvider,
    required this.onSent,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authProvider,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF7A433).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFFF7A433),
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Forgot Password?',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xff0B4A72),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email and we\'ll send you a reset link.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xffA5927D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            PetwiseUserTextfield(
              textLabel: 'EMAIL',
              textHint: 'example@email.com',
              isEditable: true,
              controller: emailController,
              textInputAction: TextInputAction.done,
            ),
            if (authProvider.error != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      authProvider.error!,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          authProvider.setError(
                            'Please enter your email address.',
                          );
                          return;
                        }
                        authProvider.clearError();
                        final success =
                            await authProvider.forgotPassword(email);
                        if (success) onSent();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF4AD44),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SentView extends StatelessWidget {
  final VoidCallback onDone;
  const _SentView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Color(0xFF4CAF50),
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Check Your Inbox',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xff0B4A72),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A reset link has been sent. Check your spam too.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xffA5927D),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF4AD44),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
