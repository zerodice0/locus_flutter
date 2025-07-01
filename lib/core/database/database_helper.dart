import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute(DatabaseConstants.createCategoriesTable);
    await db.execute(DatabaseConstants.createPlacesTable);
    await db.execute(DatabaseConstants.createOperatingHoursTable);
    await db.execute(DatabaseConstants.createEventPeriodsTable);
    await db.execute(DatabaseConstants.createSearchHistoryTable);
    await db.execute(DatabaseConstants.createSwipeActionsTable);

    // Create indexes
    await db.execute(DatabaseConstants.createPlaceLocationIndex);
    await db.execute(DatabaseConstants.createPlaceCategoryIndex);
    await db.execute(DatabaseConstants.createOperatingHoursPlaceIndex);
    await db.execute(DatabaseConstants.createEventPeriodsPlaceIndex);
    await db.execute(DatabaseConstants.createSwipeActionsPlaceIndex);
    await db.execute(DatabaseConstants.createSwipeActionsTimestampIndex);

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades
    if (oldVersion < newVersion) {
      if (oldVersion < 2) {
        // Add swipe_actions table in version 2
        await db.execute(DatabaseConstants.createSwipeActionsTable);
        await db.execute(DatabaseConstants.createSwipeActionsPlaceIndex);
        await db.execute(DatabaseConstants.createSwipeActionsTimestampIndex);
      }
      // Add future migration logic here
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    for (final category in DatabaseConstants.defaultCategories) {
      await db.insert(
        DatabaseConstants.tableCategories,
        {
          DatabaseConstants.categoryId: category['id'],
          DatabaseConstants.categoryName: category['name'],
          DatabaseConstants.categoryIcon: category['icon'],
          DatabaseConstants.categoryColor: category['color'],
          DatabaseConstants.categoryIsDefault: category['is_default'],
          DatabaseConstants.categoryCreatedAt: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawDelete(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<int> rawInsert(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Batch operations
  Future<List<dynamic>> batch(Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableSwipeActions);
      await txn.delete(DatabaseConstants.tableSearchHistory);
      await txn.delete(DatabaseConstants.tableEventPeriods);
      await txn.delete(DatabaseConstants.tableOperatingHours);
      await txn.delete(DatabaseConstants.tablePlaces);
      await txn.delete(DatabaseConstants.tableCategories);
      
      // Re-insert default categories
      for (final category in DatabaseConstants.defaultCategories) {
        await txn.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.categoryId: category['id'],
            DatabaseConstants.categoryName: category['name'],
            DatabaseConstants.categoryIcon: category['icon'],
            DatabaseConstants.categoryColor: category['color'],
            DatabaseConstants.categoryIsDefault: category['is_default'],
            DatabaseConstants.categoryCreatedAt: DateTime.now().toIso8601String(),
          },
        );
      }
    });
  }
}