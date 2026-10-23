import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_config.dart';
import '../utils/error_mapper.dart';

class ApiClient {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeoutDuration = Duration(seconds: 15);

  final FlutterSecureStorage storage;

  ApiClient({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token;
    try {
      token = await storage.read(key: 'token');
    } catch (_) {
      token = null;
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      _handleNetworkException(e);
    }
  }

  // POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      _handleNetworkException(e);
    }
  }

  // PATCH
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      _handleNetworkException(e);
    }
  }

  // PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      _handleNetworkException(e);
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      _handleNetworkException(e);
    }
  }

  Never _handleNetworkException(Object e) {
    if (e is AppException) throw e;
    final appError = ErrorMapper.from(e);
    throw AppException(
      message: appError.message,
      statusCode: appError.statusCode,
      technicalDetails: e,
    );
  }

  dynamic _handleResponse(http.Response response) {
    final dynamic decodedBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map) {
        return Map<String, dynamic>.from(decodedBody);
      }
      return decodedBody;
    }

    debugPrint("API ERROR [${response.statusCode}]: $decodedBody");

    String errorMessage = 'An unexpected error occurred';
    if (decodedBody is Map) {
      errorMessage =
          decodedBody['message'] ?? decodedBody['error'] ?? errorMessage;
    }

    throw AppException(
      message: errorMessage,
      statusCode: response.statusCode,
      technicalDetails: response.body,
    );
  }
}
