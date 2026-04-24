import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/routes/app_route.dart';

class PetWiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PetWiseAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffF8F7F6),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 13,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 35),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(top: 9.0),
            child: Text(
              'PetWise',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.black, size: 25),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoute.userProfile);
          },
          icon: const Icon(Icons.person_outline, color: Colors.black, size: 25),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}