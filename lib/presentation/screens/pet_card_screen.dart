import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/utils/pet_theme.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_petcard.dart';
import 'package:intl/intl.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:petwise/presentation/screens/pet_profile_screen.dart';
import 'package:petwise/data/models/pet_model.dart';

class PetCardScreen extends StatelessWidget {
  const PetCardScreen({super.key});

  void _showZoom(BuildContext context, Pet pet, String displayImage) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) =>
            _ZoomOverlay(pet: pet, displayImage: displayImage),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petList = context.watch<PetProvider>().pets;
    final favPets = petList.where((p) => p.isFavorite).take(3).toList();
    final bgColor = const Color(0xffF8F7F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const PetWiseAppBar(),
      body: ColoredBox(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          if (favPets.isNotEmpty) ...[
            _FavoritesStrip(pets: favPets),
            const SizedBox(height: 20),
          ],
          ...petList.asMap().entries.map((entry) {
            final pet = entry.value;
            final String displayImage =
                (pet.image_url != null && pet.image_url!.isNotEmpty)
                ? pet.image_url!
                : 'assets/images/doggie.gif';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _showZoom(context, pet, displayImage),
                onDoubleTap: () {
                  context.read<PetProvider>().selectPet(pet);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PetProfileScreen()),
                  );
                },
                child: PetCard(
                  id: pet.id,
                  name: pet.name,
                  species: pet.species,
                  birthday: DateFormat('MM-dd-yyyy').format(pet.birthday),
                  sex: pet.sex,
                  breed: pet.breed,
                  cardColor: PetTheme.cardColor(pet.species),
                  detailColor: PetTheme.detailColor(pet.species),
                  dataTileBackgroundColor: PetTheme.tileBackground(pet.species),
                  imagePath: displayImage,
                ),
              ),
            );
          }),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/AddPetProfileScreen'),
        backgroundColor: const Color(0xFFF7A433),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 3),
    );
  }
}

class _FavoritesStrip extends StatelessWidget {
  final List<Pet> pets;
  const _FavoritesStrip({required this.pets});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              'Favorites',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A2D40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: pets.map((pet) {
            final String img =
                (pet.image_url != null && pet.image_url!.isNotEmpty)
                    ? pet.image_url!
                    : 'assets/images/doggie.gif';
            final bool isNetwork =
                img.startsWith('http://') || img.startsWith('https://');
            final color = PetTheme.cardColor(pet.species);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<PetProvider>().selectPet(pet);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PetProfileScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: isNetwork
                                  ? Image.network(
                                      img,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: color.withValues(alpha: 0.3),
                                        child: Icon(Icons.pets,
                                            color: color, size: 18),
                                      ),
                                    )
                                  : Image.asset(
                                      img,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: color.withValues(alpha: 0.3),
                                        child: Icon(Icons.pets,
                                            color: color, size: 18),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ZoomOverlay extends StatefulWidget {
  final Pet pet;
  final String displayImage;
  const _ZoomOverlay({required this.pet, required this.displayImage});

  @override
  State<_ZoomOverlay> createState() => _ZoomOverlayState();
}

class _ZoomOverlayState extends State<_ZoomOverlay> {
  double _angle = 0;
  double _startAngle = 0;

  @override
  Widget build(BuildContext context) {
    final cardColor = PetTheme.cardColor(widget.pet.species);
    final detailColor = PetTheme.detailColor(widget.pet.species);
    final blobColor = detailColor.withValues(alpha: 0.45);
    final isMale = widget.pet.sex.toLowerCase() == 'male';
    final isNetwork = widget.displayImage.startsWith('http://') ||
        widget.displayImage.startsWith('https://');

    DateTime? parsed;
    try {
      parsed = DateFormat('MM-dd-yyyy')
          .parse(DateFormat('MM-dd-yyyy').format(widget.pet.birthday));
    } catch (_) {
      parsed = widget.pet.birthday;
    }
    final birthday =
        parsed != null ? DateFormat('MMMM d, yyyy').format(parsed) : '';
    final breedText =
        (widget.pet.breed != null && widget.pet.breed!.isNotEmpty)
            ? widget.pet.breed!
            : widget.pet.species;

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Center(
            child: GestureDetector(
              onTap: () {},
              onScaleStart: (d) => _startAngle = _angle,
              onScaleUpdate: (d) =>
                  setState(() => _angle = _startAngle + d.rotation),
              child: Transform.rotate(
                angle: _angle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -24,
                          left: -18,
                          child: _Blob(size: 90, color: blobColor),
                        ),
                        Positioned(
                          top: -16,
                          right: -16,
                          child: _Blob(size: 62, color: blobColor),
                        ),
                        Positioned(
                          bottom: -22,
                          left: 110,
                          child: _Blob(size: 50, color: blobColor),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 8,
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: Colors.black.withValues(alpha: 0.13),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 14, 18, 10),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 28,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Petwise Identification Card',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A2D40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 0, 18, 32),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 130,
                                      height: 130,
                                      child: isNetwork
                                          ? Image.network(
                                              widget.displayImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.shrink(),
                                            )
                                          : Image.asset(
                                              widget.displayImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.shrink(),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _Field(
                                          label: 'Name',
                                          value: widget.pet.name,
                                        ),
                                        const SizedBox(height: 14),
                                        _Field(
                                          label: 'Breed',
                                          value: breedText,
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          'Birthday',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF3D3D3D),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                birthday,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF1A1A1A),
                                                  height: 1.1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              isMale
                                                  ? Icons.male
                                                  : Icons.female,
                                              color: detailColor,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Pinch & rotate · Tap outside to close',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _fallback(Color c) => Container(
        color: c.withValues(alpha: 0.15),
        child: Icon(Icons.pets, color: c, size: 40),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3D3D3D),
          ),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            height: 1.1,
          ),
        ),
      ],
    );
  }
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
