import 'dart:developer';
import 'package:petwise/contracts/activity/activity_response.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/contracts/activity/update_activity_request.dart';
import 'api_client.dart';
import '../utils/error_mapper.dart';

class ActivityService {
  final ApiClient _apiClient;

  ActivityService(this._apiClient);

  Future<int> createActivity(CreateActivityRequest request) async {
    try {
      final response = await _apiClient.post('Activity', request.toJson());
      return response['activity_id'] as int;
    } catch (e) {
      log('Error in createActivity: $e');
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to create activity. Please check your input.',
        technicalDetails: e,
      );
    }
  }

  Future<ActivityResponse> getActivity(int activityId) async {
    try {
      final response = await _apiClient.get('Activity/$activityId');
      return ActivityResponse.fromJson(response);
    } catch (e) {
      log('Error in getActivity: $e');
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Could not find the requested activity.',
        technicalDetails: e,
      );
    }
  }

  Future<List<ActivityResponse>> getActivitiesByPet(int petId) async {
    try {
      final response = await _apiClient.get('Activity/pet/$petId');

      // Handle null or empty responses safely to avoid cast errors
      if (response == null) return [];

      final List list = response as List;
      return list.map((e) => ActivityResponse.fromJson(e)).toList();
    } catch (e) {
      log('Error in getActivitiesByPet: $e');
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to load activities',
        technicalDetails: e,
      );
    }
  }

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
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to update activity. Try again later.',
        technicalDetails: e,
      );
    }
  }

  Future<String> deleteActivity(int activityId) async {
    try {
      final response = await _apiClient.delete('Activity/$activityId');
      return response['message'] as String;
    } catch (e) {
      log('Error in deleteActivity: $e');
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to delete activity.',
        technicalDetails: e,
      );
    }
  }
}
