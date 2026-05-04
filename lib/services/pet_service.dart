import 'api_client.dart';
import '../contracts/pet/create_pet_request.dart';
import '../contracts/pet/update_pet_request.dart';
import '../contracts/pet/pet_response.dart';

class PetService {
  final ApiClient _apiClient;
  PetService(this._apiClient);

  Future<int> createPet(CreatePetRequest request) async {
    try {
      final response = await _apiClient.post('Pet/', request.toJson());
      return response['pet_id'];
    } catch (e) {
      throw Exception('Failed to create pet: $e');
    }
  }

  Future<PetResponse> getPet(int petId) async {
    try {
      final response = await _apiClient.get('Pet/$petId');
      return PetResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  Future<List<PetResponse>> getPetsByUser(String userId) async {
    try {
      final response = await _apiClient.get('Pet?user_id=$userId');
      return (response as List)
          .map((json) => PetResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pets: $e');
    }
  }

  Future<PetResponse> updatePet(int petId, UpdatePetRequest request) async {
    try {
      final response = await _apiClient.patch('Pet/$petId', request.toJson());
      return PetResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      await _apiClient.delete('Pet/$petId');
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }
}
