import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../contracts/auth/signin_request.dart';
import '../contracts/auth/signup_request.dart';
import '../contracts/auth/auth_response.dart';
import '../utils/app_config.dart';
import '../utils/error_mapper.dart';

class AuthService {
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleServerClientId,
  );

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
      if (e is AppException) rethrow;
      final appError = ErrorMapper.from(e);
      throw AppException(message: appError.message, technicalDetails: e);
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
      if (e is AppException) rethrow;
      final appError = ErrorMapper.from(e);
      throw AppException(message: appError.message, technicalDetails: e);
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
      if (e is AppException) rethrow;
      final appError = ErrorMapper.from(e);
      throw AppException(message: appError.message, technicalDetails: e);
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
      if (e is AppException) rethrow;
      final appError = ErrorMapper.from(e);
      throw AppException(message: appError.message, technicalDetails: e);
    }
  }

  //GOOGLE SIGN IN
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AppException(
          message: 'Google Sign-In was cancelled or incomplete.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AppException(
          message: 'Failed to retrieve credentials from Google. Please try again.',
        );
      }

      final response = await _apiClient.post('Auth/GoogleSignIn', {
        'idToken': idToken,
      });
      final authResponse = AuthResponse.fromJson(
        response as Map<String, dynamic>,
      );

      await _apiClient.storage.write(
        key: 'token',
        value: authResponse.accessToken,
      );
      return authResponse;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (e is AppException) rethrow;
      final appError = ErrorMapper.from(e);
      throw AppException(message: appError.message, technicalDetails: e);
    }
  }
}
