import 'dart:io';

/// Result container for pre-upload media validation.
class MediaValidationResult {
  final bool isValid;
  final String? errorMessage;

  const MediaValidationResult._({required this.isValid, this.errorMessage});

  const MediaValidationResult.success() : this._(isValid: true);
  const MediaValidationResult.failure(String message)
      : this._(isValid: false, errorMessage: message);
}

/// Security and size validation guardrails before dispatching network uploads.
class MediaValidator {
  // File size limits
  static const int maxAvatarBytes = 3 * 1024 * 1024; // 3 MB
  static const int maxImageBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxDocumentBytes = 10 * 1024 * 1024; // 10 MB

  // Allowed image file extensions
  static const Set<String> allowedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  // Allowed document/health record extensions
  static const Set<String> allowedDocumentExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
  };

  /// Validates an image file before upload.
  static MediaValidationResult validateImage(
    File file, {
    int maxBytes = maxImageBytes,
    Set<String> allowedExtensions = allowedImageExtensions,
  }) {
    if (!file.existsSync()) {
      return const MediaValidationResult.failure('The selected file does not exist.');
    }

    final length = file.lengthSync();
    if (length == 0) {
      return const MediaValidationResult.failure('The selected file is empty.');
    }

    if (length > maxBytes) {
      final double maxMb = maxBytes / (1024 * 1024);
      final double actualMb = length / (1024 * 1024);
      return MediaValidationResult.failure(
        'File size (${actualMb.toStringAsFixed(1)} MB) exceeds the ${maxMb.toStringAsFixed(0)} MB limit.',
      );
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return const MediaValidationResult.failure('File has no valid extension.');
    }

    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return MediaValidationResult.failure(
        'Format .$extension is not supported. Allowed formats: ${allowedExtensions.map((e) => e.toUpperCase()).join(", ")}',
      );
    }

    return const MediaValidationResult.success();
  }
}
