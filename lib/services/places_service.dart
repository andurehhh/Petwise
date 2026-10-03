import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/models/pet_establishment_model.dart';
import '../utils/app_config.dart';

class PlacesService {
  final String _apiKey = AppConfig.googlePlacesApiKey;

  Map<String, String> _buildHeaders([String? fieldMask]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
    };

    if (fieldMask != null && fieldMask.isNotEmpty) {
      headers['X-Goog-FieldMask'] = fieldMask;
    }

    if (!kIsWeb && Platform.isAndroid) {
      if (AppConfig.androidPackageName.isNotEmpty) {
        headers['X-Android-Package'] = AppConfig.androidPackageName;
      }
      if (AppConfig.androidCertSha1.isNotEmpty) {
        headers['X-Android-Cert'] =
            AppConfig.androidCertSha1.replaceAll(':', '').toUpperCase();
      }
    }

    return headers;
  }

  Future<List<PetEstablishmentModel>> getNearbyEstablishments({
    required double latitude,
    required double longitude,
    required double radiusInMeters,
    required EstablishmentCategory category,
  }) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchText');

    String query;
    String includedType;
    switch (category) {
      case EstablishmentCategory.clinic:
        query = 'veterinary clinic';
        includedType = 'veterinary_care';
        break;
      case EstablishmentCategory.grooming:
        query = 'pet grooming salon parlor';
        includedType = 'pet_care';
        break;
      case EstablishmentCategory.shop:
        query = 'pet store';
        includedType = 'pet_store';
        break;
    }

    final headers = _buildHeaders(
      'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.nationalPhoneNumber,places.photos,places.primaryType,places.types',
    );

    final body = jsonEncode({
      'textQuery': query,
      'includedType': includedType,
      'locationBias': {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': radiusInMeters,
        }
      },
      'maxResultCount': 20,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch nearby places: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final places = data['places'] as List<dynamic>? ?? [];

    List<PetEstablishmentModel> results = places
        .map((p) => PetEstablishmentModel.fromGooglePlaces(p, category))
        .toList();

    // Secondary strict validation for grooming to filter out non-grooming shops
    if (category == EstablishmentCategory.grooming) {
      results = results.where(_isStrictGroomingEstablishment).toList();
    }

    return results;
  }

  bool _isStrictGroomingEstablishment(PetEstablishmentModel place) {
    final nameLower = place.name.toLowerCase();

    const nonGroomingKeywords = [
      'fish',
      'aquarium',
      'aquatics',
      'aquatic',
      'koi',
      'arowana',
      'bird',
      'birds',
      'aviary',
      'reptile',
      'poultry',
      'fighting cock',
      'gamefowl',
      'feed supply',
      'feeds supply',
      'poultry supply',
    ];

    const groomingSignals = [
      'groom',
      'grooming',
      'salon',
      'spa',
      'parlor',
      'parlour',
      'barber',
      'barbershop',
      'fur',
    ];

    final hasNonGrooming =
        nonGroomingKeywords.any((kw) => nameLower.contains(kw));
    if (hasNonGrooming) {
      final hasGrooming = groomingSignals.any((kw) => nameLower.contains(kw));
      if (!hasGrooming) {
        return false;
      }
    }

    return true;
  }

  Future<void> fetchEstablishmentDetails(PetEstablishmentModel place) async {
    // 1. Fetch place details if phone number or hours are not yet cached
    if (place.phoneNumber == null || place.weekdayDescriptions == null) {
      try {
        final url =
            Uri.parse('https://places.googleapis.com/v1/places/${place.id}');
        final headers = _buildHeaders(
          'nationalPhoneNumber,regularOpeningHours.weekdayDescriptions,photos',
        );

        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          place.phoneNumber = data['nationalPhoneNumber'] ?? place.phoneNumber;
          final openingHours =
              data['regularOpeningHours'] as Map<String, dynamic>?;
          if (openingHours != null &&
              openingHours['weekdayDescriptions'] != null) {
            place.weekdayDescriptions =
                List<String>.from(openingHours['weekdayDescriptions']);
          }
          final photos = data['photos'] as List<dynamic>?;
          if (photos != null && photos.isNotEmpty && place.photoName == null) {
            place.photoName = photos[0]['name'] as String?;
          }
        }
      } catch (e) {
        debugPrint('Error fetching place details: $e');
      }
    }

    // 2. Fetch photoUrl if photoName is available and photoUrl is not yet loaded
    if (place.photoName != null && place.photoUrl == null) {
      place.photoUrl = await fetchPhotoUrl(place.photoName!);
    }
  }

  Future<String?> fetchPhotoUrl(
    String photoName, {
    int maxHeight = 400,
    int maxWidth = 600,
  }) async {
    try {
      final url = Uri.parse(
        'https://places.googleapis.com/v1/$photoName/media?maxHeightPx=$maxHeight&maxWidthPx=$maxWidth&skipHttpRedirect=true&key=$_apiKey',
      );
      final headers = _buildHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['photoUri'] as String?;
      } else {
        debugPrint(
            'Failed to fetch photo media: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching photo URL: $e');
    }
    return null;
  }
}