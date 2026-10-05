import 'package:flutter/material.dart';
import 'package:prayer_basket_2/models/prayer.dart';
import 'package:prayer_basket_2/models/prayer_schedule.dart';
import 'package:prayer_basket_2/repositories/prayer_repository.dart';
import 'package:prayer_basket_2/services/database_helper.dart';

class PrayerProvider extends ChangeNotifier {
  List<Prayer> _prayers = [];
  bool _isLoading = false;

  List<Prayer> get prayers => _prayers;
  bool get isLoading => _isLoading;

  PrayerProvider() {
    loadPrayers();
  }

  /// Fetches all prayers from SQLite and updates state
  Future<void> loadPrayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'prayer_requests',
        orderBy: 'created_at DESC',
      );

      _prayers = maps.map((map) => Prayer.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading prayers from database: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new prayer to SQLite and updates the local state
  Future<void> addPrayer(Prayer newPrayer, {PrayerSchedule? schedule}) async {
    // Optimistic UI update
    _prayers.insert(0, newPrayer);
    notifyListeners();

    try {
      await DatabaseHelper.instance.insertPrayer(newPrayer);
      if (schedule != null) {
        // await DatabaseHelper.instance.insertPrayerSchedule(schedule);
        PrayerRepository(await DatabaseHelper.instance.database)
            .createPrayerWithSchedule(prayer: newPrayer, schedule: schedule);
      }
    } catch (e) {
      debugPrint('Error inserting prayer into database: $e');
      // Rollback on failure
      _prayers.removeWhere((p) => p.id == newPrayer.id);
      notifyListeners();
    }
  }

  /// Marks a prayer as resolved in SQLite and updates state
  Future<void> toggleResolve(String id) async {
    final index = _prayers.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final updatedPrayer = _prayers[index].copyWith(
      status: PrayerStatus.resolved,
      resolvedAt: DateTime.now(),
    );

    _prayers[index] = updatedPrayer;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'prayer_requests',
        updatedPrayer.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error resolving prayer in database: $e');
      await loadPrayers(); // Re-sync state on failure
    }
  }

  /// Reverts a resolved prayer back to active in SQLite
  Future<void> undoResolve(String id) async {
    final index = _prayers.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final updatedPrayer = _prayers[index].copyWith(
      status: PrayerStatus.active,
      resolvedAt: null,
    );

    _prayers[index] = updatedPrayer;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'prayer_requests',
        updatedPrayer.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error undoing resolved status in database: $e');
      await loadPrayers(); // Re-sync state on failure
    }
  }
}