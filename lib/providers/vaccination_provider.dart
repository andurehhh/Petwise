import 'package:flutter/material.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'package:petwise/data/models/vaccination_model.dart';
import 'package:petwise/services/health_event_service.dart';

class VaccinationProvider with ChangeNotifier {
  HealthEventService? _healthEventService;

  List<VaccinationModel> _vaccinations = [];
  bool _isLoading = false;
  String? _error;

  List<VaccinationModel> get vaccinations => _vaccinations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateHealthEventService(HealthEventService service) {
    _healthEventService = service;
  }

  List<VaccinationModel> forPet(int petId) =>
      _vaccinations.where((v) => v.petId == petId).toList()
        ..sort((a, b) => b.dateGiven.compareTo(a.dateGiven));

  Future<void> loadVaccinationsForPet(int petId) async {
    if (_healthEventService == null) return;
    _setLoading(true);
    try {
      final events = await _healthEventService!.getHealthEventsByPet(petId);
      final vaccEvents = events.where((e) => e.type == 'vaccination').toList();
      // Remove existing entries for this pet then re-add
      _vaccinations.removeWhere((v) => v.petId == petId);
      _vaccinations.addAll(
        vaccEvents.map((e) => VaccinationModel.fromHealthEvent(e)),
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addVaccination({
    required int petId,
    required String vaccineName,
    required DateTime dateGiven,
    DateTime? expiryDate,
  }) async {
    if (_healthEventService == null) throw Exception('Service unavailable');
    _setLoading(true);
    try {
      final encodedName = VaccinationModel.encodeEventName(vaccineName, expiryDate);
      final request = CreateHealthEventRequest(
        petId: petId,
        eventName: encodedName,
        eventDate: dateGiven,
        type: 'vaccination',
      );
      await _healthEventService!.createHealthEvent(request);
      await loadVaccinationsForPet(petId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVaccination({
    required int eventId,
    required int petId,
    required String vaccineName,
    required DateTime dateGiven,
    DateTime? expiryDate,
  }) async {
    if (_healthEventService == null) throw Exception('Service unavailable');
    _setLoading(true);
    try {
      // Delete old, create new (HealthEvent API has no PATCH for full update)
      await _healthEventService!.deleteHealthEvent(eventId);
      final encodedName = VaccinationModel.encodeEventName(vaccineName, expiryDate);
      final request = CreateHealthEventRequest(
        petId: petId,
        eventName: encodedName,
        eventDate: dateGiven,
        type: 'vaccination',
      );
      await _healthEventService!.createHealthEvent(request);
      await loadVaccinationsForPet(petId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVaccination(int eventId, int petId) async {
    if (_healthEventService == null) throw Exception('Service unavailable');
    _setLoading(true);
    try {
      await _healthEventService!.deleteHealthEvent(eventId);
      _vaccinations.removeWhere((v) => v.id == eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsAdministered(int eventId) async {
    if (_healthEventService == null) throw Exception('Service unavailable');
    try {
      await _healthEventService!.completeHealthEvent(eventId);
      final idx = _vaccinations.indexWhere((v) => v.id == eventId);
      if (idx != -1) {
        final v = _vaccinations[idx];
        _vaccinations[idx] = VaccinationModel(
          id: v.id,
          petId: v.petId,
          vaccineName: v.vaccineName,
          dateGiven: v.dateGiven,
          expiryDate: v.expiryDate,
          isCompleted: true,
          createdAt: v.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _vaccinations = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
