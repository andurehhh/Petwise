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
import 'package:intl/intl.dart';

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

    final petEvents = healthEventProvider.healthEvents
        .where((e) => e.petId == pet?.id)
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    final today = DateTime.now();
    final recentActivities = activityProvider.activities
        .where((a) =>
            a.petId == pet?.id &&
            a.scheduledDate.year == today.year &&
            a.scheduledDate.month == today.month &&
            a.scheduledDate.day == today.day)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    final vaccinations =
        pet != null ? vaccinationProvider.forPet(pet.id) : <VaccinationModel>[];
    final validCount =
        vaccinations.where((v) => v.status == VaccinationStatus.valid).length;
    final expiredCount =
        vaccinations.where((v) => v.status == VaccinationStatus.expired).length;
    final expiringSoonCount =
        vaccinations.where((v) => v.status == VaccinationStatus.expiringSoon).length;

    final profileColor = PetTheme.cardColor(pet?.species ?? '');
    final detailColor = PetTheme.detailColor(pet?.species ?? '');
    final blobColor = detailColor.withValues(alpha: 0.35);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarRadius = (screenWidth * 0.28).clamp(70.0, 110.0);
    // Colored section ends at 42% of screen height
    final coloredHeight = screenHeight * 0.42;
    // Avatar is vertically centered in the colored section
    final avatarTop = (coloredHeight / 2) - avatarRadius + 20;
    // White sheet starts at the avatar midpoint (coloredHeight - avatarRadius)
    // so the bottom half of the avatar overlaps the white sheet
    final whiteSheetOffset = avatarRadius;
    // Sliver total height = colored area + avatar bottom half that sticks into white
    final sliverHeight = coloredHeight + avatarRadius * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: Colors.white),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: sliverHeight,
                pinned: false,
                floating: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: coloredHeight,
                        child: Container(color: profileColor),
                      ),
                      Positioned(
                        top: -20,
                        left: -16,
                        child: _Blob(size: 80, color: blobColor),
                      ),
                      Positioned(
                        top: 30,
                        right: -12,
                        child: _Blob(size: 60, color: blobColor.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        top: 80,
                        left: 60,
                        child: _Blob(size: 35, color: blobColor.withValues(alpha: 0.4)),
                      ),
                      Positioned(
                        top: 50,
                        right: 80,
                        child: _Blob(size: 28, color: blobColor.withValues(alpha: 0.35)),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: SafeArea(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: SafeArea(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoute.editPetProfile),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: avatarTop,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              backgroundImage: (pet?.image_url != null &&
                                      pet!.image_url!.startsWith('http'))
                                  ? NetworkImage(pet.image_url!)
                                  : null,
                              child: (pet?.image_url == null ||
                                      !pet!.image_url!.startsWith('http'))
                                  ? Icon(
                                      Icons.pets,
                                      size: 90,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, -whiteSheetOffset),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 20,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name → Birthday → Species • Breed
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet?.name ?? 'Unknown Pet',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A2D40),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      pet?.species ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    if (pet?.breed != null && pet!.breed!.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: detailColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          pet!.breed!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (pet?.birthday != null)
                                  Text(
                                    DateFormat.yMMMMd().format(pet!.birthday),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (pet != null) {
                                context.read<PetProvider>().toggleFavorite(pet.id);
                              }
                            },
                            icon: Icon(
                              (pet?.isFavorite ?? false)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.redAccent,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: profileColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InfoPill(
                              icon: Icons.vaccines_outlined,
                              label: validCount > 0 ? 'Vaccinated' : 'Unvax',
                              color: validCount > 0 ? Colors.green : Colors.redAccent,
                            ),
                            _Divider(),
                            _InfoPill(
                              icon: (pet?.sex ?? '').toLowerCase() == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              label: pet?.sex ?? '—',
                              color: (pet?.sex ?? '').toLowerCase() == 'male'
                                  ? Colors.blue
                                  : Colors.pink,
                            ),
                            _Divider(),
                            _InfoPill(
                              icon: Icons.cake_outlined,
                              label: '${pet?.age ?? 0} yrs',
                              color: detailColor,
                            ),
                            _Divider(),
                            _InfoPill(
                              icon: Icons.monitor_weight_outlined,
                              label: (pet?.weight != null && pet!.weight! > 0)
                                  ? '${pet.weight!.toStringAsFixed(1)} kg'
                                  : '—',
                              color: detailColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Medical',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A2D40),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: pet?.id != null
                                ? () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => AddHealthEventSheet(
                                        preselectedPetId: pet!.id,
                                      ),
                                    )
                                : null,
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: Color(0xFFF7A433),
                            ),
                            label: Text(
                              'Add',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF7A433),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (healthEventProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF7A433),
                          ),
                        )
                      else if (petEvents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No upcoming medical events',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                          ),
                        )
                      else
                        ...petEvents.take(3).map(
                              (event) => PetwiseUpcomingMedicalPill(
                                event: event,
                                onTap: () {
                                  if (!event.isCompleted) {
                                    context
                                        .read<HealthEventProvider>()
                                        .markEventAsCompleted(event.eventId);
                                  }
                                },
                              ),
                            ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Vaccination Status',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A2D40),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoute.vaccinationScreen),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Color(0xFFF7A433),
                            ),
                            label: Text(
                              'Manage',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF7A433),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (vaccinationProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF7A433),
                          ),
                        )
                      else if (vaccinations.isEmpty)
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoute.vaccinationScreen),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF7A433).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.vaccines_outlined,
                                  color: Color(0xFFF7A433),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No vaccinations recorded — tap to add',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFF7A433),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoute.vaccinationScreen),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _VaccDot(
                                  count: validCount,
                                  label: 'Valid',
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                _VaccDot(
                                  count: expiringSoonCount,
                                  label: 'Expiring',
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                _VaccDot(
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
                      const SizedBox(height: 24),
                      Text(
                        'Today\'s Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (recentActivities.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No activities scheduled for today',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                          ),
                        )
                      else
                        ...recentActivities.take(3).map(
                              (a) => PetwisePetActivityLog(activity: a),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: ColoredBox(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VaccDot extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _VaccDot({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2D40),
            ),
          ),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: Colors.grey.withValues(alpha: 0.25),
      );
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size * 0.85,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size * 0.5),
            topRight: Radius.circular(size * 0.35),
            bottomLeft: Radius.circular(size * 0.35),
            bottomRight: Radius.circular(size * 0.55),
          ),
        ),
      );
}


