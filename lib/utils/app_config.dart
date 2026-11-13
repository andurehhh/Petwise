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
  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static const String androidPackageName = String.fromEnvironment(
    'ANDROID_PACKAGE_NAME',
    defaultValue: 'com.petwise.app',
  );

  static const String androidCertSha1 = String.fromEnvironment(
    'ANDROID_CERT_SHA1',
    defaultValue: 'B16D9E1571CE5E6BEF5C830B46E99C28FCE41A6D',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: '',
  );

  /// Resolves the current runtime environment ('dev', 'staging', 'prod')
  /// based on explicit APP_ENV or inferred from API_BASE_URL.
  static String get currentEnvironment {
    if (appEnv.isNotEmpty) {
      return appEnv.toLowerCase().trim();
    }
    final url = apiBaseUrl.toLowerCase();
    if (url.contains('staging') || url.contains('test')) {
      return 'staging';
    }
    if (url.contains('dev') || url.contains('localhost') || url.contains('10.0.2.2')) {
      return 'dev';
    }
    return 'prod';
  }

  static void validate() {
    if (apiBaseUrl.isEmpty) {
      throw Exception(
        'Missing API_BASE_URL! Did you forget --dart-define-from-file=.env ?',
      );
    }
  }
}
