import 'dart:developer'; // For logging
import 'package:petwise/contracts/health_event/health_event_response.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'api_client.dart';

class HealthEventService {
  final ApiClient _apiClient;

  HealthEventService(this._apiClient);

  /// POST /HealthEvent
  Future<int> createHealthEvent(CreateHealthEventRequest request) async {
    try {
      final response = await _apiClient.post('HealthEvent', request.toJson());
      return response as int;
    } catch (e) {
      log('Error in createHealthEvent: $e');
      throw Exception(
        'Failed to create health event. Please check your input.',
      );
    }
  }

  /// GET /HealthEvent/{event_id}
  Future<HealthEventResponse> getHealthEvent(int eventId) async {
    try {
      final response = await _apiClient.get('HealthEvent/$eventId');
      return HealthEventResponse.fromJson(response);
    } catch (e) {
      log('Error in getHealthEvent: $e');
      throw Exception('Could not find the requested health event.');
    }
  }

  /// GET /HealthEvent?pet_id={pet_id}
  Future<List<HealthEventResponse>> getHealthEventsByPet(int petId) async {
    try {
      final response = await _apiClient.get('HealthEvent?pet_id=$petId');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => HealthEventResponse.fromJson(json)).toList();
    } catch (e) {
      log('Error in getHealthEventsByPet: $e');
      throw Exception('Failed to fetch health events for this pet.');
    }
  }

  /// PATCH /HealthEvent/{event_id}/complete
  Future<String> completeHealthEvent(int eventId) async {
    try {
      final response = await _apiClient.patch(
        'HealthEvent/$eventId/complete',
        {},
      );
      return response['message'] as String;
    } catch (e) {
      log('Error in completeHealthEvent: $e');
      throw Exception('Failed to mark health event as completed.');
    }
  }

  /// DELETE /HealthEvent/{event_id}
  Future<String> deleteHealthEvent(int eventId) async {
    try {
      final response = await _apiClient.delete('HealthEvent/$eventId');
      return response['message'] as String;
    } catch (e) {
      log('Error in deleteHealthEvent: $e');
      throw Exception('Failed to delete health event.');
    }
  }
}
