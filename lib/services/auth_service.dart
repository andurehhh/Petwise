import 'api_client.dart';
import '../contracts/auth/signin_request.dart';
import '../contracts/auth/signup_request.dart';
import '../contracts/auth/auth_response.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  //  SIGN IN
  Future<AuthResponse> signIn(SignInRequest request) async {
    try {
      final response = await _apiClient.post('Auth/Signin', request.toJson());
      final authResponse = AuthResponse.fromJson(response);
      await _apiClient.storage.write(
        key: 'token',
        value: authResponse.accessToken,
      );
      return authResponse;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  //  SIGN UP
  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    try {
      final response = await _apiClient.post('Auth/Signup', request.toJson());
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  //  FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _apiClient.post('Auth/ForgotPassword', {
      'email': email,
    });

    return response;
  }
}
