import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/pet_establishment_model.dart';
import '../services/places_service.dart';

class EssentialServicesProvider with ChangeNotifier {
  PlacesService? _placesService;

  LatLng? _userLocation;
  double _radiusMeters = 5000.0;
  EstablishmentCategory _selectedCategory = EstablishmentCategory.clinic;

  List<PetEstablishmentModel> _establishments = [];
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  bool _isLoading = false;
  String? _error;

  LatLng? get userLocation => _userLocation;
  double get radiusMeters => _radiusMeters;
  EstablishmentCategory get selectedCategory => _selectedCategory;
  List<PetEstablishmentModel> get establishments => _establishments;
  Set<Marker> get markers => _markers;
  Set<Circle> get circles => _circles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updatePlacesService(PlacesService service) {
    _placesService = service;
  }

  Future<void> initLocationAndFetch({void Function(PetEstablishmentModel)? onMarkerTap}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _userLocation = LatLng(position.latitude, position.longitude);
      await fetchPlaces(onMarkerTap: onMarkerTap);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlaces({void Function(PetEstablishmentModel)? onMarkerTap}) async {
    if (_userLocation == null || _placesService == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _establishments = await _placesService!.getNearbyEstablishments(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        radiusInMeters: _radiusMeters,
        category: _selectedCategory,
      );

      debugPrint("✅ Places fetched: ${_establishments.length} for ${_selectedCategory.name}");
      _buildOverlays(onMarkerTap);
    } catch (e) {
      debugPrint("❌ Error fetching nearby places: $e");
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(EstablishmentCategory category, {void Function(PetEstablishmentModel)? onMarkerTap}) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchPlaces(onMarkerTap: onMarkerTap);
  }

  void setRadius(double radius, {void Function(PetEstablishmentModel)? onMarkerTap}) {
    _radiusMeters = radius;
    _buildOverlays(onMarkerTap);
    notifyListeners();
  }

  Future<void> loadDetails(PetEstablishmentModel place) async {
    if (_placesService == null) return;
    await _placesService!.fetchEstablishmentDetails(place);
    notifyListeners();
  }

  void _buildOverlays(void Function(PetEstablishmentModel)? onMarkerTap) {
    if (_userLocation == null) return;

    final newMarkers = <Marker>{};
    for (final place in _establishments) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
            onTap: onMarkerTap != null ? () => onMarkerTap(place) : null,
          ),
          onTap: onMarkerTap != null ? () => onMarkerTap(place) : null,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _selectedCategory == EstablishmentCategory.clinic
                ? BitmapDescriptor.hueRed
                : _selectedCategory == EstablishmentCategory.grooming
                    ? BitmapDescriptor.hueCyan
                    : BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    final newCircles = <Circle>{
      Circle(
        circleId: const CircleId('search_boundary'),
        center: _userLocation!,
        radius: _radiusMeters,
        fillColor: const Color(0xFFF7A433).withValues(alpha: 0.12),
        strokeColor: const Color(0xFFF7A433),
        strokeWidth: 2,
      ),
    };

    _markers = newMarkers;
    _circles = newCircles;
  }
}