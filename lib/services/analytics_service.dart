import 'dart:developer';
import 'package:petwise/contracts/analytics/pet_activity_health_analytics_response.dart';
import 'package:petwise/contracts/analytics/user_dashboard_analytics_response.dart';

import 'api_client.dart';

class AnalyticsService {
  final ApiClient _apiClient;

  AnalyticsService(this._apiClient);

  /// Retrieves dashboard analytics for a single specific pet
  Future<PetActivityHealthAnalyticsResponse> getPetAnalytics(int petId) async {
    try {
      final response = await _apiClient.get(
        'api/Analytics/Pet/$petId/activity-health',
      );

      if (response == null) {
        throw Exception('Server returned empty data.');
      }

      return PetActivityHealthAnalyticsResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      log('Error in getPetAnalytics: $e');
      throw Exception('Failed to load analytics metrics for this pet.');
    }
  }

  /// Retrieves global aggregated dashboard statistics for all of a user's active pets
  Future<UserDashboardAnalyticsResponse> getUserAnalytics(String userId) async {
    try {
      final response = await _apiClient.get(
        'api/Analytics/User/$userId/dashboard-summary',
      );

      if (response == null) {
        throw Exception('Server returned empty data.');
      }

      return UserDashboardAnalyticsResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      log('Error in getUserAnalytics: $e');
      throw Exception('Failed to load global user dashboard metrics.');
    }
  }
}
