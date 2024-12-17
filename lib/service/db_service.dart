import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  static Database? _database;

  factory DBService() {
    return _instance;
  }

  DBService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'v.db');

    return await openDatabase(
      path,
      version: 2, // Increment this version when schema changes
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vocabulary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            type TEXT NOT NULL,
            examples TEXT NOT NULL,
            synonym TEXT,
            antonym TEXT,
            dateAdded TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrades here
        if (oldVersion < newVersion) {
          await db.execute(''' 
            -- Add any new SQL commands for schema changes
          ''');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    final db = await database;
    return await db.rawQuery(sql);
  }

  Future<int> insertData(String sql) async {
    final db = await database;
    return await db.rawInsert(sql);
  }

  Future<int> updateData(String sql) async {
    final db = await database;
    return await db.rawUpdate(sql);
  }

  Future<int> deleteData(String sql) async {
    final db = await database;
    return await db.rawDelete(sql);
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
