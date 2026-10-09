import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:petwise/utils/app_config.dart';
import 'package:petwise/utils/error_mapper.dart';

String _getApiBaseUrl() {
  if (AppConfig.apiBaseUrl.isNotEmpty) {
    return AppConfig.apiBaseUrl;
  }
  if (Platform.environment.containsKey('API_BASE_URL') &&
      Platform.environment['API_BASE_URL']!.isNotEmpty) {
    return Platform.environment['API_BASE_URL']!;
  }
  final envFile = File('.env');
  if (envFile.existsSync()) {
    for (final line in envFile.readAsLinesSync()) {
      if (line.startsWith('API_BASE_URL=')) {
        final val = line.substring('API_BASE_URL='.length).trim();
        if (val.isNotEmpty) return val;
      }
    }
  }
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.petwise.app',
  );
}

void main() {
  group('ErrorMapper Tests', () {
    test('Translates SocketException to network offline error without leaking endpoint', () {
      final apiBaseUrl = _getApiBaseUrl();
      final host = Uri.tryParse(apiBaseUrl)?.host ?? 'api.petwise.app';
      final socketError = SocketException(
        "Failed host lookup: '$host'",
        osError: const OSError('No address associated with hostname', 7),
      );

      final appError = ErrorMapper.from(socketError);

      expect(appError.category, ErrorCategory.network);
      expect(appError.isOffline, isTrue);
      expect(appError.title, 'No Internet Connection');
      expect(appError.message, contains('check your internet connection'));
      // Verify no raw URL, host, or errno is leaked in the user message
      expect(appError.message.contains(apiBaseUrl), isFalse);
      expect(appError.message.contains(host), isFalse);
      expect(appError.message.contains('errno = 7'), isFalse);
      expect(appError.instructions, isNotEmpty);
    });

    test('Translates http.ClientException wrapping SocketException to network error', () {
      final apiBaseUrl = _getApiBaseUrl();
      final host = Uri.tryParse(apiBaseUrl)?.host ?? 'api.petwise.app';
      final clientException = http.ClientException(
        "ClientException with SocketException: Failed host lookup: '$host' (OS Error: errno = 7)",
        Uri.parse('$apiBaseUrl/Pet'),
      );

      final appError = ErrorMapper.from(clientException);

      expect(appError.category, ErrorCategory.network);
      expect(appError.isOffline, isTrue);
      expect(appError.title, 'No Internet Connection');
      expect(appError.message.contains(host), isFalse);
      expect(appError.message.contains(apiBaseUrl), isFalse);
    });

    test('Translates TimeoutException to timeout error', () {
      final timeout = TimeoutException('Request timed out after 15 seconds');
      final appError = ErrorMapper.from(timeout);

      expect(appError.category, ErrorCategory.timeout);
      expect(appError.isOffline, isFalse);
      expect(appError.title, 'Connection Timed Out');
      expect(appError.instructions, isNotEmpty);
    });

    test('Translates HTTP status codes from AppException', () {
      final authError = ErrorMapper.from(
        const AppException(message: 'Token expired', statusCode: 401),
      );
      expect(authError.category, ErrorCategory.unauthorized);
      expect(authError.title, 'Session Expired');
      expect(authError.statusCode, 401);

      final notFoundError = ErrorMapper.from(
        const AppException(message: 'Pet not found', statusCode: 404),
      );
      expect(notFoundError.category, ErrorCategory.notFound);
      expect(notFoundError.title, 'Information Not Found');
      expect(notFoundError.statusCode, 404);

      final serverError = ErrorMapper.from(
        const AppException(message: 'Internal server error', statusCode: 500),
      );
      expect(serverError.category, ErrorCategory.server);
      expect(serverError.title, 'Server Unavailable');
      expect(serverError.statusCode, 500);

      final conflictError = ErrorMapper.from(
        const AppException(message: 'Pet already registered', statusCode: 409),
      );
      expect(conflictError.category, ErrorCategory.conflict);
      expect(conflictError.title, 'Action Conflict');
      expect(conflictError.statusCode, 409);
    });

    test('Sanitizes URLs and OS error codes from string exceptions', () {
      final apiBaseUrl = _getApiBaseUrl();
      final rawStringError =
          "Exception: Failed to connect to $apiBaseUrl/api/v1 (OS Error: errno = 111)";
      final appError = ErrorMapper.from(rawStringError);

      expect(appError.message.contains(apiBaseUrl), isFalse);
      expect(appError.message.contains('errno = 111'), isFalse);
    });

    test('Translates Google Sign-In PlatformException to human-friendly offline message', () {
      const rawPlatformError =
          'PlatformException(network_error, com.google.android.gms.common.api.ApiException: 7: , null, null)';
      final appError = ErrorMapper.from(rawPlatformError);

      expect(appError.category, ErrorCategory.network);
      expect(appError.isOffline, isTrue);
      expect(appError.title, 'No Internet Connection');
      expect(appError.message, contains('Google Sign-In requires an active internet connection'));
      expect(appError.message.contains('PlatformException'), isFalse);
      expect(appError.message.contains('ApiException'), isFalse);
      expect(appError.message.contains('com.google'), isFalse);
    });

    test('Translates Google Places ClientException without leaking places.googleapis.com', () {
      final placesError = http.ClientException(
        "ClientException with SocketException: Failed host lookup: 'places.googleapis.com' (OS Error: No address associated with hostname, errno = 7)",
        Uri.parse('https://places.googleapis.com/v1/places:searchText'),
      );
      final appError = ErrorMapper.from(placesError);

      expect(appError.category, ErrorCategory.network);
      expect(appError.isOffline, isTrue);
      expect(appError.title, 'No Internet Connection');
      expect(appError.message, contains('Unable to load nearby places'));
      expect(appError.message.contains('places.googleapis.com'), isFalse);
      expect(appError.message.contains('ClientException'), isFalse);
    });

    test('Sanitizes Exception prefix cleanly from Activity planner error', () {
      const rawActivityError = 'Exception: Failed to load activities';
      final appError = ErrorMapper.from(rawActivityError);

      expect(appError.message.startsWith('Exception:'), isFalse);
      expect(appError.message, 'Failed to load activities');
    });
  });
}

