import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_pet_activity_log.dart';
import 'package:petwise/presentation/widgets/petwise_add_health_event_sheet.dart';
import 'package:petwise/presentation/widgets/petwise_pet_upcoming_medical_pill.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
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
      if (!mounted) return;
      final petId = context.read<PetProvider>().selectedPet?.id;
      if (petId != null) {
        context.read<HealthEventProvider>().loadPetHealthEvents(petId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final healthEventProvider = context.watch<HealthEventProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final pet = petProvider.selectedPet;

    final petEvents =
        healthEventProvider.healthEvents
            .where((e) => e.petId == pet?.id)
            .toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    final recentActivities = activityProvider.activities
        .where((a) => a.petId == pet?.id)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    return Scaffold(
      backgroundColor: Color(0xFFDA9799),
      // backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.4],
            colors: [Color(0xFFDA9799), Colors.white],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              TextButton.icon(
                                onPressed: pet?.id != null
                                    ? () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              AddHealthEventSheet(
                                                preselectedPetId: pet!.id,
                                              ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Color(0xFFF7A433),
                                ),
                                label: Text(
                                  "Add",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF7A433),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (healthEventProvider.isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF7A433),
                              ),
                            )
                          else if (petEvents.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "No upcoming medical events",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            ...petEvents
                                .take(3)
                                .map(
                                  (event) => PetwiseUpcomingMedicalPill(
                                    event: event,
                                    onTap: () {
                                      if (!event.isCompleted) {
                                        context
                                            .read<HealthEventProvider>()
                                            .markEventAsCompleted(
                                              event.eventId,
                                            );
                                      }
                                    },
                                  ),
                                ),
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
                          if (recentActivities.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "No recent activity",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            ...recentActivities
                                .take(3)
                                .map(
                                  (activity) => PetwisePetActivityLog(
                                    activity: activity,
                                  ),
                                ),
                        ],
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
