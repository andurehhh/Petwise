import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_pet_activity_log.dart';
import 'package:petwise/presentation/widgets/petwise_add_health_event_sheet.dart';
import 'package:petwise/presentation/widgets/petwise_pet_upcoming_medical_pill.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
import 'package:petwise/providers/vaccination_provider.dart';
import 'package:petwise/data/models/vaccination_model.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:petwise/utils/pet_theme.dart';
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
        context.read<VaccinationProvider>().loadVaccinationsForPet(petId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final healthEventProvider = context.watch<HealthEventProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final vaccinationProvider = context.watch<VaccinationProvider>();
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

    final vaccinations =
        pet != null ? vaccinationProvider.forPet(pet.id) : <VaccinationModel>[];
    final validCount =
        vaccinations.where((v) => v.status == VaccinationStatus.valid).length;
    final expiredCount =
        vaccinations.where((v) => v.status == VaccinationStatus.expired).length;
    final expiringSoonCount = vaccinations
        .where((v) => v.status == VaccinationStatus.expiringSoon)
        .length;

    final profileColor = PetTheme.cardColor(pet?.species ?? '');

    return Scaffold(
      backgroundColor: profileColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.4, 0.4],
            colors: [profileColor, Colors.white],
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
                  color: profileColor,
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
                          // ── Vaccination Status ──────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Vaccination Status",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoute.vaccinationScreen,
                                ),
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 13,
                                  color: Color(0xFFF7A433),
                                ),
                                label: Text(
                                  "Manage",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF7A433),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (vaccinationProvider.isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF7A433),
                              ),
                            )
                          else if (vaccinations.isEmpty)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoute.vaccinationScreen,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF7A433)
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.vaccines_outlined,
                                      color: Color(0xFFF7A433),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "No vaccinations recorded — tap to add",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFF7A433),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoute.vaccinationScreen,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _VaccStatusDot(
                                      count: validCount,
                                      label: 'Valid',
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 12),
                                    _VaccStatusDot(
                                      count: expiringSoonCount,
                                      label: 'Expiring',
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 12),
                                    _VaccStatusDot(
                                      count: expiredCount,
                                      label: 'Expired',
                                      color: Colors.redAccent,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${vaccinations.length} total',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ],
                                ),
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

class _VaccStatusDot extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _VaccStatusDot({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
