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

  // The default image URL requested
  static const String _defaultPetImageUrl =
      'https://i.pinimg.com/736x/54/34/81/543481c0ca5a909bd4d23863c6262339.jpg';

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
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    final Widget fallbackImage = Image.network(
      _defaultPetImageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.pets, size: 35, color: Colors.white24),
    );

    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 120,
          maxHeight: 160,
          minWidth: 280,
          maxWidth: 500,
        ),
        width: double.infinity,
        height: double.infinity,
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
              padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    flex:
                        7, // Adjusted flex slightly to give text and avatar balanced spacing
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
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildDataTile(
                              Icons.calendar_month_outlined,
                              birthday,
                            ),
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
                  const SizedBox(width: 12),
                  // The Circular Avatar Container
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                        0.15,
                      ), // Fallback/Loading background ring
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isNetworkImage
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) =>
                                fallbackImage,
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) =>
                                fallbackImage,
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: detailColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
