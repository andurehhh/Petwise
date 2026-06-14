import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PetCard extends StatefulWidget {
  final int id;
  final String name;
  final String species;
  final String birthday;
  final String sex;
  final String? breed;
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
    this.breed,
    required this.cardColor,
    required this.detailColor,
    required this.dataTileBackgroundColor,
    required this.imagePath,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        widget.imagePath.startsWith('http://') ||
        widget.imagePath.startsWith('https://');
    final blobColor = widget.detailColor.withValues(alpha: 0.45);
    final activeColor = _pressed
        ? HSLColor.fromColor(widget.cardColor)
              .withLightness(
                (HSLColor.fromColor(widget.cardColor).lightness - 0.12).clamp(
                  0.0,
                  1.0,
                ),
              )
              .toColor()
        : widget.cardColor;

    DateTime? parsedBirthday;
    try {
      parsedBirthday = DateFormat('MM-dd-yyyy').parse(widget.birthday);
    } catch (_) {}
    final formattedBirthday = parsedBirthday != null
        ? DateFormat('MMMM d, yyyy').format(parsedBirthday)
        : widget.birthday;

    final isMale = widget.sex.toLowerCase() == 'male';
    final breedText = (widget.breed != null && widget.breed!.isNotEmpty)
        ? widget.breed!
        : widget.species;

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: activeColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -16,
              left: -12,
              child: _Blob(size: 65, color: blobColor),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: _Blob(size: 44, color: blobColor),
            ),
            Positioned(
              top: 50,
              left: 80,
              child: _Blob(size: 36, color: blobColor),
            ),
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: const Alignment(0.7, 0.0),
                child: _Blob(size: 48, color: Colors.black.withValues(alpha: 0.07)),
              ),
            ),
            Positioned(
              bottom: 6,
              right: 8,
              child: Icon(
                Icons.pets,
                size: 40,
                color: Colors.black.withValues(alpha: 0.07),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 14, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Petwise Identification Card',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: isNetwork
                                ? Image.network(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fallback(widget.detailColor),
                                  )
                                : Image.asset(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _fallback(widget.detailColor),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Name',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3D3D3D),
                                ),
                              ),
                              Text(
                                widget.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Breed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3D3D3D),
                                ),
                              ),
                              Text(
                                breedText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Birthday',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3D3D3D),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      formattedBirthday,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A1A1A),
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isMale ? Icons.male : Icons.female,
                                    color: widget.detailColor,
                                    size: 22,
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }

  Widget _fallback(Color color) => Container(
    color: color.withValues(alpha: 0.15),
    child: Icon(Icons.pets, color: color, size: 32),
  );
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
}
