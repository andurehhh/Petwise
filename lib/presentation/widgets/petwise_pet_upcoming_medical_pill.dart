import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petwise/contracts/health_event/health_event_response.dart';

class PetwiseUpcomingMedicalPill extends StatelessWidget {
  final HealthEventResponse event;
  final VoidCallback? onTap;

  const PetwiseUpcomingMedicalPill({
    super.key,
    required this.event,
    this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'checkup':
        return Icons.monitor_heart_outlined;
      case 'illness':
        return Icons.sick_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
          decoration: BoxDecoration(
            color: event.isCompleted
                ? Colors.green.shade50
                : const Color(0xFFFFF4E6),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: event.isCompleted
                  ? Colors.green.shade200
                  : const Color(0xFFF7A433),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: event.isCompleted
                    ? Colors.green.shade100
                    : const Color(0xFFFFE0B2),
                child: Icon(
                  _iconForType(event.type),
                  color: event.isCompleted
                      ? Colors.green
                      : const Color(0xFFF7A433),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF1A2D40),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      event.type[0].toUpperCase() + event.type.substring(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF92A1B7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(event.eventDate),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: event.isCompleted
                      ? Colors.green
                      : const Color(0xFFF7A433),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
