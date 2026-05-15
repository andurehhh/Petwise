import 'package:flutter/material.dart';
import 'package:petwise/data/models/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  final List<ActivityModel> _activities = [];

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
