import 'package:petwise/contracts/analytics/activity_timeline_slot.dart';

class UserDashboardAnalyticsResponse {
  final int totalPets;
  final int totalScheduledActivities;
  final int totalActiveRoutines;
  final int totalHealthEvents;
  final double medicalComplianceRate;
  final Map<String, int> activityRecurrenceDistribution;
  final Map<String, int> healthEventTypeDistribution;
  final List<ActivityTimelineSlot> activityTimeline;

  UserDashboardAnalyticsResponse({
    required this.totalPets,
    required this.totalScheduledActivities,
    required this.totalActiveRoutines,
    required this.totalHealthEvents,
    required this.medicalComplianceRate,
    required this.activityRecurrenceDistribution,
    required this.healthEventTypeDistribution,
    required this.activityTimeline,
  });

  factory UserDashboardAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, int> recurrenceMap = {};
    if (json['activityRecurrenceDistribution'] is Map) {
      json['activityRecurrenceDistribution'].forEach((key, value) {
        recurrenceMap[key.toString()] =
            num.tryParse(value.toString())?.toInt() ?? 0;
      });
    }

    final Map<String, int> healthTypeMap = {};
    if (json['healthEventTypeDistribution'] is Map) {
      json['healthEventTypeDistribution'].forEach((key, value) {
        healthTypeMap[key.toString()] =
            num.tryParse(value.toString())?.toInt() ?? 0;
      });
    }

    return UserDashboardAnalyticsResponse(
      totalPets:
          num.tryParse(json['totalPets']?.toString() ?? '0')?.toInt() ?? 0,
      totalScheduledActivities:
          num.tryParse(
            json['totalScheduledActivities']?.toString() ?? '0',
          )?.toInt() ??
          0,
      totalActiveRoutines:
          num.tryParse(
            json['totalActiveRoutines']?.toString() ?? '0',
          )?.toInt() ??
          0,
      totalHealthEvents:
          num.tryParse(json['totalHealthEvents']?.toString() ?? '0')?.toInt() ??
          0,
      medicalComplianceRate:
          num.tryParse(
            json['medicalComplianceRate']?.toString() ?? '100.0',
          )?.toDouble() ??
          100.0,
      activityRecurrenceDistribution: recurrenceMap,
      healthEventTypeDistribution: healthTypeMap,
      activityTimeline: json['activityTimeline'] is List
          ? (json['activityTimeline'] as List)
                .map(
                  (item) => ActivityTimelineSlot.fromJson(
                    item is Map ? Map<String, dynamic>.from(item) : {},
                  ),
                )
                .toList()
          : [],
    );
  }
}
