import 'package:flutter/material.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/contracts/activity/update_activity_request.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  ActivityService _activityService;

  ActivityProvider(this._activityService);

  void updateActivityService(ActivityService activityService) {
    _activityService = activityService;
  }

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Extracts the hidden date tag `|d:YYYY-MM-DD` from a description string.
  /// Returns the parsed date and the clean description (tag removed).
  static ({DateTime? date, String description}) _extractDateTag(String raw) {
    const tag = '|d:';
    final idx = raw.lastIndexOf(tag);
    if (idx == -1) return (date: null, description: raw);

    final datePart = raw.substring(idx + tag.length).trim();
    final parsed = DateTime.tryParse(datePart);
    final cleanDesc = raw.substring(0, idx).trim();
    return (date: parsed, description: cleanDesc);
  }

  ActivityModel _mapToModel(dynamic response, {DateTime? dateContext}) {
    final rawDescription = (response.description as String?) ?? '';
    final extracted = _extractDateTag(rawDescription);

    // Priority: explicit dateContext (just created) > tag in description > createdAt
    final dateBase = dateContext ?? extracted.date ?? (response.createdAt as DateTime);

    final raw = response.timeScheduled as String;
    final fullParse = DateTime.tryParse(raw);

    final DateTime scheduledDate;
    if (fullParse != null) {
      scheduledDate = fullParse.toLocal();
    } else {
      final timeParts = raw.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      scheduledDate = DateTime(dateBase.year, dateBase.month, dateBase.day, hour, minute);
    }

    return ActivityModel(
      id: response.activityId.toString(),
      createdAt: response.createdAt,
      petId: response.petId,
      title: response.title,
      description: extracted.description.isEmpty ? null : extracted.description,
      scheduledDate: scheduledDate,
      isCompleted: !response.isActive,
      recurrence: response.recurrence,
    );
  }

  List<ActivityModel> _expandRecurring(ActivityModel base) {
    final recurrence = (base.recurrence ?? '').toLowerCase().trim();
    if (recurrence == 'none' || recurrence.isEmpty) return [base];

    final List<ActivityModel> expanded = [];
    final now = DateTime.now();
    final rangeEnd = DateTime(now.year, now.month + 3, now.day);

    DateTime cursor = base.scheduledDate;

    while (!cursor.isAfter(rangeEnd)) {
      expanded.add(
        ActivityModel(
          id: cursor.isAtSameMomentAs(base.scheduledDate)
              ? base.id
              : '${base.id}_${cursor.millisecondsSinceEpoch}',
          createdAt: base.createdAt,
          petId: base.petId,
          title: base.title,
          description: base.description,
          scheduledDate: cursor,
          isCompleted: cursor.isAtSameMomentAs(base.scheduledDate)
              ? base.isCompleted
              : false,
          recurrence: base.recurrence,
        ),
      );

      switch (recurrence) {
        case 'daily':
          cursor = cursor.add(const Duration(days: 1));
          break;
        case 'weekly':
          cursor = cursor.add(const Duration(days: 7));
          break;
        case 'monthly':
          cursor = DateTime(
            cursor.month == 12 ? cursor.year + 1 : cursor.year,
            cursor.month == 12 ? 1 : cursor.month + 1,
            cursor.day,
            cursor.hour,
            cursor.minute,
          );
          break;
        default:
          return expanded;
      }
    }

    return expanded;
  }

  Future<void> loadAllActivities(List<int> petIds) async {
    _setLoading(true);
    try {
      final results = await Future.wait(
        petIds.map((id) => _activityService.getActivitiesByPet(id)),
      );

      final fetched = results
          .expand((list) => list)
          .map((r) => _mapToModel(r))
          .toList();

      final seen = <String>{};
      final deduped = fetched.where((a) => seen.add(a.id)).toList();

      final expanded = deduped.expand((a) => _expandRecurring(a)).toList();

      final seenExpanded = <String>{};
      _activities = expanded.where((a) => seenExpanded.add(a.id)).toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addActivity(
    CreateActivityRequest request,
    DateTime selectedDate,
  ) async {
    _setLoading(true);
    try {
      final newId = await _activityService.createActivity(request);
      final created = await _activityService.getActivity(newId);
      final mapped = _mapToModel(created, dateContext: selectedDate);
      final expanded = _expandRecurring(mapped);
      for (final a in expanded) {
        if (!_activities.any((e) => e.id == a.id)) {
          _activities.add(a);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleCompletion(String id) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final newIsCompleted = !_activities[index].isCompleted;

    _activities[index].isCompleted = newIsCompleted;
    notifyListeners();

    try {
      final baseId = id.contains('_') ? id.split('_')[0] : id;
      await _activityService.patchActivity(
        int.parse(baseId),
        UpdateActivityRequest(isActive: !newIsCompleted),
      );
    } catch (e) {
      _activities[index].isCompleted = !newIsCompleted;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String id) async {
    final baseId = id.contains('_') ? id.split('_')[0] : id;

    _activities.removeWhere((a) => a.id == id || a.id.startsWith('${baseId}_'));
    notifyListeners();

    try {
      await _activityService.deleteActivity(int.parse(baseId));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clear() {
    _activities = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
