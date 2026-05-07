import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petwise/contracts/auth/signin_request.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthService _authService;
  UserProvider _userProvider;

  bool _isLoading = false;
  String? _errorMessage;

  String? _userId;

  AuthProvider(this._authService, this._userProvider);

  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  String? get userId => _userId;

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

      _userId = authResponse.userId;

      const storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: authResponse.accessToken);

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
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

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _handleError(dynamic e) {
    _isLoading = false;
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
  }
}
