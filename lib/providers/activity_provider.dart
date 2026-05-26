import 'package:flutter/material.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/contracts/activity/update_activity_request.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/data/models/notification_model.dart';
import 'package:petwise/services/notification_service.dart';
import 'package:petwise/services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  ActivityService? _activityService;
  final NotificationService _notificationService = NotificationService();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _recentlyCompletedIds = {};

  Set<int> get recentlyCompletedIds => _recentlyCompletedIds;
  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateActivityService(ActivityService service) {
    _activityService = service;
  }

  // Option B: Load ALL activities by gathering from all pets
  Future<void> loadAllActivities(List<int> petIds) async {
    if (_activityService == null || petIds.isEmpty) {
      _activities = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<ActivityModel> allFetchedActivities = [];

      // Fetch for all pets in parallel
      final results = await Future.wait(
          petIds.map((id) => _activityService!.getActivitiesByPet(id))
      );

      for (var responses in results) {
        allFetchedActivities.addAll(responses.map((res) => ActivityModel(
          id: res.activityId,
          createdAt: res.createdAt,
          petId: res.petId,
          title: res.title,
          description: res.description,
          scheduledDate: _parseScheduledTime(res.timeScheduled),
          isCompleted: !res.isActive,
          recurrence: res.recurrence,
        )));
      }

      _activities = allFetchedActivities;
      // Sort: Pending/Upcoming first
      _activities.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    } catch (e) {
      _errorMessage = e.toString();
      print("Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load activities for a specific pet
  Future<void> loadActivities(int petId) async {
    if (_activityService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await _activityService!.getActivitiesByPet(petId);
      _activities = responses.map((res) => ActivityModel(
        id: res.activityId,
        createdAt: res.createdAt,
        petId: res.petId,
        title: res.title,
        description: res.description,
        scheduledDate: _parseScheduledTime(res.timeScheduled),
        isCompleted: !res.isActive,
        recurrence: res.recurrence,
      )).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(CreateActivityRequest request) async {
    if (_activityService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activityId = await _activityService!.createActivity(request);
      
      final newActivityRes = await _activityService!.getActivity(activityId);
      
      final newActivity = ActivityModel(
        id: newActivityRes.activityId,
        createdAt: newActivityRes.createdAt,
        petId: newActivityRes.petId,
        title: newActivityRes.title,
        description: newActivityRes.description,
        scheduledDate: _parseScheduledTime(newActivityRes.timeScheduled),
        isCompleted: !newActivityRes.isActive,
        recurrence: newActivityRes.recurrence,
      );

      _activities.add(newActivity);
      _activities.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      final notification = ActivityNotification(
        id: newActivity.id.toString(),
        title: "Petwise: ${newActivity.title}",
        body: newActivity.description ?? "It's time to take care of your pet!",
        scheduleTime: newActivity.scheduledDate,
      );
      await _notificationService.scheduleNotification(notification);

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(int activityId) async {
    if (_activityService == null) return;

    final index = _activities.indexWhere((a) => a.id == activityId);
    if (index != -1) {
      final activity = _activities[index];
      final newIsActive = activity.isCompleted; 

      try {
        final request = UpdateActivityRequest(isActive: newIsActive);
        final response = await _activityService!.patchActivity(activityId, request);

        _activities[index].isCompleted = !response.isActive;
        _recentlyCompletedIds.add(activityId);
        notifyListeners();

        if(_activities[index].isCompleted){
          _recentlyCompletedIds.add(activityId);
          notifyListeners();

          await Future.delayed(const Duration(milliseconds: 1500));
          _recentlyCompletedIds.remove(activityId);
        }
        notifyListeners();
      }
      catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> updateActivity(int activityId, UpdateActivityRequest request) async {
    if (_activityService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _activityService!.patchActivity(activityId, request);
      
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        _activities[index] = ActivityModel(
          id: response.activityId,
          createdAt: response.createdAt,
          petId: response.petId,
          title: response.title,
          description: response.description,
          scheduledDate: _parseScheduledTime(response.timeScheduled),
          isCompleted: !response.isActive,
          recurrence: response.recurrence,
        );
      }
      
      if (request.timeScheduled != null || request.title != null) {
        await _notificationService.cancelNotification(activityId.toString());
        final updatedActivity = _activities[index];
        final notification = ActivityNotification(
          id: updatedActivity.id.toString(),
          title: "Petwise: ${updatedActivity.title}",
          body: updatedActivity.description ?? "It's time to take care of your pet!",
          scheduleTime: updatedActivity.scheduledDate,
        );
        await _notificationService.scheduleNotification(notification);
      }

    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(int activityId) async {
    if (_activityService == null) return;

    try {
      await _activityService!.deleteActivity(activityId);
      await _notificationService.cancelNotification(activityId.toString());
      _activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clear() {
    _activities = [];
    _isLoading = false;
    _errorMessage = null;
    // _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  DateTime _parseScheduledTime(String timeStr) {
    try {
      return DateTime.parse(timeStr);
    } catch (_) {
      final now = DateTime.now();
      final parts = timeStr.split(':');
      return DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
          parts.length > 2 ? int.parse(parts[2]) : 0
      );
    }
  }
}
