import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetCard extends StatelessWidget {
  final int id;
  final String name;
  final String species;
  final String birthday;
  final String sex;
  final Color cardColor;
  final Color detailColor;
  final Color dataTileBackgroundColor;
  final String imagePath;

  const PetCard({
    super.key,
    required this.id,
    required this.name,
    required this.species,
    required this.birthday,
    required this.sex,
    required this.cardColor,
    required this.detailColor,
    required this.dataTileBackgroundColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 127,
        width: 320,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -10,
              left: 40,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: 15,
              right: -10,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          species,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildDataTile(
                              Icons.calendar_month_outlined,
                              birthday,
                            ),
                            const SizedBox(width: 6),
                            _buildDataTile(
                              sex.toLowerCase() == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              sex,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: dataTileBackgroundColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: detailColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: detailColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
