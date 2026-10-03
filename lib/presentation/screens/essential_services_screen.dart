import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/pet_establishment_model.dart';
import '../../providers/essential_services_provider.dart';
import '../widgets/petwise_navbar.dart';
import '../widgets/petwise_app_bar.dart';

class EssentialServicesScreen extends StatefulWidget {
  const EssentialServicesScreen({super.key});

  @override
  State<EssentialServicesScreen> createState() =>
      _EssentialServicesScreenState();
}

class _EssentialServicesScreenState extends State<EssentialServicesScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EssentialServicesProvider>().initLocationAndFetch(
            onMarkerTap: _showEstablishmentDetails,
          );
    });
  }

  double _calculateZoom(double radiusMeters) {
    if (radiusMeters <= 2000) return 14.0;
    if (radiusMeters <= 5000) return 12.5;
    if (radiusMeters <= 10000) return 11.2;
    return 10.0;
  }

  void _showEstablishmentDetails(PetEstablishmentModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EstablishmentDetailSheet(place: place),
    );
  }

  void _showHotlinesModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Hotlines & Care',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                        Text(
                          '24/7 veterinary triage, rescue & poison lines',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...kDefaultPetHotlines.map(
                (h) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: const Color(0xFF1A2D40),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              h.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.phone, size: 20),
                        onPressed: () => launchUrl(Uri.parse('tel:${h.phone}')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EssentialServicesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      appBar: const PetWiseAppBar(),
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 4),
      body: Stack(
        children: [
          // Google Map Background
          if (provider.userLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: provider.userLocation!,
                zoom: _calculateZoom(provider.radiusMeters),
              ),
              onMapCreated: (ctrl) => _mapController = ctrl,
              markers: provider.markers,
              circles: provider.circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7A433)),
            ),

          // Top Floating Control Card (Matches PetWise Design System)
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subheader Row: Title & Emergency Hotline Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7A433)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFF7A433),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Essential Services',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A2D40),
                            ),
                          ),
                        ],
                      ),
                      // Emergency Hotlines Pill Button
                      InkWell(
                        onTap: _showHotlinesModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emergency_rounded,
                                color: Colors.red.shade700,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Emergency',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip(
                          'Clinics',
                          Icons.local_hospital_rounded,
                          EstablishmentCategory.clinic,
                          provider,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          'Grooming',
                          Icons.content_cut_rounded,
                          EstablishmentCategory.grooming,
                          provider,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          'Pet Shops',
                          Icons.storefront_rounded,
                          EstablishmentCategory.shop,
                          provider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Radius Slider Row
                  Row(
                    children: [
                      Icon(
                        Icons.radar_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Radius: ${(provider.radiusMeters / 1000).toStringAsFixed(0)} km',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: const Color(0xFFF7A433),
                            inactiveTrackColor: Colors.grey.shade200,
                            thumbColor: const Color(0xFFF7A433),
                            overlayColor: const Color(0xFFF7A433)
                                .withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: provider.radiusMeters,
                            min: 2000,
                            max: 20000,
                            divisions: 9,
                            onChanged: (val) {
                              provider.setRadius(
                                val,
                                onMarkerTap: _showEstablishmentDetails,
                              );
                            },
                            onChangeEnd: (_) {
                              if (provider.userLocation != null &&
                                  _mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    provider.userLocation!,
                                    _calculateZoom(provider.radiusMeters),
                                  ),
                                );
                              }
                              provider.fetchPlaces(
                                onMarkerTap: _showEstablishmentDetails,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button: Recenter on My Location
          if (provider.userLocation != null)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'recenter_my_location',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A2D40),
                elevation: 3,
                onPressed: () {
                  if (provider.userLocation != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        provider.userLocation!,
                        _calculateZoom(provider.radiusMeters),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFFF7A433),
                ),
              ),
            ),

          // Loading & Empty States
          if (provider.isLoading)
            Positioned(
              bottom: 24,
              left: 20,
              right: 76,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF7A433),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Finding nearby establishments...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A2D40),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.error != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 76,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.establishments.isEmpty &&
              provider.userLocation != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 76,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFFF7A433),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No places found. Try expanding radius.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2D40),
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildCategoryChip(
    String label,
    IconData icon,
    EstablishmentCategory category,
    EssentialServicesProvider provider,
  ) {
    final isSelected = provider.selectedCategory == category;
    return InkWell(
      onTap: () => provider.setCategory(
        category,
        onMarkerTap: _showEstablishmentDetails,
      ),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFF7A433) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF7A433).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstablishmentDetailSheet extends StatefulWidget {
  final PetEstablishmentModel place;

  const _EstablishmentDetailSheet({required this.place});

  @override
  State<_EstablishmentDetailSheet> createState() =>
      _EstablishmentDetailSheetState();
}

