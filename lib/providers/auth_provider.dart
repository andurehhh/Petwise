import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petwise/contracts/auth/signin_request.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
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
    _setLoading(true);
    try {
      await _authService.signUp(request);
      _setLoading(false);
      return true;
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

  // --- 4. CHANGE PASSWORD ---
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      final email = _userProvider.user?.email;
      if (email == null) {
        _handleError('User session expired. Please log in again.');
        return false;
      }
      await _authService.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout({
    required PetProvider petProvider,
    required ActivityProvider activityProvider,
  }) async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      _userId = null;
      _errorMessage = null;

      _userProvider.clear();
      petProvider.clear();
      activityProvider.clear();

      notifyListeners();
    } catch (e) {
      _handleError("Logout failed: $e");
    }
  }

  // --- 6. GOOGLE LOGIN ---
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final authResponse = await _authService.signInWithGoogle();
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

  // --- HELPERS ---
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
