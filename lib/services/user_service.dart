import 'api_client.dart';
import '../contracts/user/user_response.dart';
import '../contracts/user/update_user_request.dart';

class UserService {
  final ApiClient _apiClient;
  UserService(this._apiClient);

  Future<UserResponse> getUser(String userId) async {
    try {
      final response = await _apiClient.get('User/$userId');
      return UserResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<UserResponse> updateUser(
    String userId,
    UpdateUserRequest request,
  ) async {
    try {
      final response = await _apiClient.patch('User/$userId', request.toJson());
      return UserResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> markSetupComplete(String userId) async {
    try {
      await _apiClient.patch('User/$userId', {'has_completed_setup': true});
    } catch (e) {
      throw Exception('Failed to mark setup complete: $e');
    }
  }
}
