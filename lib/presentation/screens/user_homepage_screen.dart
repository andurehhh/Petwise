import 'package:flutter/material.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import '../widgets/petwise_pet_profile.dart';
import '../widgets/petwise_dynamic_activity_card.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pet_activity_planner_screen.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageScreenState();
}

class _UserHomePageScreenState extends State<UserHomePage> {
  // lib/presentation/screens/user_homepage_screen.dart

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      final petProvider = context.read<PetProvider>();
      final activityProvider = context.read<ActivityProvider>();

      if (userProvider.user?.id != null) {
        // 1. Load pets first
        await petProvider.loadUserPets(userProvider.user!.id);

        // 2. Get the loaded pet IDs
        final petIds = petProvider.pets.map((p) => p.id).toList();

        // 3. Load all activities for these pets
        if (petIds.isNotEmpty) {
          await activityProvider.loadAllActivities(petIds);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final petList = context.watch<PetProvider>().pets;

    final activityProvider = context.watch<ActivityProvider>();
    final activityList = activityProvider.activities
        .where((a) => !a.isCompleted || activityProvider.recentlyCompletedIds.contains(a.id))
        .toList();

// Use activityProvider.isLoading to show a spinner if you want
    if (activityProvider.isLoading && activityList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final String displayName = user?.nickname ?? user?.firstName ?? "User";

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
              "Good morning, $displayName!",
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
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 20,
                children: petList.map((pet) {
                  return GestureDetector(
                    onTap: () {
                      Future.microtask(() {
                        context.read<PetProvider>().selectPet(pet);
                        Navigator.pushNamed(context, '/PetCardScreen');
                      });
                    },
                    child: PetCircle(
                      // FIXED: Passing the real network URL or path instead of an empty string
                      imagePath: pet.image_url ?? '',
                      petName: pet.name,
                      petType: pet.species,
                    ),
                  );
                }).toList(),
              ),
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
                  onTap: () {
                    Future.microtask(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlannerScreen(),
                        ),
                      );
                    });
                  },
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
            if (activityList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No pending activities",
                    style: GoogleFonts.roboto(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityList.length > 3 ? 3 : activityList.length,
                itemBuilder: (context, index) {
                  final activity = activityList[index];

                  return GestureDetector(
                    onTap: () {
                      Future.microtask(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlannerScreen(
                              initialDate: activity.scheduledDate,
                            ),
                          ),
                        );
                      });
                    },
                    child: DynamicActivityCard(activity: activity),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Future.microtask(() {
            Navigator.pushNamed(context, '/AddPetProfileScreen');
          });
        },
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
