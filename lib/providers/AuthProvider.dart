import 'package:flutter/material.dart';
import 'package:petwise/contracts/auth/signin_request.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthService _authService;
  UserProvider _userProvider;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService, this._userProvider);

  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  void updateDependencies(AuthService service, UserProvider userProvider) {
    _authService = service;
    _userProvider = userProvider;
  }

  // --- 1. SIGN IN ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = SignInRequest(email: email, password: password);
      final authResponse = await _authService.signIn(request);

      // DEBUG: Is the ID actually coming back from the server?
      print("DEBUG: authResponse.userId is ${authResponse.userId}");

      // Fetch the full user data immediately after login
      await _userProvider.loadUser(authResponse.userId);

      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 2. SIGN UP ---
  Future<bool> signUp(SignUpRequest request) async {
    _setLoading(true);
    try {
      // Your service returns a Map here. Usually, you'd check for success.
      await _authService.signUp(request);

      _setLoading(false);
      return true; // Return true so UI can navigate back to Login
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 3. FORGOT PASSWORD ---
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Helper methods to keep code DRY (Don't Repeat Yourself)
  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _handleError(dynamic e) {
    _isLoading = false;
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
  }
}