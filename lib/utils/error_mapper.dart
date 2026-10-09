import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Categories of errors for standardized handling across PetWise.
enum ErrorCategory {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
  validation,
  unknown,
}

/// A structured, human-friendly error representation.
///
/// Contains clean, non-technical English copy for users, while securely
/// preserving technical details for debug logging and support.
class AppError {
  final ErrorCategory category;
  final String title;
  final String message;
  final List<String> instructions;
  final bool isOffline;
  final int? statusCode;
  final String? technicalDetails;

  const AppError({
    required this.category,
    required this.title,
    required this.message,
    required this.instructions,
    this.isOffline = false,
    this.statusCode,
    this.technicalDetails,
  });

  @override
  String toString() => '$title: $message';
}

/// Custom exception thrown by ApiClient carrying HTTP status and humanized details.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic technicalDetails;

  const AppException({
    required this.message,
    this.statusCode,
    this.technicalDetails,
  });

  @override
  String toString() => message;
}

/// Translates low-level HTTP status codes, Socket exceptions, and Dart errors
/// into standardized, user-friendly English guidelines without leaking backend URLs.
class ErrorMapper {
  /// Maps any caught error or exception into a sanitized, user-friendly [AppError].
  static AppError from(Object error) {
    final rawDetails = error.toString();

    // 1. Check for custom AppException from ApiClient
    if (error is AppException) {
      if (error.statusCode == null) {
        final lowerMsg = error.message.toLowerCase();
        if (lowerMsg.contains('internet') ||
            lowerMsg.contains('offline') ||
            lowerMsg.contains('reach petwise') ||
            lowerMsg.contains('connection')) {
          return _createNetworkError(
            error.technicalDetails?.toString() ?? rawDetails,
          );
        }
      }
      return _mapFromStatusCode(
        error.statusCode,
        serverMessage: error.message,
        technicalDetails: error.technicalDetails?.toString() ?? rawDetails,
      );
    }

    // 2. Direct Dart SocketException (Offline / DNS lookup failure)
    if (error is SocketException) {
      return _createNetworkError(rawDetails);
    }

    // 3. Direct Dart TimeoutException
    if (error is TimeoutException) {
      return _createTimeoutError(rawDetails);
    }

    // 4. http.ClientException (often wraps SocketException)
    if (error is http.ClientException) {
      if (error.uri?.toString().contains('places.googleapis.com') == true ||
          rawDetails.toLowerCase().contains('places.googleapis.com')) {
        return _createPlacesNetworkError(rawDetails);
      }
      return _createNetworkError(rawDetails);
    }

    // 5. SSL / TLS Handshake Exception
    if (error is HandshakeException || error is CertificateException) {
      return AppError(
        category: ErrorCategory.network,
        title: 'Secure Connection Failed',
        message:
            'A secure connection could not be established with the server. Please check your device date and time settings.',
        instructions: const [
          'Verify your device time and date are set to automatic',
          'Disconnect any active VPN or proxy service',
          'Tap "Try Again" to reconnect',
        ],
        isOffline: false,
        technicalDetails: rawDetails,
      );
    }

    // 6. FormatException (Invalid JSON or unexpected response format)
    if (error is FormatException) {
      return AppError(
        category: ErrorCategory.server,
        title: 'Unexpected Server Response',
        message:
            'We received an unexpected response from the server. Our team has been notified.',
        instructions: const [
          'Tap "Try Again" in a few moments',
          'Ensure your app is updated to the latest version',
        ],
        isOffline: false,
        technicalDetails: rawDetails,
      );
    }

    final lower = rawDetails.toLowerCase();

    // 7. Google Sign-In PlatformException & network error detection
    if (lower.contains('network_error') ||
        lower.contains('apiexception: 7') ||
        lower.contains('apiexception: 8') ||
        lower.contains('api7:') ||
        (lower.contains('com.google.android.gms') &&
            (lower.contains('network') || lower.contains('api')))) {
      return AppError(
        category: ErrorCategory.network,
        title: 'No Internet Connection',
        message:
            'Google Sign-In requires an active internet connection. Please check your network and try again.',
        instructions: const [
          'Check if your Wi-Fi or mobile data is turned on',
          'Verify that Airplane Mode is disabled',
          'Tap "Continue with Google" once reconnected',
        ],
        isOffline: true,
        technicalDetails: rawDetails,
      );
    }

    // 8. Google Places / Map services exception detection
    if (lower.contains('places.googleapis.com') ||
        lower.contains('googleplaces') ||
        lower.contains('getnearbyestablishments')) {
      if (lower.contains('socketexception') ||
          lower.contains('failed host lookup') ||
          lower.contains('clientexception') ||
          lower.contains('network') ||
          lower.contains('connection')) {
        return AppError(
          category: ErrorCategory.network,
          title: 'No Internet Connection',
          message:
              'Unable to load nearby places. Please check your internet connection and try again.',
          instructions: const [
            'Check if your Wi-Fi or mobile data is turned on',
            'Verify that Airplane Mode is disabled',
            'Tap "Retry" to search nearby places again',
          ],
          isOffline: true,
          technicalDetails: rawDetails,
        );
      }
      return AppError(
        category: ErrorCategory.server,
        title: 'Map Service Unavailable',
        message:
            'Unable to load nearby places right now. Please try again in a moment.',
        instructions: const [
          'Wait a few moments and tap "Retry"',
          'Check your location settings',
        ],
        isOffline: false,
        technicalDetails: rawDetails,
      );
    }

    // 9. General network & socket keywords inspection
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('no address associated with hostname') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('broken pipe') ||
        lower.contains('xmlhttprequest error') ||
        lower.contains('clientexception') ||
        lower.contains('failed to connect') ||
        lower.contains('no internet')) {
      return _createNetworkError(rawDetails);
    }

