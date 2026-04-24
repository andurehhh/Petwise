import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:petwise/data/models/user_model.dart';

class UserProfileSignupScreen extends StatefulWidget {
  const UserProfileSignupScreen({super.key});

  @override
  State<UserProfileSignupScreen> createState() =>
      _UserProfileSignupScreenState();
}

class _UserProfileSignupScreenState extends State<UserProfileSignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  String? _profileImageUrl;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _pickImage() {
    print("Open Gallery/Camera");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.back),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffF4AD44),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: PetwiseUserTextfield(
                        textLabel: 'FIRST NAME',
                        textHint: 'First name',
                        isEditable: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PetwiseUserTextfield(
                        textLabel: 'LAST NAME',
                        textHint: 'Last name',
                        isEditable: true,
                      ),
                    ),
                  ],
                ),
                PetwiseUserTextfield(
                  textLabel: 'EMAIL',
                  textHint: 'google-email@example.com',
                  isEditable: false,
                ),
                PetwiseUserTextfield(
                  textLabel: 'NICKNAME',
                  textHint: 'Optional nickname',
                  isEditable: true,
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/UserHomePage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF4AD44),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(180, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
