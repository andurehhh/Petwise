import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/presentation/screens/edit_user_profile_screen.dart';
import 'package:petwise/presentation/widgets/petwise_confirmation_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      userProvider.loadUser(currentUserId);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xffFFF9EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A2D40),
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xffA5927D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);

    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final navigator = Navigator.of(context);

    await authProvider.logout(
      petProvider: petProvider,
      activityProvider: activityProvider,
    );

    if (!mounted) return;
    setState(() => _loggingOut = false);

    await PetwiseConfirmationDialog.show(
      context: context,
      success: true,
      title: 'Logged Out',
      message: "You've been signed out successfully.",
    );

    navigator.pushNamedAndRemoveUntil('/LoginOrSignupScreen', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (userProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F7F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF7A433)),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F6),
        body: Center(
          child: Text(
            "User profile could not be loaded.\nError: ${userProvider.error}",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Colors.red.shade700),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F7F6),
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A2D40)),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF1A2D40)),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditUserProfileScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 72,
                    backgroundColor: const Color(0xFFF7A433),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xffF6EEE4),
                      child: ClipOval(
                        child: (user.image_url != null &&
                                user.image_url!.isNotEmpty)
                            ? Image.network(
                                user.image_url!,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/SUA.jpg',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/SUA.jpg',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.nickname ?? 'User Name',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                      color: const Color(0xFF1A2D40),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 150,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCDCDC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "USER INFORMATION",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: const Color(0xFF92A1B7),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PetwiseUserTextfield(
                            textLabel: "First Name",
                            textHint: user.firstName ?? '',
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Last Name",
                            textHint: user.lastName ?? '',
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Email",
                            textHint: user.email ?? '',
                          ),
                          const SizedBox(height: 40),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    final auth = context.read<AuthProvider>();
                                    auth.clearError();
                                    showDialog(
                                      context: context,
                                      builder: (_) => _ChangePasswordDialog(
                                        authProvider: auth,
                                      ),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    backgroundColor: const Color(0xFF1A2D40),
                                  ),
                                  child: Text(
                                    "Change Password",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: _confirmLogout,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      overlayColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      'Log Out',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loggingOut) const _DarkLoader(label: 'Signing you out...'),
      ],
    );
  }
}

class _DarkLoader extends StatefulWidget {
  final String label;
  const _DarkLoader({required this.label});

  @override
  State<_DarkLoader> createState() => _DarkLoaderState();
}

class _DarkLoaderState extends State<_DarkLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0E1A).withValues(alpha: 0.82),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Image.asset(
                  'assets/images/logo_no_name.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFF1A2D40),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'PetWise',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AuthProvider authProvider;

  const _ChangePasswordDialog({required this.authProvider});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authProvider,
      builder: (context, _) {
        final errorMsg = _localError ?? widget.authProvider.error;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color(0xffFFF9EE),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2D40).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF1A2D40),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Change Password',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xff0B4A72),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                PetwiseUserTextfield(
                  textLabel: 'CURRENT',
                  textHint: 'Current password',
                  isEditable: true,
                  controller: _currentCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                PetwiseUserTextfield(
                  textLabel: 'NEW',
                  textHint: 'New password',
                  isEditable: true,
                  controller: _newCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                PetwiseUserTextfield(
                  textLabel: 'CONFIRM',
                  textHint: 'Confirm password',
                  isEditable: true,
                  controller: _confirmCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          errorMsg,
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
                    onPressed: widget.authProvider.isLoading
                        ? null
                        : () async {
                            setState(() => _localError = null);
                            widget.authProvider.clearError();

                            final current = _currentCtrl.text.trim();
                            final newPass = _newCtrl.text.trim();
                            final confirm = _confirmCtrl.text.trim();

                            if (current.isEmpty ||
                                newPass.isEmpty ||
                                confirm.isEmpty) {
                              setState(
                                () =>
                                    _localError = 'Please fill in all fields.',
                              );
                              return;
                            }
                            if (newPass != confirm) {
                              setState(
                                () => _localError = 'Passwords do not match.',
                              );
                              return;
                            }
                            if (newPass.length < 6) {
                              setState(
                                () => _localError = 'Min. 6 characters.',
                              );
                              return;
                            }

                            final success =
                                await widget.authProvider.changePassword(
                              current,
                              newPass,
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            await PetwiseConfirmationDialog.show(
                              context: context,
                              success: success,
                              title: success
                                  ? 'Password Changed'
                                  : 'Change Failed',
                              message: success
                                  ? 'Your password has been updated.'
                                  : widget.authProvider.error ??
                                      'Something went wrong.',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2D40),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: widget.authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Done',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
