// import 'dart:convert';
import 'package:uuid/uuid.dart';

enum PrayerType { prayer, request }
enum PrayerStatus { active, resolved }

class Prayer {
  final String id;
  final String title;
  final String description;
  final PrayerType type;
  final PrayerStatus status;
  final DateTime createdAt;
  final String? category;
  final bool isConfidential;
  // final bool isPublic;
  // final List<Map<String, dynamic>> prayerRecords;
  final DateTime? resolvedAt; 

  Prayer({
    required this.id,
    required this.title,
    this.description = '',
    this.type = PrayerType.prayer,
    this.status = PrayerStatus.active,
    required this.createdAt,
    this.category,
    this.isConfidential = false,
    // this.isPublic = false,
    // this.prayerRecords = const [],
    this.resolvedAt,
  });

  /// Factory constructor for quick creation
  factory Prayer.create({required String title, required PrayerType type}) {
    return Prayer(
      id: const Uuid().v4(),
      title: title,
      type: type,
      createdAt: DateTime.now(),
    );
  }

  /// Helper to check if prayer was marked resolved on the current calendar day
  bool get wasResolvedToday {
    if (status != PrayerStatus.resolved || resolvedAt == null) return false;
    final now = DateTime.now();
    return resolvedAt!.year == now.year && 
           resolvedAt!.month == now.month && 
           resolvedAt!.day == now.day;
  }

  /// Creates a copy with updated values
  Prayer copyWith({
    String? title,
    String? description,
    PrayerType? type,
    PrayerStatus? status,
    String? category,
    List<int>? weeklyDays,
    bool? isConfidential,
    // bool? isPublic,
    List<Map<String, dynamic>>? prayerRecords, 
    DateTime? resolvedAt,
  }) {
    return Prayer(
      id: id,
      createdAt: createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      isConfidential: isConfidential ?? this.isConfidential,
      // isPublic: isPublic ?? this.isPublic,
      // prayerRecords: prayerRecords ?? this.prayerRecords,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  /// Converts model to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'category': category,
      'is_confidential': isConfidential ? 1 : 0,
      // 'is_public': isPublic ? 1 : 0,
      // 'prayer_records': jsonEncode(prayerRecords),
      'created_at': createdAt.millisecondsSinceEpoch,
      'resolved_at': resolvedAt?.millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Reconstructs model from SQLite Map
  factory Prayer.fromMap(Map<String, dynamic> map) {
    return Prayer(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PrayerStatus.active,
      ),
      category: map['category'] as String?,
      isConfidential: (map['is_confidential'] as int? ?? 0) == 1,
      // isPublic: (map['is_public'] as int? ?? 0) == 1,
      // prayerRecords: map['prayer_records'] != null
      //     ? List<Map<String, dynamic>>.from(
      //         jsonDecode(map['prayer_records'] as String) as List)
      //     : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      resolvedAt: map['resolved_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['resolved_at'] as int)
          : null,
    );
  }
}