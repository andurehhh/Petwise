import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petwise/data/models/activity_model.dart';

class PetwisePetActivityLog extends StatelessWidget {
  final ActivityModel activity;

  const PetwisePetActivityLog({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    String timeAgo;
    final now = DateTime.now();
    final difference = now.difference(activity.scheduledDate);

    if (difference.isNegative) {
      // Future activity
      timeAgo = "IN ${difference.abs().inMinutes} MIN";
      if (difference.abs().inHours > 0) {
        timeAgo = "IN ${difference.abs().inHours}H";
      }
    } else {
      // Past activity
      timeAgo = "${difference.inMinutes} MIN AGO";
      if (difference.inHours > 0) {
        timeAgo = "${difference.inHours}H AGO";
      }
    }

    // Special case for just now
    if (difference.inMinutes.abs() < 1) {
      timeAgo = "JUST NOW";
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 33.5,
                  child: Container(
                    width: 3,
                    color: Colors.grey.shade300,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: activity.isCompleted
                          ? Colors.green
                          : const Color(0xFFF7A433),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity.isCompleted ? Icons.check : Icons.pets,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeAgo,
                    style: GoogleFonts.plusJakartaSans(
                      color: activity.isCompleted
                          ? Colors.green
                          : const Color(0xFFF7A433),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    activity.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (activity.description != null &&
                      activity.description!.isNotEmpty)
                    Text(
                      activity.description!,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey,
                        fontSize: 15,
                        letterSpacing: -0.5,
                      ),
                    ),
                  Text(
                    DateFormat('hh:mm a').format(activity.scheduledDate),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
