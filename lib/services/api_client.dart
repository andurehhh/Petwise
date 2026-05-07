import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://petwise-api-425628448755.asia-southeast1.run.app';

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
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response);
  }

  //  POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  //PATCH

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  //  PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  //  DELETE
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
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

    print("API ERROR BODY: $decodedBody");

    String errorMessage = 'An unexpected error occurred';
    if (decodedBody is Map) {
      errorMessage =
          decodedBody['message'] ?? decodedBody['error'] ?? errorMessage;
    }

    switch (response.statusCode) {
      case 400:
      case 409:
        throw Exception(errorMessage);
      case 401:
        throw Exception(
          errorMessage.contains('Unauthorized')
              ? errorMessage
              : 'Session expired. Please login again.',
        );
      case 500:
        throw Exception('Server error: $errorMessage');
      default:
        throw Exception('Error ${response.statusCode}: $errorMessage');
    }
  }
}
