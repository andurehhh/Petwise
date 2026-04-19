import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:flutter/cupertino.dart';

class UserProfileSignupScreen extends StatefulWidget {
  const UserProfileSignupScreen({super.key});

  @override
  State<UserProfileSignupScreen> createState() =>
      _UserProfileSignupScreenState();
}

class _UserProfileSignupScreenState extends State<UserProfileSignupScreen> {
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(CupertinoIcons.back),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffF4AD44),
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/SUA.jpg'),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: PetwiseUserTextfield(
                        textLabel: 'FIRST NAME',
                        textHint: '',
                        isEditable: true,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: PetwiseUserTextfield(
                        textLabel: 'LAST NAME',
                        textHint: '',
                        isEditable: true,
                      ),
                    ),
                  ],
                ),

                PetwiseUserTextfield(
                  textLabel: 'NICKNAME',
                  textHint: '',
                  isEditable: true,
                ),

                PetwiseUserTextfield(
                  textLabel: 'PHONE NUMBER',
                  textHint: '',
                  isEditable: true,
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/UserHomePage');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF4AD44),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
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
