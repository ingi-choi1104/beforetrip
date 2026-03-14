import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/city_group_seed.dart';
import '../data/descriptions.dart';
import '../data/seed_data.dart';
import '../models/city_group.dart';
import '../models/destination.dart';
import '../models/monthly_climate.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'beforetrip.db');
    try {
      return await openDatabase(
        path,
        version: 22,
        onCreate: _onCreate,
        onUpgrade: (db, oldVersion, newVersion) async {
          debugPrint('[DB] 버전 업그레이드 $oldVersion → $newVersion: 재생성');
          await db.execute('DROP TABLE IF EXISTS monthly_climates');
          await db.execute('DROP TABLE IF EXISTS destinations');
          await db.execute('DROP TABLE IF EXISTS city_groups');
          await _onCreate(db, newVersion);
          return;
        },
      );
    } catch (e) {
      debugPrint('[DB] 오픈 실패, 재생성: $e');
      await deleteDatabase(path);
      return await openDatabase(path, version: 21, onCreate: _onCreate);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE destinations (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        country       TEXT NOT NULL,
        region        TEXT NOT NULL,
        flag          TEXT NOT NULL,
        theme         TEXT NOT NULL DEFAULT 'general',
        col_coffee    REAL,
        col_meal      REAL,
        col_beer      REAL,
        col_transport REAL,
        col_hotel     REAL,
        min_days           INTEGER NOT NULL DEFAULT 0,
        max_days           INTEGER NOT NULL DEFAULT 0,
        flight_price_low   INTEGER,
        flight_price_high  INTEGER,
        description        TEXT    NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE monthly_climates (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        destination_id TEXT    NOT NULL,
        month          INTEGER NOT NULL,
        min_temp       REAL    NOT NULL,
        max_temp       REAL    NOT NULL,
        precipitation  REAL    NOT NULL,
        daylight_hours REAL    NOT NULL,
        aurora_index   REAL    NOT NULL DEFAULT 0,
        humidity       REAL    NOT NULL DEFAULT 60,
        wind_speed     REAL    NOT NULL DEFAULT 3,
        FOREIGN KEY (destination_id) REFERENCES destinations(id)
          ON DELETE CASCADE,
        UNIQUE (destination_id, month)
      )
    ''');

    await db.execute('''
      CREATE TABLE city_groups (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        region   TEXT    NOT NULL,
        min_days INTEGER NOT NULL DEFAULT 0,
        max_days INTEGER NOT NULL DEFAULT 0,
        dest_ids TEXT    NOT NULL
      )
    ''');

    await _seed(db);
    debugPrint('[DB] beforetrip.db 생성 완료 — 시드 데이터 삽입됨');
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    for (final dest in SeedData.destinations) {
      final map = dest.toMap();
      map['description'] = DestinationDescriptions.data[dest.id] ?? '';
      batch.insert('destinations', map);
      for (final climate in dest.climates) {
        batch.insert('monthly_climates', climate.toMap(dest.id));
      }
    }
    for (final group in CityGroupSeed.groups) {
      batch.insert('city_groups', group.toMap());
    }
    await batch.commit(noResult: true);
  }

  // ─── 조회 ─────────────────────────────────────────────

  Future<List<Destination>> getAllDestinations() async {
    final db = await _database;
    final rows = await db.query(
      'destinations',
      orderBy: 'region, country, name',
    );
    final result = <Destination>[];
    for (final row in rows) {
      final climates = await _getClimates(db, row['id'] as String);
      result.add(Destination.fromMap(row, climates));
    }
    return result;
  }

  Future<Destination?> getDestination(String id) async {
    final db = await _database;
    final rows = await db.query(
      'destinations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    final climates = await _getClimates(db, id);
    return Destination.fromMap(rows.first, climates);
  }

  Future<List<MonthlyClimate>> _getClimates(Database db, String destId) async {
    final rows = await db.query(
      'monthly_climates',
      where: 'destination_id = ?',
      whereArgs: [destId],
      orderBy: 'month',
    );
    return rows.map(MonthlyClimate.fromMap).toList();
  }

  Future<List<CityGroup>> getAllCityGroups() async {
    final db = await _database;
    final rows = await db.query('city_groups', orderBy: 'region, name');
    return rows.map(CityGroup.fromMap).toList();
  }

  // ─── 추가 / 수정 ──────────────────────────────────────

  /// 여행지 추가 또는 전체 덮어쓰기 (climates 포함)
  Future<void> upsertDestination(Destination dest) async {
    final db = await _database;
    await db.insert(
      'destinations',
      dest.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final c in dest.climates) {
      await db.insert(
        'monthly_climates',
        c.toMap(dest.id),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    debugPrint('[DB] upsertDestination: ${dest.id}');
  }

  /// 특정 월 기후 데이터만 수정
  Future<void> updateMonthlyClimate(
    String destId,
    MonthlyClimate climate,
  ) async {
    final db = await _database;
    final count = await db.update(
      'monthly_climates',
      climate.toMap(destId),
      where: 'destination_id = ? AND month = ?',
      whereArgs: [destId, climate.month],
    );
    debugPrint(
      '[DB] updateMonthlyClimate: $destId ${climate.month}월 ($count rows)',
    );
  }

  /// 여행지 테마만 변경
  Future<void> updateTheme(String destId, DestinationTheme theme) async {
    final db = await _database;
    await db.update(
      'destinations',
      {'theme': theme.name},
      where: 'id = ?',
      whereArgs: [destId],
    );
    debugPrint('[DB] updateTheme: $destId → ${theme.name}');
  }

  // ─── 삭제 ─────────────────────────────────────────────

  Future<void> deleteDestination(String id) async {
    final db = await _database;
    await db.delete('destinations', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'monthly_climates',
      where: 'destination_id = ?',
      whereArgs: [id],
    );
    debugPrint('[DB] deleteDestination: $id');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
