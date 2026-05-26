import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';

class DynamicActivityCard extends StatelessWidget {
  final ActivityModel activity;
  const DynamicActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final petProvider = context.read<PetProvider>();
    final activityProvider = context.read<ActivityProvider>();

    final pet = petProvider.pets.firstWhere((p) => p.id == activity.petId, orElse: () => petProvider.pets.isNotEmpty? petProvider.pets.first: throw Exception("Pet not found"));

    final bool isRecentlyCompleted = activityProvider.recentlyCompletedIds.contains(activity.id);
    final bool shouldHide = activity.isCompleted && !isRecentlyCompleted;

    return
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          return AnimatedOpacity(
            opacity: activity.isCompleted ? 0.0 : value,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            child: AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: shouldHide?const SizedBox.shrink():child,
            ),
          );
        },
        child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: activity.isCompleted
                      ? Colors.green
                      : const Color(0xFFF7A433),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${pet.name.toUpperCase()} • ${pet.species.toUpperCase()}",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFF7A433),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A2D40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          size: 16,
                          color: Color(0xFF92A1B7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('hh:mm a').format(activity.scheduledDate),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF92A1B7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      'assets/images/pet_${pet.id}.png',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context
                        .read<ActivityProvider>()
                        .toggleCompletion(activity.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activity.isCompleted
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        color: activity.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: activity.isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            ),
      );
  }
}
