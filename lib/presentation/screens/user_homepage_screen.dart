import 'package:flutter/material.dart';
import '../widgets/petwise_pet_profile.dart';
import '../widgets/petwise_activity_card.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageScreenState();
}

class _UserHomePageScreenState extends State<UserHomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      appBar: const PetWiseAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              "Good morning, Mia!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            Text(
              "They are having a great day so far.",
              style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xffF6EEE4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pets",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    overlayColor: Colors.transparent,
                  ),
                  child: Text(
                    "See all",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PetCircle(
                  imagePath: 'assets/images/dog.png',
                  petName: 'Draeco',
                  petType: 'Pomeranian',
                ),
                PetCircle(
                  imagePath: 'assets/images/cat.png',
                  petName: 'Rence',
                  petType: 'British Shorthair',
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Upcoming Activities",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    overlayColor: Colors.transparent,
                  ),
                  child: Text(
                    "See all",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const ActivityCard(title: 'Vet Appointment', subtitle: '10:00 AM'),
            const ActivityCard(title: 'Grooming', subtitle: '2:00 PM'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFFF7A433),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: PetwiseNavbar(navbarIndex: 1),
    );
  }
}
