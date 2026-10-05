import 'package:prayer_basket_2/models/prayer.dart';
import 'package:prayer_basket_2/models/prayer_schedule.dart';
import 'package:sqflite/sqflite.dart';

class PrayerRepository {
  final Database db;

  PrayerRepository(this.db);

  Future<void> createPrayerWithSchedule({
    required Prayer prayer,
    PrayerSchedule? schedule,
  }) async {
    await db.transaction((txn) async {
      // 1. Save core prayer
      await txn.insert(
        'prayer_requests',
        prayer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Save schedule if present
      if (schedule != null) {
        await txn.insert(
          'prayer_schedules',
          schedule.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Query prayers due for today based on active schedules
  Future<List<Prayer>> getScheduledPrayersForDay(int dayOfWeek) async {
    final results = await db.rawQuery('''
      SELECT p.* FROM prayer_requests p
      INNER JOIN prayer_schedules s ON p.id = s.prayer_id
      WHERE p.status = 'active'
        AND s.is_active = 1
        AND (s.frequency = 'daily' OR s.days_of_week LIKE ?)
    ''', ['%$dayOfWeek%']);

    return results.map((row) => Prayer.fromMap(row)).toList();
  }

  Future<List<Prayer>> fetchAllPrayers() async {
    final maps = await db.query('prayer_requests', orderBy: 'created_at DESC');
    return maps.map((map) => Prayer.fromMap(map)).toList();
  }
}