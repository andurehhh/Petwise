class PetQrPayload {
  /// Generates the QR payload.
  /// If a contact number is available, generates a direct `tel:<number>` URI
  /// so that any smartphone camera scanning the QR code immediately prompts
  /// the finder to call the owner's phone number.
  /// Falls back to emergency contact text if no phone number is provided.
  static String generate({
    required int petId,
    required String petName,
    required String species,
    String? breed,
    required String sex,
    required String birthday,
    String? ownerName,
    String? contactNumber,
    String? address,
  }) {
    final cleanPhone = contactNumber?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
    if (cleanPhone.isNotEmpty) {
      return 'tel:$cleanPhone';
    }

    final breedText = (breed != null && breed.isNotEmpty) ? breed : species;
    final guardianName = (ownerName != null && ownerName.trim().isNotEmpty)
        ? ownerName.trim()
        : 'Pet Owner';

    return 'Petwise Emergency\\n'
        'Pet: $petName (#$petId)\\n'
        'Breed: $breedText ($sex)\\n'
        'Owner: $guardianName\\n'
        'Please help contact the owner!';
  }
}
