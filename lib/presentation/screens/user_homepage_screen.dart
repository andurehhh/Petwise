import 'package:flutter/material.dart';
import 'package:petwise/presentation/widgets/petwise_pet_pen.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/routes/app_route.dart';
import '../widgets/petwise_pet_profile.dart';
import '../widgets/petwise_dynamic_activity_card.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pet_activity_planner_screen.dart';
import 'package:petwise/presentation/widgets/petwise_add_activity_sheet.dart';
import 'package:intl/intl.dart';

Route _slideLeft(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    // FIX: Exit immediately if no user is found.
    // This prevents the "Task" exception on first run/no account.
    if (userId == null) {
      debugPrint("Skipping data initialization: No user logged in.");
      return;
    }

    try {
      final petProvider = context.read<PetProvider>();

      // 1. Load pets first
      await petProvider.loadUserPets(userId);

      if (!mounted) return;

      // 2. Only proceed to activities if we have pets
      final petIds = petProvider.pets.map((p) => p.id).toList();
      if (petIds.isNotEmpty) {
        await context.read<ActivityProvider>().loadAllActivities(petIds);
      } else {
        debugPrint("No pets found for user $userId, skipping activities.");
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final petList = context.watch<PetProvider>().pets;
    final activityProvider = context.watch<ActivityProvider>();

    final today = DateTime.now();
    final activityList = activityProvider.activities
        .where((a) =>
            !a.isCompleted &&
            a.scheduledDate.year == today.year &&
            a.scheduledDate.month == today.month &&
            a.scheduledDate.day == today.day)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final favPets = petList.where((p) => p.isFavorite).take(3).toList();
    final displayedPets = favPets.isNotEmpty ? favPets : petList.take(3).toList();
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
              "${today.hour < 12 ? 'Good morning' : today.hour < 17 ? 'Good afternoon' : 'Good evening'}, $displayName!",
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
            // Container(
            //   width: double.infinity,
            //   height: 160,
            //   decoration: BoxDecoration(
            //     color: const Color(0xffF6EEE4),
            //     borderRadius: BorderRadius.circular(24),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withValues(alpha: 0.03),
            //         blurRadius: 10,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            // ),
            const InteractivePetPen(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  favPets.isNotEmpty ? "Favorites" : "Pets",
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 40) / 3;
                  return Row(
                    mainAxisAlignment: displayedPets.length == 1
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceBetween,
                    children: displayedPets.map((pet) {
                      return SizedBox(
                        width: itemWidth,
                        child: GestureDetector(
                          onTap: () {
                            context.read<PetProvider>().selectPet(pet);
                            Navigator.pushNamed(context, AppRoute.petProfile);
                          },
                          child: PetCircle(
                            imagePath: pet.image_url ?? '',
                            petName: pet.name,
                            petType: pet.species,
                            isFavorite: pet.isFavorite,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Activities",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(today),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final userId = context.read<UserProvider>().user?.id;
                        if (userId != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddActivitySheet(
                              userId: userId,
                              selectedDate: today,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF7A433).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: Color(0xFFF7A433),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Add",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF7A433),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        _slideLeft(PlannerScreen(initialDate: today)),
                      ),
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
              ],
            ),
            const SizedBox(height: 15),
            if (activityProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFFF7A433)),
                ),
              )
            else if (activityList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "All clear for today!",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          final userId =
                              context.read<UserProvider>().user?.id;
                          if (userId != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddActivitySheet(
                                userId: userId,
                                selectedDate: today,
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Tap + to schedule one",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFF7A433),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
                    onTap: () => Navigator.push(
                      context,
                      _slideLeft(PlannerScreen(
                        initialDate: activity.scheduledDate,
                      )),
                    ),
                    child: DynamicActivityCard(activity: activity),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/AddPetProfileScreen'),
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

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
