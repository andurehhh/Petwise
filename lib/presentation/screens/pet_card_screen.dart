import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/presentation/screens/pet_profile_screen.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/utils/pet_theme.dart';
import 'package:petwise/utils/phone_number_formatter.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_navbar.dart';
import '../widgets/petwise_petcard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:petwise/utils/pet_qr_payload.dart';

class PetCardScreen extends StatefulWidget {
  const PetCardScreen({super.key});

  @override
  State<PetCardScreen> createState() => _PetCardScreenState();
}

class _PetCardScreenState extends State<PetCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId;
    if (userProvider.user == null && currentUserId != null && currentUserId.isNotEmpty) {
      userProvider.loadUser(currentUserId);
    }
  }

  void _showZoom({
    required BuildContext context,
    required Pet pet,
    required String displayImage,
    String? ownerName,
    String? contactNumber,
    String? address,
    String? ownerImageUrl,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, _, _) => _ZoomOverlay(
          pet: pet,
          displayImage: displayImage,
          ownerName: ownerName,
          contactNumber: contactNumber,
          address: address,
          ownerImageUrl: ownerImageUrl,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petList = context.watch<PetProvider>().pets;
    final favPets = petList.where((p) => p.isFavorite).take(3).toList();
    final user = context.watch<UserProvider>().user;
    final bgColor = const Color(0xffF8F7F6);

    final ownerName = user != null
        ? ((user.firstName.isNotEmpty || user.lastName.isNotEmpty)
            ? '${user.firstName} ${user.lastName}'.trim()
            : (user.nickname ?? 'Pet Owner'))
        : null;
    final contactNumber = (user?.contactNumber != null &&
            user!.contactNumber!.trim().isNotEmpty)
        ? MobileNumberInputFormatter.format(user.contactNumber!)
        : null;
    final address = (user?.address != null && user!.address!.trim().isNotEmpty)
        ? user.address
        : null;
    final ownerImageUrl = user?.imageUrl;

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
                  (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
                      ? pet.imageUrl!
                      : 'assets/images/doggie.gif';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onLongPress: () => _showZoom(
                    context: context,
                    pet: pet,
                    displayImage: displayImage,
                    ownerName: ownerName,
                    contactNumber: contactNumber,
                    address: address,
                    ownerImageUrl: ownerImageUrl,
                  ),
                  onTap: () {
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
                    ownerName: ownerName,
                    contactNumber: contactNumber,
                    address: address,
                    ownerImageUrl: ownerImageUrl,
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
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 3, showFab: true),
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
                (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
                    ? pet.imageUrl!
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
                                      errorBuilder: (_, _, _) => Container(
                                        color: color.withValues(alpha: 0.3),
                                        child: Icon(Icons.pets,
                                            color: color, size: 18),
                                      ),
                                    )
                                  : Image.asset(
                                      img,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
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
  final String? ownerName;
  final String? contactNumber;
  final String? address;
  final String? ownerImageUrl;

  const _ZoomOverlay({
    required this.pet,
    required this.displayImage,
    this.ownerName,
    this.contactNumber,
    this.address,
    this.ownerImageUrl,
  });

  @override
  State<_ZoomOverlay> createState() => _ZoomOverlayState();
}

class _ZoomOverlayState extends State<_ZoomOverlay>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _startAngle = 0;
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
    final birthday = DateFormat('MMMM d, yyyy').format(parsed);
    final breedText = (widget.pet.breed != null && widget.pet.breed!.isNotEmpty)
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
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, _) {
                        final flipAngle = _flipAnimation.value * 3.14159265;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(flipAngle),
                          child: _isBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(3.14159265),
                                  child: _buildBackCard(
                                    cardColor: cardColor,
                                    detailColor: detailColor,
                                    blobColor: blobColor,
                                  ),
                                )
                              : _buildFrontCard(
                                  cardColor: cardColor,
                                  detailColor: detailColor,
                                  blobColor: blobColor,
                                  isNetwork: isNetwork,
                                  birthday: birthday,
                                  isMale: isMale,
                                  breedText: breedText,
                                ),
                        );
                      },
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
                  'Pinch & rotate · Tap button to flip · Tap outside to close',
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

  Widget _buildFrontCard({
    required Color cardColor,
    required Color detailColor,
    required Color blobColor,
    required bool isNetwork,
    required String birthday,
    required bool isMale,
    required String breedText,
  }) {
    return Container(
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
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Petwise Identification Card',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _flipCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: detailColor.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                                fontSize: 11,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: isNetwork
                            ? Image.network(
                                widget.displayImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              )
                            : Image.asset(
                                widget.displayImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Field(
                            label: 'Name',
                            value: widget.pet.name,
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            label: 'Breed',
                            value: breedText,
                          ),
                          const SizedBox(height: 12),
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
                                isMale ? Icons.male : Icons.female,
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
    );
  }

  Widget _buildBackCard({
    required Color cardColor,
    required Color detailColor,
    required Color blobColor,
  }) {
    final qrPayload = PetQrPayload.generate(
      petId: widget.pet.id,
      petName: widget.pet.name,
      species: widget.pet.species,
      breed: widget.pet.breed,
      sex: widget.pet.sex,
      birthday: DateFormat('MMMM d, yyyy').format(widget.pet.birthday),
      ownerName: widget.ownerName,
      contactNumber: widget.contactNumber,
      address: widget.address,
    );

    return Container(
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
            bottom: -20,
            right: -15,
            child: _Blob(size: 75, color: blobColor),
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: Icon(
              Icons.badge_outlined,
              size: 48,
              color: Colors.black.withValues(alpha: 0.13),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Owner & Emergency Info',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _flipCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: detailColor.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                                fontSize: 11,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: detailColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: QrImageView(
                              data: qrPayload,
                              version: QrVersions.auto,
                              padding: EdgeInsets.zero,
                              size: 90,
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
                          const SizedBox(height: 3),
                          Text(
                            'SCAN TO CALL NUMBER',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: detailColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'PET ID #${widget.pet.id}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7A8B9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ZoomInfoField(
                            label: 'PET OWNER',
                            value: widget.ownerName ?? 'Not set',
                          ),
                          const SizedBox(height: 10),
                          _ZoomInfoField(
                            label: 'CONTACT NUMBER',
                            icon: Icons.phone_rounded,
                            iconColor: detailColor,
                            value: widget.contactNumber ?? 'Not set',
                          ),
                          const SizedBox(height: 10),
                          _ZoomInfoField(
                            label: 'ADDRESS',
                            icon: Icons.location_on_rounded,
                            iconColor: detailColor,
                            value: widget.address ?? 'Not set',
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
    );
  }
}

class _ZoomInfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const _ZoomInfoField({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5A5A5A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            height: 1.15,
          ),
        ),
      ],
    );
  }
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
