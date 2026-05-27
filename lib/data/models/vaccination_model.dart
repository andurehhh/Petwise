import 'package:petwise/contracts/health_event/health_event_response.dart';

enum VaccinationStatus { valid, expiringSoon, expired }

class VaccinationModel {
  final int id;
  final int petId;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime? expiryDate; // parsed from eventName tag |exp:YYYY-MM-DD
  final bool isCompleted;
  final DateTime createdAt;

  VaccinationModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.dateGiven,
    this.expiryDate,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Validity status based on expiry date relative to today.
  /// No expiry date = valid indefinitely.
  VaccinationStatus get status {
    if (expiryDate == null) return VaccinationStatus.valid;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return VaccinationStatus.expired;
    if (daysLeft <= 30) return VaccinationStatus.expiringSoon;
    return VaccinationStatus.valid;
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Build from a HealthEventResponse (type == 'vaccination').
  /// Expiry date is encoded in eventName as suffix `|exp:YYYY-MM-DD`.
  factory VaccinationModel.fromHealthEvent(HealthEventResponse e) {
    final parsed = _parseEventName(e.eventName);
    return VaccinationModel(
      id: e.eventId,
      petId: e.petId,
      vaccineName: parsed.name,
      dateGiven: e.eventDate,
      expiryDate: parsed.expiry,
      isCompleted: e.isCompleted,
      createdAt: e.createdAt,
    );
  }

  /// Encode vaccine name + expiry into the eventName field.
  static String encodeEventName(String name, DateTime? expiry) {
    if (expiry == null) return name;
    final tag =
        '|exp:${expiry.year.toString().padLeft(4, '0')}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';
    return '$name$tag';
  }

  static ({String name, DateTime? expiry}) _parseEventName(String raw) {
    const tag = '|exp:';
    final idx = raw.lastIndexOf(tag);
    if (idx == -1) return (name: raw, expiry: null);
    final datePart = raw.substring(idx + tag.length).trim();
    final expiry = DateTime.tryParse(datePart);
    return (name: raw.substring(0, idx).trim(), expiry: expiry);
  }
}
