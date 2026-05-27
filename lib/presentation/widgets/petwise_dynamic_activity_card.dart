import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petwise/data/models/pet_model.dart';
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
    final pet = petProvider.pets.firstWhere(
      (p) => p.id == activity.petId,
      orElse: () => throw Exception('Pet not found for id ${activity.petId}'),
    );

    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Delete Activity",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete "${activity.title}"?',
              style: GoogleFonts.plusJakartaSans(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confirmed = false;
                  Navigator.pop(ctx);
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  confirmed = true;
                  Navigator.pop(ctx);
                },
                child: Text(
                  "Delete",
                  style: GoogleFonts.plusJakartaSans(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
        return confirmed;
      },
      onDismissed: (_) {
        context.read<ActivityProvider>().deleteActivity(activity.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.title} deleted'),
            backgroundColor: Colors.redAccent,
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
              color: Colors.black.withValues(alpha: 0.03),
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
                    backgroundImage: _getPetImage(pet),
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
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
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

  ImageProvider _getPetImage(Pet pet) {
    final imageUrl = pet.image_url;

    // 1. Check if we have a valid image_url
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      }
      return AssetImage(imageUrl);
    }

    // 2. Fallback to species-specific defaults
    final species = pet.species.toLowerCase();
    if (species.contains('cat')) {
      return const AssetImage('assets/images/cat.png');
    }
    if (species.contains('dog')) {
      return const AssetImage('assets/images/dog.png');
    }

    // 3. Final fallback
    return const AssetImage('assets/images/doggie.gif');
  }
}
