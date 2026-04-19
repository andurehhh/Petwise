import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetCircle extends StatelessWidget {
  final String imagePath;
  final String petName;
  final String petType;

  const PetCircle({
    super.key,
    required this.imagePath,
    required this.petName,
    required this.petType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xffD0DAF0), width: 3),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Color(0xffFFF9F2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          petName,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        Text(
          petType,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade600,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
