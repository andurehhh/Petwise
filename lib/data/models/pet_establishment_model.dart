enum EstablishmentCategory { clinic, grooming, shop }

class PetEstablishmentModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final bool? isOpenNow;
  final EstablishmentCategory category;
  String? phoneNumber;
  List<String>? weekdayDescriptions;
  String? photoName;
  String? photoUrl;

  PetEstablishmentModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.rating,
    this.userRatingsTotal,
    this.isOpenNow,
    this.phoneNumber,
    this.weekdayDescriptions,
    this.photoName,
    this.photoUrl,
  });

  factory PetEstablishmentModel.fromGooglePlaces(
    Map<String, dynamic> json,
    EstablishmentCategory category,
  ) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final displayName = json['displayName'] as Map<String, dynamic>? ?? {};
    final regularHours = json['regularOpeningHours'] as Map<String, dynamic>?;
    final photos = json['photos'] as List<dynamic>?;

    String? photoName;
    if (photos != null && photos.isNotEmpty) {
      photoName = photos[0]['name'] as String?;
    }

    List<String>? weekdayDescriptions;
    if (regularHours != null && regularHours['weekdayDescriptions'] != null) {
      weekdayDescriptions =
          List<String>.from(regularHours['weekdayDescriptions']);
    }

    return PetEstablishmentModel(
      id: json['id'] as String? ?? '',
      name: displayName['text'] as String? ?? 'Pet Facility',
      address: json['formattedAddress'] as String? ?? 'No address listed',
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['userRatingCount'] as int?,
      isOpenNow: regularHours?['openNow'] as bool?,
      category: category,
      phoneNumber: json['nationalPhoneNumber'] as String?,
      weekdayDescriptions: weekdayDescriptions,
      photoName: photoName,
    );
  }
}

class EmergencyHotlineModel {
  final String title;
  final String description;
  final String phone;

  const EmergencyHotlineModel({
    required this.title,
    required this.description,
    required this.phone,
  });
}

const List<EmergencyHotlineModel> kDefaultPetHotlines = [
  EmergencyHotlineModel(
    title: 'PAWS Animal Rehabilitation & Clinic',
    description: 'Animal rescue, clinic assistance, and emergency triage',
    phone: '0284751686',
  ),
  EmergencyHotlineModel(
    title: 'Vets In Practice (24/7 Emergency Hospital)',
    description: 'Round-the-clock emergency medical dispatch and admission',
    phone: '0285311581',
  ),
  EmergencyHotlineModel(
    title: 'National Pet Poison Information Hotline',
    description: 'Immediate guidance for toxic ingestions and snake/bug bites',
    phone: '09178387297',
  ),
];