import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/presentation/screens/edit_user_profile_screen.dart'; // Ensure correct path

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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

    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1A2D40)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditUserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 72,
                backgroundColor: const Color(0xFFF7A433),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xffF6EEE4),
                  child: ClipOval(
                    child:
                        (user.image_url != null && user.image_url!.isNotEmpty)
                        ? Image.network(
                            user.image_url!,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 800,
                              minWidth: 40,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 30),
                                FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(300, 50),
                                    backgroundColor: const Color(0xFFF7A433),
                                    side: const BorderSide(
                                      color: Color(0xFFDA9B44),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "FORGOT PASSWORD",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                OutlinedButton(
                                  onPressed: () async {
                                    final authProvider = context
                                        .read<AuthProvider>();
                                    final petProvider = context
                                        .read<PetProvider>();
                                    final activityProvider = context
                                        .read<ActivityProvider>();
                                    final navigator = Navigator.of(context);

                                    await authProvider.logout(
                                      petProvider: petProvider,
                                      activityProvider: activityProvider,
                                    );
                                    navigator.pushNamedAndRemoveUntil(
                                      '/LoginOrSignupScreen',
                                      (route) => false,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(300, 50),
                                    side: const BorderSide(
                                      color: Color(0xFFF7A433),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "LOG OUT",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFF7A433),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
