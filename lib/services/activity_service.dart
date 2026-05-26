import 'dart:developer'; // For logging
import 'package:petwise/contracts/activity/activity_response.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/contracts/activity/update_activity_request.dart';
import 'api_client.dart';

class ActivityService {
  final ApiClient _apiClient;

  ActivityService(this._apiClient);

  /// POST /Activity
  Future<int> createActivity(CreateActivityRequest request) async {
    try {
      final response = await _apiClient.post('Activity', request.toJson());
      return response['activity_id'] as int;
    } catch (e) {
      log('Error in createActivity: $e');
      throw Exception('Failed to create activity. Please check your input.');
    }
  }

  /// GET /Activity/{id}
  Future<ActivityResponse> getActivity(int activityId) async {
    try {
      final response = await _apiClient.get('Activity/$activityId');
      return ActivityResponse.fromJson(response);
    } catch (e) {
      log('Error in getActivity: $e');
      throw Exception('Could not find the requested activity.');
    }
  }

  ///TODO: GET /Activity
  /// Returns all activities for the authenticated user
  Future<List<ActivityResponse>> getAllActivities() async {
    try {
      final response = await _apiClient.get('Activity');
      if(response == null) return [];
      return (response as List)
          .map((json) => ActivityResponse.fromJson(json))
          .toList();
    } catch (e) {
      log('Error in getAllActivities: $e');
      throw Exception('Failed to load activities.');
    }
  }

  ///TODO: GET /Activity/Pet/{pet_id:int}
  Future<List<ActivityResponse>> getActivitiesByPet(int petId) async {
    try {
      final response = await _apiClient.get('Activity/Pet/$petId');
      if (response == null) return [];
      return (response as List)
          .map((json) => ActivityResponse.fromJson(json))
          .toList();
    } catch (e) {
      log('Error in getActivitiesByPet: $e');
      throw Exception('Failed to load activities for this pet.');
    }
  }

  /// PATCH /Activity/{id}
  Future<ActivityResponse> patchActivity(
    int activityId,
    UpdateActivityRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        'Activity/$activityId',
        request.toJson(),
      );
      return ActivityResponse.fromJson(response);
    } catch (e) {
      log('Error in patchActivity: $e');
      throw Exception('Failed to update activity. Try again later.');
    }
  }

  /// DELETE /Activity/{id}
  Future<String> deleteActivity(int activityId) async {
    try {
      final response = await _apiClient.delete('Activity/$activityId');
      return response['message'] as String;
    } catch (e) {
      log('Error in deleteActivity: $e');
      throw Exception('Failed to delete activity.');
    }
  }
}
