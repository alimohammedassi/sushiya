import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sushi_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sushiaya.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger database recreation
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Clear existing data if version changed
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS products');
          await db.execute('DROP TABLE IF EXISTS categories');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        rating REAL DEFAULT 0,
        image TEXT,
        description TEXT,
        category TEXT NOT NULL,
        ingredients TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await _insertInitialData(db);
  }

  Future _insertInitialData(Database db) async {
    await db.insert('categories', {
      'name': 'All',
      'emoji': '🍽️',
      'sort_order': 0,
    });
    await db.insert('categories', {
      'name': 'Sushi',
      'emoji': '🍣',
      'sort_order': 1,
    });
    await db.insert('categories', {
      'name': 'Special',
      'emoji': '🍱',
      'sort_order': 2,
    });
    await db.insert('categories', {
      'name': 'Sashimi',
      'emoji': '🍤',
      'sort_order': 3,
    });
  }

  // 👇 CRUD Methods

  Future<List<SushiItem>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return result.map((map) => SushiItem.fromMap(map)).toList();
  }

  Future<int> insertProduct(SushiItem item) async {
    final db = await instance.database;
    final map = item.toMap();
    // Remove ID when inserting new products to let SQLite auto-generate it
    map.remove('id');
    return await db.insert('products', map);
  }

  Future<int> updateProduct(SushiItem item) async {
    final db = await instance.database;
    return await db.update(
      'products',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query(
      'categories',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );
  }

  // Clear all products (useful for debugging)
  Future<void> clearProducts() async {
    final db = await instance.database;
    await db.delete('products');
  }

  // Clear all data (useful for debugging)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('products');
    await db.delete('categories');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
