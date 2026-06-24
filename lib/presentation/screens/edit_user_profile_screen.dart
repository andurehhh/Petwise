import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/presentation/widgets/petwise_user_image_picker.dart';
import 'package:petwise/providers/user_provider.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nicknameController;
  String? _temporarySelectedImageUrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? "");
    _lastNameController = TextEditingController(text: user?.lastName ?? "");
    _nicknameController = TextEditingController(text: user?.nickname ?? "");
    _temporarySelectedImageUrl = user?.image_url;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _openUserImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => PetwiseUserImagePickerSheet(
        currentImageUrl: _temporarySelectedImageUrl ?? "",
        onImageSelected: (newImageUrl) {
          setState(() {
            _temporarySelectedImageUrl = newImageUrl;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openUserImagePicker(context),
                child: CircleAvatar(
                  radius: 72,
                  backgroundColor: const Color(0xFFF7A433),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color(0xffF6EEE4),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          if (_temporarySelectedImageUrl != null &&
                              _temporarySelectedImageUrl!.isNotEmpty)
                            Image.network(
                              _temporarySelectedImageUrl!,
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
                          else
                            Image.asset(
                              'assets/images/SUA.jpg',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          Container(
                            color: Colors.black38,
                            width: 140,
                            height: 140,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 300,
                child: TextField(
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter nickname",
                  ),
                  controller: _nicknameController,
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
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "USER INFORMATION",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF92A1B7),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PetwiseUserTextfield(
                        textLabel: "First Name",
                        textHint: "Enter first name",
                        isEditable: true,
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 12),
                      PetwiseUserTextfield(
                        textLabel: "Last Name",
                        textHint: "Enter last name",
                        isEditable: true,
                        controller: _lastNameController,
                      ),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Column(
                            children: [
                              PetwiseUserTextfield(
                                textLabel: "Email",
                                textHint:
                                    userProvider.user?.email ??
                                    "No Email Registered",
                                isEditable: false,
                              ),
                              const SizedBox(height: 32),
                              FilledButton(
                                onPressed: userProvider.isLoading
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final navigator = Navigator.of(context);

                                        bool success = await userProvider
                                            .updateProfile(
                                              firstName: _firstNameController
                                                  .text
                                                  .trim(),
                                              lastName: _lastNameController.text
                                                  .trim(),
                                              nickname: _nicknameController.text
                                                  .trim(),
                                              image_url:
                                                  _temporarySelectedImageUrl,
                                            );

                                        if (success) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text("Profile Updated!"),
                                              backgroundColor:
                                                  Colors.lightGreen,
                                            ),
                                          );
                                          navigator.pop(context);
                                        } else {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                userProvider.error ??
                                                    "Failed to update profile",
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  backgroundColor: const Color(0xFFF7A433),
                                  side: const BorderSide(
                                    color: Color(0xFFDA9B44),
                                    width: 2,
                                  ),
                                ),
                                child: userProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "SAVE CHANGES",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(
                            color: Color(0xFFF7A433),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          "CANCEL",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFF7A433),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
