import 'package:flutter/material.dart';
import 'package:petwise/contracts/analytics/pet_activity_health_analytics_response.dart';
import 'package:petwise/contracts/analytics/user_dashboard_analytics_response.dart';
import 'package:petwise/services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  AnalyticsService _analyticsService;

  AnalyticsProvider(this._analyticsService);

  /// Proxy update hook to automatically refresh the dependency when the ApiClient token changes
  void updateAnalyticsService(AnalyticsService analyticsService) {
    _analyticsService = analyticsService;
  }

  // --- STATE CACHING VARIABLES ---
  PetActivityHealthAnalyticsResponse? _petAnalytics;
  UserDashboardAnalyticsResponse? _userAnalytics;
  bool _isLoading = false;
  String? _error;

  // --- PUBLIC STATE GETTERS ---
  PetActivityHealthAnalyticsResponse? get petAnalytics => _petAnalytics;
  UserDashboardAnalyticsResponse? get userAnalytics => _userAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches metrics and timeline series for a single specific pet
  Future<void> loadPetAnalytics(int petId) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _analyticsService.getPetAnalytics(petId);
      _petAnalytics = result;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches global dashboard aggregated summaries for a specific user UUID
  Future<void> loadUserAnalytics(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _analyticsService.getUserAnalytics(userId);
      _userAnalytics = result;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Clears down all internal metric memory cache (useful upon logging out)
  void clear() {
    _petAnalytics = null;
    _userAnalytics = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Reset error boundary parameters without affecting data states
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
