import 'package:flutter/material.dart';
import 'package:petwise/providers/PetProvider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import '../widgets/petwise_pet_profile.dart';
import '../widgets/petwise_activity_card.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageScreenState();
}



class _UserHomePageScreenState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Get the current user's ID
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.user?.id;

      // 2. Fetch the pets for this user
      if (userId != null) {
        context.read<PetProvider>().loadUserPets(userId);
      }
      print(userId);

    });
  }

  @override
  Widget build(BuildContext context) {
    final petList = context.watch<PetProvider>().pets;
    final activityList = context.watch<ActivityProvider>().activities;

    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      appBar: const PetWiseAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              "Good morning, Mia!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "They are having a great day so far.",
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xffF6EEE4),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Pets",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/PetCardScreen'),
                  child: Text(
                    "See all",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffF4AD44),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 25,
              runSpacing: 20,
              alignment: WrapAlignment.start,
              children: petList.map((pet) {
                return GestureDetector(
                  onTap: () {
                    context.read<PetProvider>().selectPet(pet);
                  },
                  child: PetCircle(
                    imagePath: 'assets/images/${pet.name.toLowerCase()}.png',
                    petName: pet.name,
                    petType: pet.species,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Upcoming Activities",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "See all",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffF4AD44),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activityList.length,
              itemBuilder: (context, index) {
                final activity = activityList[index];
                final timeString = DateFormat.jm().format(
                  activity.scheduledDate,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ActivityCard(
                    title: activity.title,
                    subtitle: timeString,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF7A433),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 0),
    );
  }
}
