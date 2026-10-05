import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prayer_basket_2/models/prayer.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prayer_basket.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final path = join(dbDir.path, fileName);

    // Check if database exists on device local storage
    final exists = await databaseExists(path);

    if (!exists) {
      // Copy pre-populated DB from asset bundle to local storage
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load('assets/db/$fileName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
      // 1. Core Prayer Table
      await db.execute('''
        CREATE TABLE prayer_requests (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL,
          category TEXT,
          is_confidential INTEGER NOT NULL,
          is_public INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          resolved_at INTEGER,
          updated_at INTEGER,
          resolved_at INTEGER
        );
      ''');

      // 2. Separate Schedules Table
      await db.execute('''
        CREATE TABLE prayer_schedules (
          id TEXT PRIMARY KEY,
          prayer_id TEXT NOT NULL,
          frequency TEXT NOT NULL,
          days_of_week TEXT NOT NULL,
          time_of_day TEXT NOT NULL,
          is_active INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (prayer_id) REFERENCES prayer_requests (id) ON DELETE CASCADE
        );
      ''');
    },
    );
  }
  Future<int> insertPrayerRequest(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('prayer_requests', row);
  }
  
  Future<void> insertPrayer(Prayer prayer) async {
  final db = await database;
  
  // Exclude 'type' from the database map
  final map = prayer.toMap();

  // Dynamically select target table
  final String tableName = switch (prayer.type) {
    PrayerType.request => 'prayer_requests',
    PrayerType.prayer  => 'prayers', // or praise_items / general_prayers
  };

  await db.insert(
    tableName,
    map,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<List<Map<String, dynamic>>> fetchPrayerRequests() async {
    final db = await instance.database;
    return await db.query('prayer_requests', orderBy: 'created_at DESC');
  }
}