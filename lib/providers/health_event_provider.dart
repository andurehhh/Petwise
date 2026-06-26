import 'package:flutter/material.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'package:petwise/contracts/health_event/health_event_response.dart';
import 'package:petwise/services/health_event_service.dart';
import 'package:petwise/services/notif_service.dart'; // Import Notification Service
import 'package:petwise/data/models/notification_model.dart'; // Import Notification Model

class HealthEventProvider extends ChangeNotifier {
  HealthEventService? _healthEventService;

  bool _isLoading = false;
  String? _errorMessage;
  List<HealthEventResponse> _healthEvents = [];
  HealthEventResponse? _selectedEvent;

  List<HealthEventResponse> get healthEvents => _healthEvents;
  HealthEventResponse? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateHealthEventService(HealthEventService service) {
    _healthEventService = service;
  }

  Future<void> loadAllHealthEvents(List<int> petIds) async {
    if (_healthEventService == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait(
        petIds.map((id) => _healthEventService!.getHealthEventsByPet(id)),
      );
      final fetched = results.expand((list) => list).toList();
      final seen = <int>{};
      _healthEvents = fetched.where((e) => seen.add(e.eventId)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPetHealthEvents(int petId) async {
    if (_healthEventService == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final responses = await _healthEventService!.getHealthEventsByPet(petId);
      _healthEvents.removeWhere((e) => e.petId == petId);
      _healthEvents.addAll(responses);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNewHealthEvent(CreateHealthEventRequest request) async {
    if (_healthEventService == null) {
      throw Exception("Health Event service is not available.");
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Create the event and get the ID
      final int eventId = await _healthEventService!.createHealthEvent(request);

      // Reload local data
      await loadPetHealthEvents(request.petId);

      // Schedule notification for the health event
      final notification = ActivityNotification(
        id: eventId,
        title: "Petwise: ${request.eventName}",
        body: "Health event for your pet is scheduled for today!",
        scheduleTime: request.eventDate,
        recurrence: 'none', // Health events are typically one-time
      );
      await NotifService().scheduledNotification(notification);

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

  Future<bool> markEventAsCompleted(int eventId) async {
    if (_healthEventService == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _healthEventService!.completeHealthEvent(eventId);

      // Cancel the notification as the event is completed
      await NotifService().cancelNotification(eventId);

      final index = _healthEvents.indexWhere(
            (event) => event.eventId == eventId,
      );
      if (index != -1) {
        final current = _healthEvents[index];
        final updated = HealthEventResponse(
          eventId: current.eventId,
          petId: current.petId,
          eventName: current.eventName,
          eventDate: current.eventDate,
          type: current.type,
          isCompleted: true,
          createdAt: current.createdAt,
        );
        _healthEvents[index] = updated;
        if (_selectedEvent?.eventId == eventId) {
          _selectedEvent = updated;
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

  Future<bool> deleteHealthEvent(int eventId) async {
    if (_healthEventService == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _healthEventService!.deleteHealthEvent(eventId);

      // Cancel notification when event is deleted
      await NotifService().cancelNotification(eventId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}