import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/pet_establishment_model.dart';
import '../../providers/essential_services_provider.dart';
import '../widgets/petwise_Navbar.dart';

class EssentialServicesScreen extends StatefulWidget {
  const EssentialServicesScreen({super.key});

  @override
  State<EssentialServicesScreen> createState() => _EssentialServicesScreenState();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emergency, color: Colors.red, size: 26),
                  SizedBox(width: 8),
                  Text('Emergency Hotlines & Care', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              ...kDefaultPetHotlines.map(
                (h) => Card(
                  elevation: 0,
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(h.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.red),
                      onPressed: () => launchUrl(Uri.parse('tel:${h.phone}')),
                    ),
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
      appBar: AppBar(
        title: const Text('Nearby Services'),
        backgroundColor: const Color(0xFFF7A433),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Emergency Hotlines',
            icon: const Icon(Icons.emergency, color: Colors.white),
            onPressed: _showHotlinesModal,
          ),
        ],
      ),
      body: Stack(

        children: [
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
              myLocationButtonEnabled: true,
            )
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFFF7A433))),

          // Filters and Radius Bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Clinics', EstablishmentCategory.clinic, provider),
                      const SizedBox(width: 8),
                      _buildChip('Grooming', EstablishmentCategory.grooming, provider),
                      const SizedBox(width: 8),
                      _buildChip('Pet Shops', EstablishmentCategory.shop, provider),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radar, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${(provider.radiusMeters / 1000).toStringAsFixed(0)} km'),
                      Slider(
                        value: provider.radiusMeters,
                        min: 2000,
                        max: 20000,
                        divisions: 9,
                        activeColor: const Color(0xFFF7A433),
                        onChanged: (val) {
                          provider.setRadius(val, onMarkerTap: _showEstablishmentDetails);
                        },
                        onChangeEnd: (_) {
                          if (provider.userLocation != null && _mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                provider.userLocation!,
                                _calculateZoom(provider.radiusMeters),
                              ),
                            );
                          }
                          provider.fetchPlaces(onMarkerTap: _showEstablishmentDetails);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (provider.isLoading)
            Positioned(
              bottom: 24,
              left: MediaQuery.of(context).size.width / 2 - 20,
              child: const CircularProgressIndicator(color: Color(0xFFF7A433)),
            )
          else if (provider.error != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (provider.establishments.isEmpty && provider.userLocation != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'No establishments found nearby. Try increasing the radius.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: const 
      PetwiseNavbar(navbarIndex: 4),
    );
  }

  Widget _buildChip(
    String label,
    EstablishmentCategory category,
    EssentialServicesProvider provider,
  ) {
    final isSelected = provider.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFF7A433),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          provider.setCategory(category, onMarkerTap: _showEstablishmentDetails);
        }
      },
    );
  }
}

class _EstablishmentDetailSheet extends StatefulWidget {
  final PetEstablishmentModel place;

  const _EstablishmentDetailSheet({required this.place});

  @override
  State<_EstablishmentDetailSheet> createState() => _EstablishmentDetailSheetState();
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
        context.read<EssentialServicesProvider>().loadDetails(widget.place).then((_) {
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
    final webMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
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
            style: TextStyle(
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
              errorBuilder: (ctx, error, stackTrace) => _buildFallbackBanner(place),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF7A433), strokeWidth: 2.5),
            SizedBox(height: 10),
            Text(
              'Loading establishment photo...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (place.isOpenNow != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: place.isOpenNow! ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: place.isOpenNow! ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          place.isOpenNow! ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: place.isOpenNow! ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (place.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        place.rating!.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${place.userRatingsTotal ?? 0} reviews)',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
                if (place.weekdayDescriptions != null && place.weekdayDescriptions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      leading: Icon(Icons.access_time_rounded, size: 18, color: Colors.grey.shade600),
                      title: const Text(
                        'Operating Hours',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      children: place.weekdayDescriptions!
                          .map(
                            (desc) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      desc,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                            : () => launchUrl(Uri.parse('tel:${place.phoneNumber}')),
                        icon: const Icon(Icons.phone),
                        label: Text(
                          place.phoneNumber ?? (_isLoadingDetails ? 'Loading...' : 'No Phone'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openDirections(place.latitude, place.longitude),
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7A433),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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