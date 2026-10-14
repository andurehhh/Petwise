import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:petwise/utils/pet_qr_payload.dart';

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
  final String? ownerName;
  final String? contactNumber;
  final String? address;
  final String? ownerImageUrl;

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
    this.ownerName,
    this.contactNumber,
    this.address,
    this.ownerImageUrl,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        final shouldBeBack = _flipAnimation.value >= 0.5;
        if (shouldBeBack != _isBack) {
          setState(() {
            _isBack = shouldBeBack;
          });
        }
      });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_isBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, _) {
          final angle = _flipAnimation.value * 3.14159265;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159265),
                    child: _buildBackSide(
                      activeColor: activeColor,
                      blobColor: blobColor,
                      detailColor: widget.detailColor,
                    ),
                  )
                : _buildFrontSide(
                    activeColor: activeColor,
                    blobColor: blobColor,
                    detailColor: widget.detailColor,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide({
    required Color activeColor,
    required Color blobColor,
    required Color detailColor,
  }) {
    final isNetwork = widget.imagePath.startsWith('http://') ||
        widget.imagePath.startsWith('https://');

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

    return Container(
      width: double.infinity,
      height: 175,
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
              child: _Blob(
                size: 48,
                color: Colors.black.withValues(alpha: 0.07),
              ),
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
                padding: const EdgeInsets.fromLTRB(20, 10, 14, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    GestureDetector(
                      onTap: _flipCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: detailColor.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flip_to_back_rounded,
                              size: 13,
                              color: Color(0xFF1A2D40),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owner',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A2D40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 14, 12),
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
                                  errorBuilder: (_, _, _) =>
                                      _fallback(detailColor),
                                )
                              : Image.asset(
                                  widget.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _fallback(detailColor),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
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
                                  color: detailColor,
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
    );
  }

  Widget _buildBackSide({
    required Color activeColor,
    required Color blobColor,
    required Color detailColor,
  }) {
    final qrPayload = PetQrPayload.generate(
      petId: widget.id,
      petName: widget.name,
      species: widget.species,
      breed: widget.breed,
      sex: widget.sex,
      birthday: widget.birthday,
      ownerName: widget.ownerName,
      contactNumber: widget.contactNumber,
      address: widget.address,
    );

    return Container(
      width: double.infinity,
      height: 175,
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
            bottom: -15,
            right: -10,
            child: _Blob(size: 55, color: blobColor),
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: Icon(
              Icons.badge_outlined,
              size: 40,
              color: Colors.black.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 14, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Owner & Emergency Info',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _flipCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: detailColor.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flip_to_front_rounded,
                              size: 13,
                              color: Color(0xFF1A2D40),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pet ID',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A2D40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: detailColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: QrImageView(
                                data: qrPayload,
                                version: QrVersions.auto,
                                padding: EdgeInsets.zero,
                                size: 68,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF1A2D40),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF1A2D40),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SCAN TO CALL',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w800,
                                color: detailColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PET OWNER',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5A5A5A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              widget.ownerName ?? 'Not set',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 11,
                                  color: detailColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'CONTACT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5A5A5A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.contactNumber ?? 'Not set',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 11,
                                  color: detailColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ADDRESS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5A5A5A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.address ?? 'Not set',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                                height: 1.15,
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
        ],
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

