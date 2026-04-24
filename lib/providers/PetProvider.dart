import 'package:flutter/material.dart';
import 'package:petwise/data/models/pet_model.dart';

class PetProvider extends ChangeNotifier {
  final List<Pet> _pets = [
    //dummy data
    Pet(
      id: "01d",
      createdAt: DateTime(2023, 10, 10),
      userId: "100",
      name: "Mocha",
      species: "Dog",
      birthday: DateTime(2023, 10, 10),
      sex: "male",
    ),
    Pet(
      id: "02c",
      createdAt: DateTime(2024, 06, 10),
      userId: "100",
      name: "Jamba",
      species: "Cat",
      birthday: DateTime(2024, 06, 04),
      sex: "male",
    ),
  ];

  Pet? _selectedPet = Pet(
    id: "01",
    createdAt: DateTime(2023, 10, 10),
    userId: "100",
    name: "Mocha",
    species: "dog",
    birthday: DateTime(2023, 10, 10),
    sex: "male",
  );

  List<Pet> get pets => _pets;
  // REPLACE THIS
  // Pet? get selectedPet => _selectedPet;
  Pet? get selectedPet => _selectedPet;

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void deselectPet() {
    _selectedPet = null;
    notifyListeners();
  }

  void addPet(Pet newPet) {
    _pets.add(newPet);
    notifyListeners();
  }

  void updatePetInfo(String newName, String newSpecies) {
    if (_selectedPet == null) return;
    _selectedPet = Pet(
      id: _selectedPet!.id,
      createdAt: _selectedPet!.createdAt,
      userId: _selectedPet!.userId,

      name: newName ?? _selectedPet!.name,
      species: newSpecies ?? _selectedPet!.species,
      birthday: _selectedPet!.birthday,
      sex: _selectedPet!.sex,
    );

    print("Provider: Updated user to ${_selectedPet!.name}");
    notifyListeners();
  }
}
