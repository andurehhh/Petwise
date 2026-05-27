import 'package:flutter/material.dart';
import 'package:petwise/contracts/pet/create_pet_request.dart';
import 'package:petwise/contracts/pet/update_pet_request.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  PetService? _petService;
  bool _isLoading = false;
  String? _errorMessage;

  // Updated Mock Initial Data with image_url included
  List<Pet> _pets = [
    Pet(
      id: 1,
      createdAt: DateTime(2023, 10, 10),
      userId: "100",
      name: "Mocha",
      species: "dog",
      birthday: DateTime(2023, 10, 10),
      sex: "male",
      image_url: null, // Ready for network image URLs
    ),
    Pet(
      id: 2,
      createdAt: DateTime(2024, 06, 10),
      userId: "100",
      name: "Jamba",
      species: "cat",
      birthday: DateTime(2024, 06, 04),
      sex: "male",
      image_url: null,
    ),
    Pet(
      id: 3,
      createdAt: DateTime(2024, 06, 10),
      userId: "100",
      name: "Draeco",
      species: "rabbit",
      birthday: DateTime(2024, 08, 11),
      sex: "male",
      image_url: null,
    ),
  ];

  Pet? _selectedPet = Pet(
    id: 1,
    createdAt: DateTime(2023, 10, 10),
    userId: "100",
    name: "Mocha",
    species: "dog",
    birthday: DateTime(2023, 10, 10),
    sex: "male",
    image_url: null,
  );

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updatePetService(PetService service) {
    _petService = service;
  }

  Future<void> loadUserPets(String userid) async {
    if (_petService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await _petService!.getPetsByUser(userid);
      _pets = responses
          .map(
            (res) => Pet(
              id: res.petId, // Mapping cleanly to your ID change
              name: res.name,
              species: res.species,
              userId: res.userId,
              birthday: res.birthday,
              sex: res.sex,
              createdAt: res.createdAt,
              weight: res.weight,
              breed: res.breed,
              image_url: res
                  .image_url, // Added mapping for image_url from API contract response
            ),
          )
          .toList();

      if (_pets.isNotEmpty && _selectedPet == null) {
        _selectedPet = _pets.first;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNewPet(CreatePetRequest request) async {
    if (_petService == null) {
      throw Exception("Pet service is not available.");
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petService!.createPet(request);
      await loadUserPets(request.userId);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void deselectPet() {
    _selectedPet = null;
    notifyListeners();
  }

  void clear() {
    _pets = [];
    _selectedPet = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updatePet(int petId, UpdatePetRequest request) async {
    if (_petService == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petService!.updatePet(petId, request);

      final updatedPet = Pet(
        id: response.petId,
        name: response.name,
        species: response.species,
        userId: response.userId,
        birthday: response.birthday,
        sex: response.sex,
        createdAt: response.createdAt,
        weight: response.weight,
        breed: response.breed,
        image_url: response
            .image_url, // Added mapping here too so updates preserve the image
      );

      int index = _pets.indexWhere((pet) => pet.id == petId);
      if (index != -1) {
        _pets[index] = updatedPet;
      }
      if (_selectedPet?.id == petId) {
        _selectedPet = updatedPet;
      }
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
}
