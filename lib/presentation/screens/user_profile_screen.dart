import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:petwise/presentation/widgets/petwise_Navbar.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/presentation/widgets/petwise_user_image_picker.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/data/models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId;

    print("DEBUG: Fetching profile for ID: $currentUserId");

    if (currentUserId != null && currentUserId.isNotEmpty) {
      userProvider.loadUser(currentUserId);
    } else {
      print("DEBUG: Cannot load user because ID is null in AuthProvider");
    }
  }

  void _openUserImagePicker(BuildContext context, UserModel currentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PetwiseUserImagePickerSheet(
        currentImageUrl: currentUser.image_url ?? "",
        onImageSelected: (newImageUrl) async {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final success = await userProvider.updateProfile(
            firstName: currentUser.firstName ?? '',
            lastName: currentUser.lastName ?? '',
            nickname: currentUser.nickname ?? '',
            image_url: newImageUrl,
          );

          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to update profile image: ${userProvider.error}',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A2D40)),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Interactive avatar image container
              GestureDetector(
                onTap: () => _openUserImagePicker(context, user),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 72,
                      backgroundColor: const Color(0xFFF7A433),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(0xffF6EEE4),
                        child: ClipOval(
                          child:
                              (user.image_url != null &&
                                  user.image_url!.isNotEmpty)
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF7A433),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "${user.nickname ?? 'User Name'}",
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                            textHint: "${user.firstName ?? ''}",
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Last Name",
                            textHint: "${user.lastName ?? ''}",
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Email",
                            textHint: "${user.email ?? ''}",
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
                                  onPressed: () {},
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
