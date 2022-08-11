import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/favorite_currency.dart';

class FavoritesDatabase {
  static final FavoritesDatabase instance = FavoritesDatabase._init();

  static Database? _database;

  FavoritesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('favorites.db');
    return _database!;
  }

  /// Open the database at a given path.
  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Create the database table. If the table already exists, do nothing.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFavoriteCurrency(
        ${FavoriteCurrencyFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${FavoriteCurrencyFields.currency} TEXT NOT NULL,
      )
    ''');
  }

  /// Insert a FavoriteCurrency into the database and return it afterwards.
  Future<FavoriteCurrency> create(FavoriteCurrency currency) async {
    final db = await instance.database;
    final id = await db.insert(tableFavoriteCurrency, currency.toJson());
    return currency.copyWith(id: id);
  }

  /// Get a currency by id from the database.
  Future<FavoriteCurrency> getCurrency(int id) async {
    final db = await instance.database;
    final result = await db.query(tableFavoriteCurrency,
        columns: FavoriteCurrencyFields.values, where: '${FavoriteCurrencyFields.id} = ?', whereArgs: [id]);
    return result.isNotEmpty ? FavoriteCurrency.fromJson(result.first) : throw Exception('Currency $id not found');
  }

  /// Get all currencies from the database and return as a List of FavoriteCurrency objects.
  Future<List<FavoriteCurrency>> getCurrencies() async {
    final db = await instance.database;
    final result = await db.query(tableFavoriteCurrency, columns: FavoriteCurrencyFields.values);
    return result.map((json) => FavoriteCurrency.fromJson(json)).toList();
  }

  /// Delete a currency by id from the database.
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(tableFavoriteCurrency, where: '${FavoriteCurrencyFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    (await instance.database).close();
  }
}
