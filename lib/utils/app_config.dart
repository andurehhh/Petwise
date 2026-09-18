class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

static void validate() {
    if (apiBaseUrl.isEmpty) {
      throw Exception(
        'Missing API_BASE_URL! Did you forget --dart-define-from-file=.env ?',
      );
    }
  }
}
