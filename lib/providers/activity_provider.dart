import 'package:flutter/material.dart';
import 'package:petwise/data/models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  final List<ActivityModel> _activities = [
    ActivityModel(
      id: 'act_001',
      createdAt: DateTime.now(),
      petId: 1,
      title: 'Morning Walk',
      description: 'Quick walk around the park',
      scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      isCompleted: false,
      recurrence: 'Daily',
    ),
    ActivityModel(
      id: 'act_002',
      createdAt: DateTime.now(),
      petId: 2,
      title: 'Vet Appointment',
      description: 'Annual check-up and vaccines',
      scheduledDate: DateTime.now().add(const Duration(hours: 3)),
      isCompleted: false,
    ),
    ActivityModel(
      id: 'act_003',
      createdAt: DateTime.now(),
      petId: 1,
      title: 'Grooming Session',
      description: 'Full hair trim and nail clip',
      scheduledDate: DateTime.now().add(const Duration(hours: 5)),
      isCompleted: false,
    ),
    ActivityModel(
      id: 'act_004',
      createdAt: DateTime.now(),
      petId: 2,
      title: 'Feeding Time',
      description: 'British Shorthair special diet',
      scheduledDate: DateTime.now().add(const Duration(hours: 7)),
      isCompleted: false,
      recurrence: 'Daily',
    ),
  ];

  List<ActivityModel> get activities => _activities;

  void addActivity(ActivityModel activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void toggleCompletion(String id) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _activities[index].isCompleted = !_activities[index].isCompleted;
      notifyListeners();
    }
  }
}
