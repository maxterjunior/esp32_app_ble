import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "esp32_app_ble.db";
  static const _databaseVersion = 1;

  static const table = 'gps_data';

  static const columnId = '_id';
  static const columnLat = 'latitude';
  static const columnLong = 'longitude';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    print('path BD: $path');
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnLat REAL NOT NULL,
            $columnLong REAL NOT NULL
          )
          ''');
  }

  Future<int?> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db?.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    print('BD: $table - queryAllRows');
    Database? db = await instance.database;
    return await db!.query(table);
  }

  // Clear the table
  Future<int?> deleteAll() async {
    Database? db = await instance.database;
    return await db?.delete(table);
  }
}
