import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:live_location_tracking/models/location_model.dart';
import 'package:live_location_tracking/models/synced_record_model.dart';
import 'package:live_location_tracking/models/synced_records_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'local_database.dart';

class DBHelper implements LocalDatabase{
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  @override
  Future<Database> initDB() async {
    try {
      final path = join(await getDatabasesPath(), 'locations.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE locations(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              timestamp INTEGER NOT NULL,
              accuracy REAL,
              speed REAL,
              battery INTEGER,
              network TEXT,
              synced INTEGER NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint("DB init failed: $e");
      throw Exception("DB init failed: $e");
    }
  }

  // Insert
  @override
  Future<int> insertLocation(LocationModel location) async {
    try {
      final dbClient = await db;
      return await dbClient.insert('locations', location.toMap());
    } catch (e) {
      debugPrint("Insert failed: $e");
      throw Exception("Insert failed: $e");
    }
  }

  // Update
  @override
  Future<int> updateLocation(LocationModel location) async {
    try {
      final dbClient = await db;
      return await dbClient.update(
        'locations',
        location.toMap(),
        where: 'id = ?',
        whereArgs: [location.id],
      );
    } catch (e) {
      debugPrint("Update failed for id=${location.id}: $e");
      throw Exception("Update failed for id=${location.id}: $e");
    }
  }

  // Delete
  @override
  Future<int> deleteLocation(int id) async {
    try {
      final dbClient = await db;
      return await dbClient.delete('locations', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("Delete failed for id=$id: $e");
      throw Exception("Delete failed for id=$id: $e");
    }
  }

  // Get by ID
  @override
  Future<LocationModel?> getLocationById(int id) async {
    try {
      final dbClient = await db;
      final res = await dbClient.query('locations', where: 'id = ?', whereArgs: [id]);
      if (res.isNotEmpty) {
        return LocationModel.fromMap(res.first);
      }
      return null;
    } catch (e) {
      debugPrint("Get by ID failed for id=$id: $e");
      throw Exception("Get by ID failed for id=$id: $e");
    }
  }

  // Fetch first 50 unsynced records (synced = 0)
  @override
  Future<List<LocationModel>> getFirst50Unsynced() async {
    try {
      final dbClient = await db;
      final res = await dbClient.query(
        'locations',
        where: 'synced = ?',
        whereArgs: [0],
        limit: 50,
        orderBy: 'timestamp ASC',
      );
      return res.map((e) => LocationModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Fetch first 50 unsynced failed: $e");
      throw Exception("Fetch first 50 unsynced failed: $e");
    }
  }

  // Get synced records (id, lat, long) & Count synced records
  @override
  Future<SyncedRecordsData> getSyncedRecordsData() async {
    try {
      final dbClient = await db;

      final res = await dbClient.rawQuery('''
        SELECT id, latitude, longitude 
        FROM locations 
        WHERE synced = 1
      ''');

      final records = res.map((e) => SyncedRecordModel.fromMap(e)).toList();

      return SyncedRecordsData(
        count: records.length,
        records: records,
      );
    } catch (e) {
      debugPrint("Fetch synced records data failed: $e");
      throw Exception("Fetch synced records data failed: $e");
    }
  }

  //
  Future<int> countSyncedRecords() async {
    try {
      final dbClient = await db;
      final res = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM locations WHERE synced = 1'),
      );
      return res ?? 0;
    } catch (e) {
      debugPrint("Count synced records failed: $e");
      throw Exception("Count synced records failed: $e");
    }
  }
}
