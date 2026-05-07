import 'api_client.dart';
import '../contracts/auth/signin_request.dart';
import '../contracts/auth/signup_request.dart';
import '../contracts/auth/auth_response.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // SIGN IN
  Future<AuthResponse> signIn(SignInRequest request) async {
    try {
      final response = await _apiClient.post('Auth/Signin', request.toJson());
      final authResponse = AuthResponse.fromJson(
        response as Map<String, dynamic>,
      );

      await _apiClient.storage.write(
        key: 'token',
        value: authResponse.accessToken,
      );

      return authResponse;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // SIGN UP
  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    try {
      final response = await _apiClient.post('Auth/Signup', request.toJson());

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return {'message': 'Signup successful.', 'success': true};
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post('Auth/ForgotPassword', {
        'email': email,
      });
      return (response as Map<String, dynamic>?) ?? {};
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // CHANGE PASSWORD
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post('Auth/ChangePassword', {
        'email': email,
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return (response as Map<String, dynamic>?) ?? {};
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