class _EstablishmentDetailSheetState extends State<_EstablishmentDetailSheet> {
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    if (p.phoneNumber == null ||
        p.weekdayDescriptions == null ||
        (p.photoName != null && p.photoUrl == null)) {
      _isLoadingDetails = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<EssentialServicesProvider>()
            .loadDetails(widget.place)
            .then((_) {
          if (mounted) {
            setState(() {
              _isLoadingDetails = false;
            });
          }
        });
      });
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final googleMapsAppUri = Uri.parse('google.navigation:q=$lat,$lng');
    final webMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(googleMapsAppUri)) {
      await launchUrl(googleMapsAppUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCategoryBadge(EstablishmentCategory category) {
    String label;
    IconData icon;
    Color color;
    switch (category) {
      case EstablishmentCategory.clinic:
        label = 'Veterinary Clinic';
        icon = Icons.local_hospital_rounded;
        color = Colors.red.shade700;
        break;
      case EstablishmentCategory.grooming:
        label = 'Pet Grooming';
        icon = Icons.content_cut_rounded;
        color = Colors.cyan.shade800;
        break;
      case EstablishmentCategory.shop:
        label = 'Pet Store';
        icon = Icons.pets_rounded;
        color = const Color(0xFFF7A433);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner(PetEstablishmentModel place) {
    IconData icon;
    Color color;
    String label;
    switch (place.category) {
      case EstablishmentCategory.clinic:
        icon = Icons.local_hospital_rounded;
        color = Colors.red.shade400;
        label = 'Veterinary Clinic';
        break;
      case EstablishmentCategory.grooming:
        icon = Icons.content_cut_rounded;
        color = Colors.cyan.shade600;
        label = 'Pet Grooming Salon';
        break;
      case EstablishmentCategory.shop:
        icon = Icons.pets_rounded;
        color = const Color(0xFFF7A433);
        label = 'Pet Supplies & Store';
        break;
    }

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoHeader(PetEstablishmentModel place) {
    if (place.photoUrl != null && place.photoUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              place.photoUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF7A433),
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              },
              errorBuilder: (ctx, error, stackTrace) =>
                  _buildFallbackBanner(place),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _buildCategoryBadge(place.category),
          ),
        ],
      );
    } else if (place.photoName != null && _isLoadingDetails) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFF7A433),
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 10),
            Text(
              'Loading establishment photo...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          _buildFallbackBanner(place),
          Positioned(
            top: 10,
            left: 10,
            child: _buildCategoryBadge(place.category),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                _buildPhotoHeader(place),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                    ),
                    if (place.isOpenNow != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: place.isOpenNow!
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: place.isOpenNow!
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          place.isOpenNow! ? 'OPEN' : 'CLOSED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: place.isOpenNow!
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (place.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        place.rating!.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${place.userRatingsTotal ?? 0} reviews)',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.address,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                if (place.weekdayDescriptions != null &&
                    place.weekdayDescriptions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      leading: Icon(Icons.access_time_rounded,
                          size: 18, color: Colors.grey.shade600),
                      title: Text(
                        'Operating Hours',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                      children: place.weekdayDescriptions!
                          .map(
                            (desc) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      desc,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: place.phoneNumber == null
                            ? null
                            : () => launchUrl(
                                Uri.parse('tel:${place.phoneNumber}')),
                        icon: const Icon(Icons.phone),
                        label: Text(
                          place.phoneNumber ??
                              (_isLoadingDetails ? 'Loading...' : 'No Phone'),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openDirections(
                          place.latitude,
                          place.longitude,
                        ),
                        icon: const Icon(Icons.directions),
                        label: Text(
                          'Directions',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7A433),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}