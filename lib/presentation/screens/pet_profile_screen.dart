import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_pet_activity_log.dart';
import 'package:petwise/presentation/widgets/petwise_pet_upcoming_medical_pill.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:provider/provider.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petProvider = context.read<PetProvider>();

      // Get all pet IDs to populate the global activity list (Option B)
      final petIds = petProvider.pets.map((p) => p.id).toList();

      if (petIds.isNotEmpty) {
        context.read<ActivityProvider>().loadAllActivities(petIds);
      } else {
        // Fallback: If no pets are loaded yet, load activities for the selected pet only
        final selectedPet = petProvider.selectedPet;
        if (selectedPet != null) {
          context.read<ActivityProvider>().loadActivities(selectedPet.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final pet = petProvider.selectedPet;

    final petActivities = activityProvider.activities
        .where((a) => a.petId == pet?.id)
        .toList();

    if (pet == null) {
      return const Scaffold(body: Center(child: Text("No pet selected")));
    }
    return Scaffold(
      backgroundColor: Color(0xFFDA9799),
      // backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.4],
            colors: [
              Color(0xFFDA9799), //bg color
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              stretch: true,
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.none,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoute.editPetProfile),
                  icon: const Icon(Icons.edit),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: const Color(0xFFDA9799),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: -50,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 119,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (pet?.image_url != null &&
                                    pet!.image_url!.startsWith('http'))
                                ? NetworkImage(pet.image_url!)
                                : null,
                            child:
                                (pet?.image_url == null ||
                                    !pet!.image_url!.startsWith('http'))
                                ? Icon(
                                    Icons.pets,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 30, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet?.name ?? "Unknown Pet",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            pet?.species ?? "Unknown Species",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 16,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            "${pet?.age ?? 0} years old",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 16,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upcoming Medical",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const PetwiseUpcomingMedicalPill(),
                          const SizedBox(height: 20),
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (activityProvider.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (activityProvider.activities.isEmpty)
                            Center(
                              child: Text(
                                "No activities found",
                                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                              ),
                            )
                          else
                          // Change activityProvider.activities.map to petActivities.map
                            ...petActivities.map((activity) => PetwisePetActivityLog(activity: activity)),],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
