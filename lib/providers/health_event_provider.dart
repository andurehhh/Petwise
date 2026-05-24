import 'package:flutter/material.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'package:petwise/contracts/health_event/health_event_response.dart';
import 'package:petwise/services/health_event_service.dart';

class HealthEventProvider extends ChangeNotifier {
  HealthEventService? _healthEventService;
  bool _isLoading = false;
  String? _errorMessage;

  // Mock initial data matching your pet's format for development/UI testing
  List<HealthEventResponse> _healthEvents = [
    HealthEventResponse(
      eventId: 1,
      petId: 4,
      eventName: "Rabies Shot",
      eventDate: DateTime(2026, 06, 15),
      type: "vaccination",
      isCompleted: false,
      createdAt: DateTime(2026, 05, 24),
    ),
    HealthEventResponse(
      eventId: 2,
      petId: 4,
      eventName: "Annual Dental Clean",
      eventDate: DateTime(2026, 07, 10),
      type: "checkup",
      isCompleted: true,
      createdAt: DateTime(2026, 05, 24),
    ),
  ];

  HealthEventResponse? _selectedEvent;

  List<HealthEventResponse> get healthEvents => _healthEvents;
  HealthEventResponse? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Updates the service instance when API clients change or initialize
  void updateHealthEventService(HealthEventService service) {
    _healthEventService = service;
  }

  /// Fetches all health events associated with a specific pet ID
  Future<void> loadPetHealthEvents(int petId) async {
    if (_healthEventService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await _healthEventService!.getHealthEventsByPet(petId);
      _healthEvents = responses;

      // Reset or adapt the single chosen event reference if needed
      if (_healthEvents.isNotEmpty && _selectedEvent == null) {
        _selectedEvent = _healthEvents.first;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a brand new health record entry and pulls fresh changes down
  Future<void> createNewHealthEvent(CreateHealthEventRequest request) async {
    if (_healthEventService == null) {
      throw Exception("Health Event service is not available.");
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _healthEventService!.createHealthEvent(request);
      // Reload using the petId target from the creation request parameters
      await loadPetHealthEvents(request.petId);
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

  /// Marks an individual health event as done/completed on the database side
  Future<bool> markEventAsCompleted(int eventId) async {
    if (_healthEventService == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _healthEventService!.completeHealthEvent(eventId);

      // Local State Sync: Find matching items locally and update their bool fields
      final index = _healthEvents.indexWhere(
        (event) => event.eventId == eventId,
      );
      if (index != -1) {
        final currentEvent = _healthEvents[index];
        final updatedEvent = HealthEventResponse(
          eventId: currentEvent.eventId,
          petId: currentEvent.petId,
          eventName: currentEvent.eventName,
          eventDate: currentEvent.eventDate,
          type: currentEvent.type,
          isCompleted: true, // Swapping status out explicitly
          createdAt: currentEvent.createdAt,
        );
        _healthEvents[index] = updatedEvent;

        if (_selectedEvent?.eventId == eventId) {
          _selectedEvent = updatedEvent;
        }
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

  /// Removes an entry completely from the local array cache and backend service
  Future<bool> deleteHealthEvent(int eventId) async {
    if (_healthEventService == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _healthEventService!.deleteHealthEvent(eventId);

      // Remove item locally upon verified server execution success
      _healthEvents.removeWhere((event) => event.eventId == eventId);

      if (_selectedEvent?.eventId == eventId) {
        _selectedEvent = null;
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

  void selectEvent(HealthEventResponse event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void deselectEvent() {
    _selectedEvent = null;
    notifyListeners();
  }
}
