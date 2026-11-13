import '../../utils/app_config.dart';

enum MediaCategory {
  userAvatar,
  petProfile,
  penBackground,
  healthRecord,
}

/// Standardized directory destination and path generator for cloud storage uploads.
class StorageDestination {
  final MediaCategory category;
  final String? entityId;
  final String environment;

  StorageDestination({
    required this.category,
    this.entityId,
    String? environment,
  }) : environment = environment ?? AppConfig.currentEnvironment;

  /// Factory for Pet Profile photos
  factory StorageDestination.petProfile({
    String? petId,
    String? environment,
  }) {
    return StorageDestination(
      category: MediaCategory.petProfile,
      entityId: petId ?? 'temp',
      environment: environment,
    );
  }

  /// Factory for User Avatars
  factory StorageDestination.userAvatar({
    String? userId,
    String? environment,
  }) {
    return StorageDestination(
      category: MediaCategory.userAvatar,
      entityId: userId ?? 'me',
      environment: environment,
    );
  }

  /// Factory for Pen Background uploads
  factory StorageDestination.penBackground({
    String? userId,
    String? environment,
  }) {
    return StorageDestination(
      category: MediaCategory.penBackground,
      entityId: userId ?? 'me',
      environment: environment,
    );
  }

  /// Factory for Health & Medical Records
  factory StorageDestination.healthRecord({
    String? petId,
    String? environment,
  }) {
    return StorageDestination(
      category: MediaCategory.healthRecord,
      entityId: petId ?? 'general',
      environment: environment,
    );
  }

  /// Generates the canonical directory folder path for cloud storage (Cloudinary/S3/Firebase).
  String get folderPath {
    final cleanId = (entityId == null || entityId!.trim().isEmpty)
        ? 'general'
        : entityId!.trim();

    return 'petwise/$environment/${_subpath(cleanId)}';
  }

  String _subpath(String cleanId) {
    switch (category) {
      case MediaCategory.userAvatar:
        return 'users/$cleanId/avatar';
      case MediaCategory.penBackground:
        return 'users/$cleanId/pen_backgrounds';
      case MediaCategory.petProfile:
        return 'pets/$cleanId/profile';
      case MediaCategory.healthRecord:
        return 'health/$cleanId/records';
    }
  }

  @override
  String toString() => folderPath;
}
