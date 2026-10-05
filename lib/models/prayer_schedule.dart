import 'dart:convert';

enum ScheduleFrequency { daily, weekly, monthly }

class PrayerSchedule {
  final String id;
  final String prayerId;
  final ScheduleFrequency frequency;
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final String timeOfDay;     // HH:mm, e.g., "08:30"
  final bool isActive;
  final DateTime createdAt;

  const PrayerSchedule({
    required this.id,
    required this.prayerId,
    required this.frequency,
    this.daysOfWeek = const [],
    required this.timeOfDay,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'prayer_id': prayerId,
      'frequency': frequency.name,
      'days_of_week': jsonEncode(daysOfWeek),
      'time_of_day': timeOfDay,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PrayerSchedule.fromDbMap(Map<String, dynamic> map) {
    return PrayerSchedule(
      id: map['id'] as String,
      prayerId: map['prayer_id'] as String,
      frequency: ScheduleFrequency.values.byName(map['frequency'] as String),
      daysOfWeek: List<int>.from(jsonDecode(map['days_of_week'] as String)),
      timeOfDay: map['time_of_day'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}