    // 10. Timeout inspection
    if (lower.contains('timeoutexception') ||
        lower.contains('timed out') ||
        lower.contains('deadline exceeded')) {
      return _createTimeoutError(rawDetails);
    }

    // 11. HTTP status code pattern matching from strings like "Error 401: ..." or "status code: 500"
    final statusMatch = RegExp(
      r'(?:error|status|code)\s*:?\s*(\d{3})',
      caseSensitive: false,
    ).firstMatch(rawDetails);
    if (statusMatch != null) {
      final code = int.tryParse(statusMatch.group(1) ?? '');
      if (code != null) {
        return _mapFromStatusCode(code, technicalDetails: rawDetails);
      }
    }

    // 12. Fallback: Generic, safe error with sanitized message
    return AppError(
      category: ErrorCategory.unknown,
      title: 'Something Went Wrong',
      message: _sanitizeMessage(
        rawDetails,
        fallback:
            'An unexpected error occurred while processing your request. Please try again.',
      ),
      instructions: const [
        'Check your internet connection',
        'Tap "Try Again" to retry the action',
        'If the issue persists, try again in a few moments',
      ],
      isOffline: false,
      technicalDetails: rawDetails,
    );
  }

  /// Maps an HTTP status code to a humanized [AppError].
  static AppError _mapFromStatusCode(
    int? statusCode, {
    String? serverMessage,
    String? technicalDetails,
  }) {
    final sanitizedServerMsg = serverMessage != null
        ? _sanitizeMessage(serverMessage, fallback: '')
        : '';

    switch (statusCode) {
      case 400:
        return AppError(
          category: ErrorCategory.validation,
          title: 'Invalid Request',
          message: sanitizedServerMsg.isNotEmpty
              ? sanitizedServerMsg
              : 'The requested action could not be processed due to invalid data.',
          instructions: const [
            'Review the information you entered',
            'Ensure all required fields are complete',
            'Tap "Try Again" once corrected',
          ],
          statusCode: 400,
          technicalDetails: technicalDetails,
        );

      case 401:
        return AppError(
          category: ErrorCategory.unauthorized,
          title: 'Session Expired',
          message:
              'Your session has expired or is invalid. Please log in again to continue.',
          instructions: const [
            'Log in with your PetWise account',
            'If you were already logged in, try signing out and back in',
          ],
          statusCode: 401,
          technicalDetails: technicalDetails,
        );

      case 403:
        return AppError(
          category: ErrorCategory.forbidden,
          title: 'Access Restricted',
          message:
              'You do not have permission to view or modify this resource.',
          instructions: const [
            'Ensure you are logged in with the correct account',
            'Contact PetWise support if you believe this is an error',
          ],
          statusCode: 403,
          technicalDetails: technicalDetails,
        );

      case 404:
        return AppError(
          category: ErrorCategory.notFound,
          title: 'Information Not Found',
          message: sanitizedServerMsg.isNotEmpty
              ? sanitizedServerMsg
              : 'The requested record or item could not be located.',
          instructions: const [
            'Refresh your screen to see the latest data',
            'Check if the item was deleted or moved',
          ],
          statusCode: 404,
          technicalDetails: technicalDetails,
        );

      case 409:
        return AppError(
          category: ErrorCategory.conflict,
          title: 'Action Conflict',
          message: sanitizedServerMsg.isNotEmpty
              ? sanitizedServerMsg
              : 'This action conflicts with existing records (e.g., duplicate entry).',
          instructions: const [
            'Check for existing records with the same name or schedule',
            'Modify your details and try again',
          ],
          statusCode: 409,
          technicalDetails: technicalDetails,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          category: ErrorCategory.server,
          title: 'Server Unavailable',
          message:
              'Our servers are temporarily experiencing high traffic or maintenance. Please try again shortly.',
          instructions: const [
            'Wait a few moments and tap "Try Again"',
            'Check back shortly while our team restores service',
          ],
          statusCode: statusCode,
          technicalDetails: technicalDetails,
        );

      default:
        return AppError(
          category: ErrorCategory.unknown,
          title: 'Unable to Complete Request',
          message: sanitizedServerMsg.isNotEmpty
              ? sanitizedServerMsg
              : 'A communication error occurred with the server. Please try again.',
          instructions: const [
            'Check your network connection',
            'Tap "Try Again" to retry',
          ],
          statusCode: statusCode,
          technicalDetails: technicalDetails,
        );
    }
  }

  static AppError _createNetworkError(String technicalDetails) {
    return AppError(
      category: ErrorCategory.network,
      title: 'No Internet Connection',
      message:
          'We could not reach PetWise servers. Please check your internet connection and try again.',
      instructions: const [
        'Check if your Wi-Fi or mobile data is turned on',
        'Verify that Airplane Mode is disabled',
        'Tap "Try Again" once reconnected',
      ],
      isOffline: true,
      technicalDetails: technicalDetails,
    );
  }

  static AppError _createPlacesNetworkError(String technicalDetails) {
    return AppError(
      category: ErrorCategory.network,
      title: 'No Internet Connection',
      message:
          'Unable to load nearby places. Please check your internet connection and try again.',
      instructions: const [
        'Check if your Wi-Fi or mobile data is turned on',
        'Verify that Airplane Mode is disabled',
        'Tap "Retry" to search nearby places again',
      ],
      isOffline: true,
      technicalDetails: technicalDetails,
    );
  }

  static AppError _createTimeoutError(String technicalDetails) {
    return AppError(
      category: ErrorCategory.timeout,
      title: 'Connection Timed Out',
      message:
          'The server took too long to respond. Your connection might be slow or unstable.',
      instructions: const [
        'Check your Wi-Fi or cellular signal strength',
        'Move to an area with better coverage',
        'Tap "Try Again" below',
      ],
      isOffline: false,
      technicalDetails: technicalDetails,
    );
  }

  /// Scrubs URLs, domains, port numbers, OS error codes, and technical jargon
  /// from user-facing copy.
  static String _sanitizeMessage(String rawMessage, {required String fallback}) {
    var sanitized = rawMessage;

    // Remove any "Exception: ", "ClientException: ", "PlatformException: " prefix (even repeated)
    sanitized = sanitized.replaceAll(
      RegExp(r'(?:[A-Za-z]+Exception|Exception):\s*', caseSensitive: false),
      '',
    );

    // Remove any URLs (e.g. https://... or uri=https://...)
    sanitized = sanitized.replaceAll(RegExp(r'uri=https?://[^\s,)]+'), '');
    sanitized = sanitized.replaceAll(RegExp(r'https?://[^\s,)]+'), '');
    sanitized = sanitized.replaceAll('places.googleapis.com', '');

    // Remove OS error codes like "(OS Error: No address associated with hostname, errno = 7)"
    sanitized = sanitized.replaceAll(RegExp(r'\(OS Error:[^)]+\)'), '');

    // Clean up leftover punctuation or whitespace
    sanitized = sanitized.trim();
    while (sanitized.startsWith(':') || sanitized.startsWith(',')) {
      sanitized = sanitized.substring(1).trim();
    }
    while (sanitized.endsWith(':') || sanitized.endsWith(',')) {
      sanitized = sanitized.substring(0, sanitized.length - 1).trim();
    }

    // If sanitized message still looks like low-level code/stack trace or is too cryptic, return fallback
    final lower = sanitized.toLowerCase();
    if (lower.contains('failed host lookup') ||
        lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('network_error') ||
        lower.contains('apiexception') ||
        lower.contains('errno =') ||
        lower.isEmpty ||
        sanitized.length > 200) {
      return fallback;
    }

    return sanitized;
  }
}

