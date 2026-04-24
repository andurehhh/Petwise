import 'package:flutter/material.dart';
import 'package:petwise/contracts/pet/create_pet_request.dart';
import 'package:petwise/contracts/pet/update_pet_request.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  PetService? _petService;
  bool _isLoading = false;
  String? _errorMessage;

  List<Pet> _pets = [
    // //dummy data
    // Pet(
    //   id: 01,
    //   createdAt: DateTime(2023, 10, 10),
    //   userId: "100",
    //   name: "Mocha",
    //   species: "dog",
    //   birthday: DateTime(2023, 10, 10),
    //   sex: "male",
    // ),
    // Pet(
    //   id: 02,
    //   createdAt: DateTime(2024, 06, 10),
    //   userId: "100",
    //   name: "Jamba",
    //   species: "dog",
    //   birthday: DateTime(2024, 06, 04),
    //   sex: "male",
    // ),
  ];

  Pet? _selectedPet;
  // Pet? _selectedPet = Pet(
  //   id: 01,
  //   createdAt: DateTime(2023, 10, 10),
  //   userId: "100",
  //   name: "Mocha",
  //   species: "dog",
  //   birthday: DateTime(2023, 10, 10),
  //   sex: "male",
  // );

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //method for ProxyProvider
  void updatePetService(PetService service) {
    _petService = service;
  }

  //Fetching
  Future<void> loadUserPets(String userid) async {
    if(_petService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await _petService!.getPetsByUser(userid);
      _pets = responses.map((res) => Pet(
        id: res.petId,
        name: res.name,
        species: res.species,
        userId: res.userId,
        birthday: res.birthday,
        sex: res.sex,
        createdAt: res.createdAt,
      )).toList();

      if(_pets.isNotEmpty && _selectedPet == null){
        _selectedPet = _pets.first;
      }
    }catch(e){
      _errorMessage =e.toString();
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNewPet(CreatePetRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _petService!.createPet(request);
      // After creating, re-fetch the list to stay updated
      await loadUserPets(request.userId);
    } catch (e) {
      _errorMessage = e.toString();
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

Future<bool> updatePet(int petId, UpdatePetRequest request) async {
  if (_petService == null) return false;

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    //API req to update pet
    final response = await _petService!.updatePet(petId, request);

    //convert response to pet model
    final updatedPet = Pet(
      id: response.petId,
      name: response.name,
      species: response.species,
      userId: response.userId,
      birthday: response.birthday,
      sex: response.sex,
      createdAt: response.createdAt,
      weight: response.weight,
      breed: response.breed
    );
    //update pets list

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
